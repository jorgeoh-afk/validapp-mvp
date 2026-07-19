"use server";

// Dominio: Autenticación y usuarios — pero, a diferencia de
// `lib/data/profile-settings.ts` (que solo toca la tabla `profiles`), esta
// acción no lee ni escribe ninguna tabla propia de ValidApp: opera
// exclusivamente contra Supabase Auth (`auth.users`, vía el SDK, nunca SQL
// directo). Se separa en su propio archivo a propósito, aunque comparte
// pantalla ("Mi perfil") con `profile-settings.ts`, por tres razones:
//   1. Superficie de auditoría: un cambio de contraseña es sensible por sí
//      mismo (reautenticación, manejo de errores de Auth) y conviene poder
//      revisarlo sin mezclarlo con la edición de `full_name`.
//   2. Separación de producto: la sección "Seguridad de la cuenta" en la UI
//      es explícitamente distinta de "Editar nombre" (ver tarea de diseño
//      previa), así que el código del servidor refleja esa misma frontera.
//   3. No depende de la política RLS `profiles_update_own`: cualquier
//      cambio futuro a esa política no debería poder afectar, ni por
//      accidente, el flujo de cambio de contraseña.
//
// Mecanismo de reautenticación (decisión de este agente, ver auditoría):
// Supabase Auth NO exige la contraseña actual en `updateUser({ password })`
// por defecto (eso solo ocurre si se activa "Secure password change" en el
// proveedor de correo del proyecto, y ahí el flujo es distinto: envía un
// nonce por correo que hay que pasar a `updateUser`, ver
// `reauthenticate()`/`nonce` en `@supabase/auth-js`). Como esa opción vive en
// la configuración remota de Supabase (fuera del alcance de este agente) y
// el producto pidió una reautenticación con la contraseña actual sin salto
// de correo, se implementa reautenticación local: se reintenta
// `signInWithPassword` con el correo de la sesión ya validada
// (`auth.getUser()`) y la contraseña actual ingresada, usando el MISMO
// cliente de Supabase (con cookies) de esta Server Action.
//
// Efecto sobre la sesión (verificado leyendo
// `node_modules/@supabase/auth-js/dist/module/GoTrueClient.js`):
// - Si la contraseña actual es incorrecta, `signInWithPassword` devuelve un
//   error y NO llama a `_saveSession`: la sesión original queda intacta.
// - Si es correcta, `signInWithPassword` sí llama a `_saveSession` +
//   notifica `SIGNED_IN`: esto reemplaza las cookies de sesión por una
//   sesión nueva y válida del MISMO usuario (no cierra sesión ni la
//   invalida "de forma indeseada": el estudiante sigue autenticado, solo
//   con tokens renovados). El `updateUser` posterior reutiliza esa sesión
//   recién guardada.
// - Invalidación de OTRAS sesiones/dispositivos: `_updateUser` (ver mismo
//   archivo, método `_updateUser`) solo hace `PUT /user` con el nuevo
//   password y guarda la sesión propia; no llama a `signOut` ni a ningún
//   endpoint de revocación de otras sesiones. Por eso, después de un cambio
//   de contraseña exitoso, se llama explícitamente a
//   `supabase.auth.signOut({ scope: "others" })`: cierra cualquier otra
//   sesión activa del mismo usuario (otro navegador/dispositivo) sin tocar
//   la sesión actual, que es justamente el cliente que acaba de reautenticar
//   la contraseña actual más arriba.
//
// Rate limiting: no se agrega una capa propia de límite de intentos. GoTrue
// ya modela `over_request_rate_limit` como código de error tipado en el SDK
// (`error-codes.d.ts`), lo que confirma que el servidor de Auth aplica
// límites de tasa a sus endpoints (incluido el de login por contraseña) de
// forma nativa; este código se traduce a un mensaje específico más abajo en
// vez de reinventar un limitador local.

import { createClient } from "@/lib/supabase/server";

export type UpdatePasswordState =
  | { status: "error"; message: string }
  | { status: "success" }
  | null;

const MIN_PASSWORD_LENGTH = 6; // Misma regla que `minLength` en /registro.

export async function updatePassword(
  _prevState: UpdatePasswordState,
  formData: FormData
): Promise<UpdatePasswordState> {
  const currentPassword = String(formData.get("currentPassword") ?? "");
  const newPassword = String(formData.get("newPassword") ?? "");
  const confirmPassword = String(formData.get("confirmPassword") ?? "");

  if (!currentPassword || !newPassword || !confirmPassword) {
    return { status: "error", message: "Completa los tres campos." };
  }

  if (newPassword.length < MIN_PASSWORD_LENGTH) {
    return {
      status: "error",
      message: `La nueva contraseña debe tener al menos ${MIN_PASSWORD_LENGTH} caracteres.`,
    };
  }

  if (newPassword !== confirmPassword) {
    return {
      status: "error",
      message: "La nueva contraseña y su confirmación no coinciden.",
    };
  }

  if (newPassword === currentPassword) {
    return {
      status: "error",
      message: "Tu nueva contraseña debe ser distinta de la actual.",
    };
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user || !user.email) {
    return {
      status: "error",
      message: "Tu sesión caducó. Inicia sesión de nuevo para cambiar tu contraseña.",
    };
  }

  // Reautenticación: confirma la contraseña actual reintentando el login.
  // Si falla, la sesión original no se toca (ver comentario de cabecera).
  const { error: reauthError } = await supabase.auth.signInWithPassword({
    email: user.email,
    password: currentPassword,
  });

  if (reauthError) {
    if (
      reauthError.code === "over_request_rate_limit" ||
      reauthError.code === "over_email_send_rate_limit"
    ) {
      return {
        status: "error",
        message: "Hiciste demasiados intentos. Espera unos minutos y vuelve a intentarlo.",
      };
    }
    return { status: "error", message: "Tu contraseña actual no es correcta." };
  }

  const { error: updateError } = await supabase.auth.updateUser({
    password: newPassword,
  });

  if (updateError) {
    if (updateError.code === "same_password") {
      return {
        status: "error",
        message: "Tu nueva contraseña debe ser distinta de la actual.",
      };
    }
    if (updateError.code === "weak_password") {
      return {
        status: "error",
        message: "Esa contraseña es muy débil. Prueba con una combinación más larga o variada.",
      };
    }
    return {
      status: "error",
      message: "No pudimos actualizar tu contraseña. Intenta de nuevo.",
    };
  }

  // No se bloquea el éxito si esto falla: la contraseña ya quedó cambiada,
  // que es lo importante para la cuenta. Si el cierre de otras sesiones
  // falla (p. ej. error de red puntual), se registra pero no se muestra
  // como error al estudiante — su contraseña sí se actualizó correctamente.
  const { error: signOutOthersError } = await supabase.auth.signOut({
    scope: "others",
  });
  if (signOutOthersError) {
    console.error(
      "No se pudieron cerrar las otras sesiones tras el cambio de contraseña:",
      signOutOthersError.message
    );
  }

  return { status: "success" };
}
