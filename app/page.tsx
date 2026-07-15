import Link from "next/link";
import { buttonVariants } from "@/components/ui/button";

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center gap-4 bg-zinc-50 px-6 text-center dark:bg-black">
      <h1 className="text-3xl font-semibold tracking-tight text-black dark:text-zinc-50">
        ValidApp
      </h1>
      <p className="max-w-sm text-base text-zinc-600 dark:text-zinc-400">
        Prepárate para tu examen de validación de estudios.
      </p>
      <div className="flex gap-3">
        <Link href="/registro" className={buttonVariants({ variant: "default" })}>
          Crear cuenta
        </Link>
        <Link href="/login" className={buttonVariants({ variant: "outline" })}>
          Iniciar sesión
        </Link>
      </div>
    </main>
  );
}
