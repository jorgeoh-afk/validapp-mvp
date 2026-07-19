import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

const ADMIN_PREFIX = "/admin";
// Se exporta para que `signIn` (`lib/data/auth.ts`) valide el parámetro
// `?next=` con la misma lista, en vez de mantener una copia separada que
// pueda quedar desincronizada (como pasó con "/ensayos").
export const STUDENT_PREFIXES = ["/panel", "/diagnostico", "/ruta", "/leccion", "/ensayos"];

export async function updateSession(request: NextRequest) {
  let response = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          );
          response = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            response.cookies.set(name, value, options)
          );
        },
      },
    }
  );

  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { pathname } = request.nextUrl;
  const needsStudent = STUDENT_PREFIXES.some((prefix) =>
    pathname.startsWith(prefix)
  );
  const needsAdmin = pathname.startsWith(ADMIN_PREFIX);

  if ((needsStudent || needsAdmin) && !user) {
    const loginUrl = new URL("/login", request.url);
    loginUrl.searchParams.set("next", pathname);
    return NextResponse.redirect(loginUrl);
  }

  if (needsAdmin && user) {
    const { data: profile } = await supabase
      .from("profiles")
      .select("role")
      .eq("id", user.id)
      .single();

    if (profile?.role !== "administrador") {
      return NextResponse.redirect(new URL("/panel", request.url));
    }
  }

  return response;
}
