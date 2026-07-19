import { getLeads } from "@/lib/data/leads";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

/** Formatea la fecha de registro en formato chileno (día, mes y hora). */
function formatCreatedAt(value: string) {
  return new Intl.DateTimeFormat("es-CL", {
    dateStyle: "long",
    timeStyle: "short",
  }).format(new Date(value));
}

export default async function LeadsPage() {
  const leads = await getLeads();

  return (
    <main className="mx-auto flex max-w-4xl flex-col gap-6 px-6 py-12">
      <header>
        <h1 className="font-heading text-xl font-semibold text-foreground">
          Interesados
        </h1>
        <p className="mt-1 text-sm text-muted-foreground">
          Personas que dejaron sus datos en el formulario de la página
          pública. Este listado es solo de lectura.
        </p>
      </header>

      <Card>
        <CardHeader>
          <CardTitle>Registros recientes</CardTitle>
        </CardHeader>
        <CardContent>
          {leads.length === 0 ? (
            <p className="py-4 text-sm text-muted-foreground">
              Aún no hay interesados registrados.
            </p>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full min-w-[720px] border-collapse text-sm">
                <thead>
                  <tr className="border-b border-border text-left">
                    <th className="py-2 pr-4">Nombre</th>
                    <th className="py-2 pr-4">Edad</th>
                    <th className="py-2 pr-4">Correo</th>
                    <th className="py-2 pr-4">Teléfono</th>
                    <th className="py-2 pr-4">Región</th>
                    <th className="py-2 pr-4">Nivel de interés</th>
                    <th className="py-2 pr-4">Fecha</th>
                    <th className="py-2 pr-4">Consentimiento</th>
                  </tr>
                </thead>
                <tbody>
                  {leads.map((lead) => (
                    <tr key={lead.id} className="border-b border-border/50">
                      <td className="py-2 pr-4">{lead.name}</td>
                      <td className="py-2 pr-4">{lead.age}</td>
                      <td className="py-2 pr-4">{lead.email}</td>
                      <td className="py-2 pr-4">{lead.phone}</td>
                      <td className="py-2 pr-4">{lead.region}</td>
                      <td className="py-2 pr-4">{lead.level}</td>
                      <td className="py-2 pr-4 whitespace-nowrap">
                        {formatCreatedAt(lead.createdAt)}
                      </td>
                      <td className="py-2 pr-4">
                        {lead.consentComplete ? (
                          <Badge variant="success">Completo</Badge>
                        ) : (
                          <Badge variant="warning">Incompleto</Badge>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </CardContent>
      </Card>
    </main>
  );
}
