// Helper de pruebas locales (no forma parte del código de producción). No
// coincide con el patrón `lib/**/*.test.ts` de `vitest.config.ts`, así que
// vitest no intenta ejecutarlo como archivo de test.
//
// Simula lo mínimo del cliente de Supabase (`from().select()...`,
// `.rpc()`, `.auth.getUser()`) que necesitan los tests de
// `essay-attempts.ts`, `diagnostics.ts` y `lessons.ts` para verificar, sin
// tocar una base de datos real, que:
//   1) esos módulos llaman a las funciones RPC de la migración 0019 en vez
//      de leer `questions` directamente, y
//   2) los flujos de "iniciar/responder/calificar" siguen funcionando con
//      la forma de datos que esas funciones RPC devuelven.

export type MockCall =
  | { type: "select"; table: string }
  | { type: "insert"; table: string; args: unknown }
  | { type: "update"; table: string; args: unknown }
  | { type: "upsert"; table: string; args: unknown }
  | { type: "delete"; table: string }
  | { type: "rpc"; fn: string; args: unknown };

export type QueryState = {
  table: string;
  method: "select" | "insert" | "update" | "upsert" | "delete";
  filters: Record<string, unknown>;
  payload?: unknown;
};

export type TableHandler = (
  state: QueryState
) => { data?: unknown; error?: { message: string } | null; count?: number };

export type RpcHandler = (
  args: Record<string, unknown> | undefined
) => { data?: unknown; error?: { message: string } | null };

type QueryChain = {
  select: (cols?: string, opts?: unknown) => QueryChain;
  eq: (col: string, val: unknown) => QueryChain;
  in: (col: string, vals: unknown) => QueryChain;
  is: (col: string, val: unknown) => QueryChain;
  order: (col?: string, opts?: unknown) => QueryChain;
  limit: (n?: number) => QueryChain;
  returns: () => QueryChain;
  maybeSingle: () => SingleResultChain;
  single: () => SingleResultChain;
  then: (
    onFulfilled: (value: { data: unknown; error: unknown; count?: number }) => unknown,
    onRejected?: (reason: unknown) => unknown
  ) => Promise<unknown>;
};

// `.single()`/`.maybeSingle()` en supabase-js real siguen siendo
// "thenables" que además aceptan `.returns<>()`/`.overrideTypes<>()`
// encadenado después (ver `getLesson` en `lib/data/lessons.ts`). Se modela
// igual aquí: un objeto que es awaitable Y tiene `.returns()`.
type SingleResultChain = {
  returns: () => SingleResultChain;
  then: (
    onFulfilled: (value: { data: unknown; error: unknown; count?: number }) => unknown,
    onRejected?: (reason: unknown) => unknown
  ) => Promise<unknown>;
};

function makeSingleResult(
  resolve: () => { data: unknown; error: unknown; count?: number }
): SingleResultChain {
  const result: SingleResultChain = {
    returns: () => result,
    then: (onFulfilled, onRejected) => Promise.resolve(resolve()).then(onFulfilled, onRejected),
  };
  return result;
}

export type AuthMockHandlers = {
  // Usado por `lib/data/account-security.ts` para simular la
  // reautenticación con la contraseña actual sin tocar Supabase real.
  signInWithPassword?: (args: {
    email: string;
    password: string;
  }) => { error?: { message: string; code?: string } | null };
  updateUser?: (args: {
    password?: string;
  }) => { error?: { message: string; code?: string } | null };
};

export function createSupabaseMock(opts: {
  user?: { id: string; email?: string } | null;
  from?: Record<string, TableHandler>;
  rpc?: Record<string, RpcHandler>;
  auth?: AuthMockHandlers;
}) {
  const calls: MockCall[] = [];

  function makeQuery(
    table: string,
    method: QueryState["method"],
    payload?: unknown
  ): QueryChain {
    const state: QueryState = { table, method, filters: {}, payload };
    const resolve = () => {
      const handler = opts.from?.[table];
      const result = handler ? handler(state) : { data: null, error: null };
      return {
        data: result.data ?? null,
        error: result.error ?? null,
        count: result.count,
      };
    };
    const chain: QueryChain = {
      select: () => chain,
      eq: (col, val) => {
        state.filters[col] = val;
        return chain;
      },
      in: (col, vals) => {
        state.filters[col] = vals;
        return chain;
      },
      is: (col, val) => {
        state.filters[col] = val;
        return chain;
      },
      order: () => chain,
      limit: () => chain,
      returns: () => chain,
      maybeSingle: () => makeSingleResult(resolve),
      single: () => makeSingleResult(resolve),
      then: (onFulfilled, onRejected) => Promise.resolve(resolve()).then(onFulfilled, onRejected),
    };
    return chain;
  }

  const client = {
    auth: {
      getUser: async () => ({ data: { user: opts.user ?? null } }),
      signInWithPassword: async (args: { email: string; password: string }) => {
        const handler = opts.auth?.signInWithPassword;
        const result = handler ? handler(args) : { error: null };
        return { data: {}, error: result.error ?? null };
      },
      updateUser: async (args: { password?: string }) => {
        const handler = opts.auth?.updateUser;
        const result = handler ? handler(args) : { error: null };
        return { data: {}, error: result.error ?? null };
      },
    },
    from(table: string) {
      return {
        select: (cols?: string, selectOpts?: unknown) => {
          calls.push({ type: "select", table });
          return makeQuery(table, "select", { cols, selectOpts });
        },
        insert: (rows: unknown) => {
          calls.push({ type: "insert", table, args: rows });
          return makeQuery(table, "insert", rows);
        },
        update: (vals: unknown) => {
          calls.push({ type: "update", table, args: vals });
          return makeQuery(table, "update", vals);
        },
        upsert: (vals: unknown) => {
          calls.push({ type: "upsert", table, args: vals });
          return makeQuery(table, "upsert", vals);
        },
        delete: () => {
          calls.push({ type: "delete", table });
          return makeQuery(table, "delete");
        },
      };
    },
    rpc(fn: string, args?: Record<string, unknown>) {
      calls.push({ type: "rpc", fn, args });
      const handler = opts.rpc?.[fn];
      const result = handler ? handler(args) : { data: null, error: null };
      const resolved = { data: result.data ?? null, error: result.error ?? null };
      const rpcChain = {
        maybeSingle: () => makeSingleResult(() => resolved),
        single: () => makeSingleResult(() => resolved),
        returns: () => rpcChain,
        then: (
          onFulfilled: (value: typeof resolved) => unknown,
          onRejected?: (reason: unknown) => unknown
        ) => Promise.resolve(resolved).then(onFulfilled, onRejected),
      };
      return rpcChain;
    },
  };

  return { client, calls };
}

/** Filtra las llamadas hechas a `.from(table)`, útil para asserts negativos. */
export function callsToTable(calls: MockCall[], table: string) {
  return calls.filter((c) => "table" in c && c.table === table);
}

/** Filtra las llamadas hechas a `.rpc(fn)`. */
export function callsToRpc(calls: MockCall[], fn: string) {
  return calls.filter((c): c is Extract<MockCall, { type: "rpc" }> => c.type === "rpc" && c.fn === fn);
}
