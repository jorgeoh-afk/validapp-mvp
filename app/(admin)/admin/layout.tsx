import { redirect } from "next/navigation";
import { getCurrentProfile } from "@/lib/data/profiles";
import { signOut } from "@/lib/data/auth";
import { AdminNav } from "@/components/admin/admin-nav";

export default async function AdminLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const profile = await getCurrentProfile();

  // Defensa en profundidad: el middleware ya protege /admin, pero el layout
  // vuelve a confirmar el rol por si el layout se alcanza sin pasar por él.
  if (!profile) {
    redirect("/login?next=/admin");
  }

  if (profile.role !== "administrador") {
    redirect("/panel");
  }

  return (
    <div className="flex min-h-screen flex-col md:flex-row">
      <AdminNav adminName={profile.full_name} signOutAction={signOut} />
      <main className="flex-1 px-4 py-6 md:px-8 md:py-8">{children}</main>
    </div>
  );
}
