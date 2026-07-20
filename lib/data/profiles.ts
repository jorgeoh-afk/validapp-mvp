import { createClient } from "@/lib/supabase/server";

export async function getCurrentProfile() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) return null;

  const { data: profile } = await supabase
    .from("profiles")
    .select(
      "id, full_name, role, target_level, student_age_group, target_program_id, target_level_id, target_program:programs(id, name, code, curriculum_type), target_level_detail:levels(id, name, code, equivalence, education_type)"
    )
    .eq("id", user.id)
    .single();

  return profile;
}
