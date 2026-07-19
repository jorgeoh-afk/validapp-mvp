// Pruebas locales de `updatePassword` (lib/data/account-security.ts).
// Se simula el cliente de Supabase (no se conecta a una base ni a Auth
// reales) para verificar: validaciones de servidor, que la contraseña
// actual se valida vía `signInWithPassword` antes de llamar a `updateUser`,
// y que los códigos de error de `@supabase/auth-js` (`same_password`,
// `weak_password`, `over_request_rate_limit`) se traducen a mensajes
// específicos en vez de un mensaje genérico único.
import { describe, it, expect, vi } from "vitest";
import { createSupabaseMock, type AuthMockHandlers } from "./__test-helpers__/supabase-mock";

let mockClient: ReturnType<typeof createSupabaseMock>["client"];

vi.mock("@/lib/supabase/server", () => ({
  createClient: async () => mockClient,
}));

const { updatePassword } = await import("./account-security");

function setMock(opts: {
  user?: { id: string; email?: string } | null;
  auth?: AuthMockHandlers;
}) {
  const mock = createSupabaseMock(opts);
  mockClient = mock.client;
  return mock;
}

function formData(fields: Record<string, string>) {
  const fd = new FormData();
  for (const [key, value] of Object.entries(fields)) {
    fd.set(key, value);
  }
  return fd;
}

describe("updatePassword", () => {
  it("rechaza si faltan campos", async () => {
    setMock({ user: { id: "u1", email: "a@a.com" } });
    const result = await updatePassword(
      null,
      formData({ currentPassword: "", newPassword: "abcdef", confirmPassword: "abcdef" })
    );
    expect(result).toEqual({ status: "error", message: "Completa los tres campos." });
  });

  it("rechaza la nueva contraseña si es muy corta", async () => {
    setMock({ user: { id: "u1", email: "a@a.com" } });
    const result = await updatePassword(
      null,
      formData({ currentPassword: "actual1", newPassword: "abc", confirmPassword: "abc" })
    );
    expect(result).toMatchObject({ status: "error" });
    expect((result as { message: string }).message).toMatch(/al menos 6 caracteres/);
  });

  it("rechaza si la confirmación no coincide con la nueva contraseña", async () => {
    setMock({ user: { id: "u1", email: "a@a.com" } });
    const result = await updatePassword(
      null,
      formData({ currentPassword: "actual1", newPassword: "nueva123", confirmPassword: "otraCosa" })
    );
    expect(result).toEqual({
      status: "error",
      message: "La nueva contraseña y su confirmación no coinciden.",
    });
  });

  it("rechaza si la nueva contraseña es igual a la actual, sin llamar a Supabase", async () => {
    const mock = setMock({ user: { id: "u1", email: "a@a.com" } });
    const result = await updatePassword(
      null,
      formData({ currentPassword: "igual123", newPassword: "igual123", confirmPassword: "igual123" })
    );
    expect(result).toEqual({
      status: "error",
      message: "Tu nueva contraseña debe ser distinta de la actual.",
    });
    expect(mock.calls).toHaveLength(0);
  });

  it("devuelve error de sesión caducada si no hay usuario", async () => {
    setMock({ user: null });
    const result = await updatePassword(
      null,
      formData({ currentPassword: "actual1", newPassword: "nueva123", confirmPassword: "nueva123" })
    );
    expect(result).toEqual({
      status: "error",
      message: "Tu sesión caducó. Inicia sesión de nuevo para cambiar tu contraseña.",
    });
  });

  it("rechaza si la contraseña actual ingresada es incorrecta (reautenticación falla) y no llega a updateUser", async () => {
    let updateUserCalled = false;
    setMock({
      user: { id: "u1", email: "estudiante@validapp.cl" },
      auth: {
        signInWithPassword: ({ email, password }) => {
          expect(email).toBe("estudiante@validapp.cl");
          expect(password).toBe("incorrecta1");
          return { error: { message: "Invalid login credentials", code: "invalid_credentials" } };
        },
        updateUser: () => {
          updateUserCalled = true;
          return { error: null };
        },
      },
    });

    const result = await updatePassword(
      null,
      formData({ currentPassword: "incorrecta1", newPassword: "nueva123", confirmPassword: "nueva123" })
    );

    expect(result).toEqual({ status: "error", message: "Tu contraseña actual no es correcta." });
    expect(updateUserCalled).toBe(false);
  });

  it("reporta un mensaje específico si Supabase Auth devuelve over_request_rate_limit", async () => {
    setMock({
      user: { id: "u1", email: "estudiante@validapp.cl" },
      auth: {
        signInWithPassword: () => ({
          error: { message: "rate limited", code: "over_request_rate_limit" },
        }),
      },
    });

    const result = await updatePassword(
      null,
      formData({ currentPassword: "actual1", newPassword: "nueva123", confirmPassword: "nueva123" })
    );

    expect(result).toEqual({
      status: "error",
      message: "Hiciste demasiados intentos. Espera unos minutos y vuelve a intentarlo.",
    });
  });

  it("actualiza la contraseña cuando la reautenticación es correcta", async () => {
    let updateUserArgs: { password?: string } | null = null;
    setMock({
      user: { id: "u1", email: "estudiante@validapp.cl" },
      auth: {
        signInWithPassword: () => ({ error: null }),
        updateUser: (args) => {
          updateUserArgs = args;
          return { error: null };
        },
      },
    });

    const result = await updatePassword(
      null,
      formData({ currentPassword: "actual1", newPassword: "nuevaSegura1", confirmPassword: "nuevaSegura1" })
    );

    expect(result).toEqual({ status: "success" });
    expect(updateUserArgs).toEqual({ password: "nuevaSegura1" });
  });

  it("cierra las demás sesiones (scope: others) tras un cambio exitoso", async () => {
    let signOutArgs: { scope?: string } | null = null;
    setMock({
      user: { id: "u1", email: "estudiante@validapp.cl" },
      auth: {
        signInWithPassword: () => ({ error: null }),
        updateUser: () => ({ error: null }),
        signOut: (args) => {
          signOutArgs = args;
          return { error: null };
        },
      },
    });

    const result = await updatePassword(
      null,
      formData({ currentPassword: "actual1", newPassword: "nuevaSegura1", confirmPassword: "nuevaSegura1" })
    );

    expect(result).toEqual({ status: "success" });
    expect(signOutArgs).toEqual({ scope: "others" });
  });

  it("igual reporta éxito si falla el cierre de otras sesiones (la contraseña ya cambió)", async () => {
    setMock({
      user: { id: "u1", email: "estudiante@validapp.cl" },
      auth: {
        signInWithPassword: () => ({ error: null }),
        updateUser: () => ({ error: null }),
        signOut: () => ({ error: { message: "network error" } }),
      },
    });

    const result = await updatePassword(
      null,
      formData({ currentPassword: "actual1", newPassword: "nuevaSegura1", confirmPassword: "nuevaSegura1" })
    );

    expect(result).toEqual({ status: "success" });
  });

  it("traduce same_password de updateUser a un mensaje específico", async () => {
    setMock({
      user: { id: "u1", email: "estudiante@validapp.cl" },
      auth: {
        signInWithPassword: () => ({ error: null }),
        updateUser: () => ({ error: { message: "same password", code: "same_password" } }),
      },
    });

    const result = await updatePassword(
      null,
      formData({ currentPassword: "actual1", newPassword: "otraNueva1", confirmPassword: "otraNueva1" })
    );

    expect(result).toEqual({
      status: "error",
      message: "Tu nueva contraseña debe ser distinta de la actual.",
    });
  });

  it("traduce weak_password de updateUser a un mensaje específico", async () => {
    setMock({
      user: { id: "u1", email: "estudiante@validapp.cl" },
      auth: {
        signInWithPassword: () => ({ error: null }),
        updateUser: () => ({ error: { message: "weak", code: "weak_password" } }),
      },
    });

    const result = await updatePassword(
      null,
      formData({ currentPassword: "actual1", newPassword: "111111", confirmPassword: "111111" })
    );

    expect(result).toEqual({
      status: "error",
      message: "Esa contraseña es muy débil. Prueba con una combinación más larga o variada.",
    });
  });
});
