import { notFound, redirect } from "next/navigation";
import { getAttemptView } from "@/lib/data/essay-attempts";
import { EssayAttemptForm } from "./essay-attempt-form";

export default async function EnsayoIntentoPage({
  params,
}: {
  params: Promise<{ essayId: string; attemptId: string }>;
}) {
  const { essayId, attemptId } = await params;
  const attempt = await getAttemptView(attemptId);
  if (!attempt || attempt.essayId !== essayId) notFound();

  if (attempt.status !== "en_curso") {
    redirect(`/ensayos/${essayId}/resultado/${attemptId}`);
  }

  return (
    <main className="mx-auto flex w-full max-w-xl flex-col gap-4 px-4 py-8 sm:px-6 sm:py-12">
      <EssayAttemptForm attempt={attempt} />
    </main>
  );
}
