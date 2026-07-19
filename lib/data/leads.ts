"use server";

import { createClient } from "@/lib/supabase/server";

export type LeadFormState = { error: string } | { success: true } | null;

export async function submitLead(
  _prevState: LeadFormState,
  formData: FormData
): Promise<LeadFormState> {
  const name = String(formData.get("name") ?? "").trim();
  const age = Number(formData.get("age"));
  const email = String(formData.get("email") ?? "").trim();
  const phone = String(formData.get("phone") ?? "").trim();
  const region = String(formData.get("region") ?? "").trim();
  const level = String(formData.get("level") ?? "").trim();
  const consentData = formData.get("consent-data") === "on";
  const consentGuardian = formData.get("consent-guardian") === "on";

  if (
    !name ||
    !email ||
    !phone ||
    !region ||
    !level ||
    !Number.isFinite(age) ||
    age < 12 ||
    age > 99
  ) {
    return { error: "Revisa que todos los campos estén completos." };
  }
  if (!consentData || !consentGuardian) {
    return { error: "Debes aceptar ambas autorizaciones para continuar." };
  }

  const supabase = await createClient();
  const { error } = await supabase.from("leads").insert({
    name,
    age,
    email,
    phone,
    region,
    level,
    consent_data: consentData,
    consent_guardian: consentGuardian,
  });

  if (error) {
    return { error: "No pudimos enviar tus datos. Intenta nuevamente en unos minutos." };
  }
  return { success: true };
}

export type LeadRow = {
  id: string;
  name: string;
  age: number;
  email: string;
  phone: string;
  region: string;
  level: string;
  consentComplete: boolean;
  createdAt: string;
};

/**
 * Lista de interesados registrados en el formulario público de la landing.
 * Solo lectura: pensada para el panel administrativo (protegido por RLS con
 * `is_admin()` y por el layout de /admin). No expone estos datos a
 * componentes cliente ni los registra en consola.
 */
export async function getLeads(): Promise<LeadRow[]> {
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("leads")
    .select(
      "id, name, age, email, phone, region, level, consent_data, consent_guardian, created_at"
    )
    .order("created_at", { ascending: false });

  if (error || !data) {
    return [];
  }

  return data.map((lead) => ({
    id: lead.id,
    name: lead.name,
    age: lead.age,
    email: lead.email,
    phone: lead.phone,
    region: lead.region,
    level: lead.level,
    consentComplete: lead.consent_data === true && lead.consent_guardian === true,
    createdAt: lead.created_at,
  }));
}
