// Facemark.az — Supabase paylaşılan client
// Bu fayl bütün səhifələrdə <script src="assets/supabase-client.js"> ilə
// supabase-js kitabxanasından SONRA yüklənməlidir:
// <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.js"></script>
// <script src="assets/supabase-client.js"></script>

const SUPABASE_URL = 'https://ocgjaksvfxtufwgmdzys.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_a2t9kIjDYZ6qhqw7bMNvjw_zuQGsaLh';

const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Kömekçi: applications cədvəlinə müraciət yazmaq
async function submitApplication(payload) {
  const { data, error } = await supabaseClient
    .from('applications')
    .insert([payload])
    .select()
    .single();
  if (error) throw error;
  return data;
}
