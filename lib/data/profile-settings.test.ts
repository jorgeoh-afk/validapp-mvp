// Pruebas locales de `updateProfile` (lib/data/profile-settings.ts), tras el
// wizard de 3 pasos (tipo de estudiante -> programa -> curso/nivel) agregado
// junto con 0028_regular_epja_curriculum_hierarchy.sql.
//
// Cubre las pruebas mínimas #1-#3 del pedido original del usuario (sección
// "Estudiante" / integridad de perfil), simulando el cliente de Supabase (no
// se conecta a una base real ni aplica la migración/seed 0028):
//   #1 Un menor puede seleccionar 7° Básico dentro de Currículum Regular.
//   #2 Un menor NO puede seleccionar "Primer Nivel Medio" (EPJA): debe
//      bloquearse en el servidor con un mensaje amigable, sin llegar al
//      error crudo de los triggers `levels_program_curriculum_match` /
//      `profiles_sync_target_level` de la base de datos.
//   #3 Un adulto puede seleccionar "Segundo Nivel Medio" (EPJA).
// También cubre casos de integridad ya documentados en el propio archivo
// (curso que no pertenece al programa elegido, curso sin programa, sesión
// caducada) para no dejar sin probar la validación de servidor completa.
import { describe, it, expect, vi } from "vitest";
import { createSupabaseMock, type TableHandler } from "./__test-helpers__/supabase-mock";

let mockClient: ReturnType<typeof createSupabaseMock>["client"];

vi.mock("@/lib/supabase/server", () => ({
  createClient: async () => mockClient,
}));

vi.mock("next/cache", () => ({
  revalidatePath: vi.fn(),
}));

const { updateProfile } = await import("./profile-settings");

// Ids/nombres realistas (no reales de dev) para los 2 programas y 2 cursos
// usados en las pruebas: uno de Currículum Regular (menores) y uno de EPJA
// Exámenes Libres (adultos), cada uno con su curso correspondiente.
const REGULAR_PROGRAM_ID = "program-regular-examenes-libres";
const EPJA_PROGRAM_ID = "program-epja-examenes-libres";
const REGULAR_7_BASICO_ID = "level-7-basico";
const EPJA_PRIMER_NIVEL_MEDIO_ID = "level-epja-primer-nivel-medio";
const EPJA_SEGUNDO_NIVEL_MEDIO_ID = "level-epja-segundo-nivel-medio";

const PROGRAMS: Record<string, { id: string; curriculum_type: string }> = {
  [REGULAR_PROGRAM_ID]: { id: REGULAR_PROGRAM_ID, curriculum_type: "regular" },
  [EPJA_PROGRAM_ID]: { id: EPJA_PROGRAM_ID, curriculum_type: "epja" },
};

const LEVELS: Record<string, { id: string; program_id: string }> = {
  [REGULAR_7_BASICO_ID]: { id: REGULAR_7_BASICO_ID, program_id: REGULAR_PROGRAM_ID },
  [EPJA_PRIMER_NIVEL_MEDIO_ID]: {
    id: EPJA_PRIMER_NIVEL_MEDIO_ID,
    program_id: EPJA_PROGRAM_ID,
  },
  [EPJA_SEGUNDO_NIVEL_MEDIO_ID]: {
    id: EPJA_SEGUNDO_NIVEL_MEDIO_ID,
    program_id: EPJA_PROGRAM_ID,
  },
};

function programsHandler(): TableHandler {
  return (state) => {
    const id = state.filters.id as string | undefined;
    const program = id ? PROGRAMS[id] : undefined;
    return { data: program ?? null };
  };
}

function levelsHandler(): TableHandler {
  return (state) => {
    const id = state.filters.id as string | undefined;
    const level = id ? LEVELS[id] : undefined;
    return { data: level ?? null };
  };
}

function profilesHandler(): TableHandler {
  return () => ({ data: null, error: null });
}

function setMock(user: { id: string; email?: string } | null = { id: "student-1" }) {
  const mock = createSupabaseMock({
    user,
    from: {
      programs: programsHandler(),
      levels: levelsHandler(),
      profiles: profilesHandler(),
    },
  });
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

describe("updateProfile", () => {
  it("#1 permite a un menor seleccionar 7° Básico dentro de Currículum Regular", async () => {
    setMock();
    const result = await updateProfile(
      null,
      formData({
        fullName: "Estudiante Menor",
        studentAgeGroup: "menor_18",
        targetProgramId: REGULAR_PROGRAM_ID,
        targetLevelId: REGULAR_7_BASICO_ID,
      })
    );
    expect(result).toEqual({ status: "success" });
  });

  it('#2 bloquea a un menor que intenta seleccionar "Primer Nivel Medio" (EPJA), con mensaje amigable', async () => {
    setMock();
    const result = await updateProfile(
      null,
      formData({
        fullName: "Estudiante Menor",
        studentAgeGroup: "menor_18",
        targetProgramId: EPJA_PROGRAM_ID,
        targetLevelId: EPJA_PRIMER_NIVEL_MEDIO_ID,
      })
    );
    expect(result).toEqual({
      status: "error",
      message:
        "El programa elegido no corresponde con el tipo de estudiante seleccionado.",
    });
  });

  it('#3 permite a un adulto seleccionar "Segundo Nivel Medio" (EPJA)', async () => {
    setMock();
    const result = await updateProfile(
      null,
      formData({
        fullName: "Estudiante Adulto",
        studentAgeGroup: "mayor_18",
        targetProgramId: EPJA_PROGRAM_ID,
        targetLevelId: EPJA_SEGUNDO_NIVEL_MEDIO_ID,
      })
    );
    expect(result).toEqual({ status: "success" });
  });

  it("rechaza un curso que no pertenece al programa elegido (aunque ambos existan)", async () => {
    setMock();
    const result = await updateProfile(
      null,
      formData({
        fullName: "Estudiante",
        studentAgeGroup: "mayor_18",
        targetProgramId: EPJA_PROGRAM_ID,
        targetLevelId: REGULAR_7_BASICO_ID,
      })
    );
    expect(result).toEqual({
      status: "error",
      message: "El curso elegido no pertenece al programa seleccionado.",
    });
  });

  it("rechaza un curso sin haber elegido antes un programa", async () => {
    setMock();
    const result = await updateProfile(
      null,
      formData({
        fullName: "Estudiante",
        studentAgeGroup: "menor_18",
        targetLevelId: REGULAR_7_BASICO_ID,
      })
    );
    expect(result).toEqual({
      status: "error",
      message: "Elige primero un programa educativo antes que un curso.",
    });
  });

  it("permite guardar un programa EPJA sin modalidad de cursos propios (p. ej. EPJA Regular/Flexible), sin curso", async () => {
    setMock();
    const result = await updateProfile(
      null,
      formData({
        fullName: "Estudiante Adulto",
        studentAgeGroup: "mayor_18",
        targetProgramId: EPJA_PROGRAM_ID,
      })
    );
    expect(result).toEqual({ status: "success" });
  });

  it("rechaza si falta el nombre completo", async () => {
    setMock();
    const result = await updateProfile(null, formData({ fullName: "  " }));
    expect(result).toEqual({
      status: "error",
      message: "Ingresa tu nombre completo.",
    });
  });

  it("rechaza si la sesión caducó", async () => {
    setMock(null);
    const result = await updateProfile(
      null,
      formData({ fullName: "Estudiante" })
    );
    expect(result).toEqual({
      status: "error",
      message: "Tu sesión caducó. Inicia sesión de nuevo para guardar tus cambios.",
    });
  });
});
