// Facemark.az — Supabase paylaşılan client
// Bu fayl bütün səhifələrdə <script src="assets/supabase-client.js"> ilə
// supabase-js kitabxanasından SONRA yüklənməlidir:
// <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.js"></script>
// <script src="assets/supabase-client.js"></script>

const SUPABASE_URL = 'https://ocgjaksvfxtufwgmdzys.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_a2t9kIjDYZ6qhqw7bMNvjw_zuQGsaLh';

const supabaseGlobal = (typeof window !== 'undefined' && window.supabase)
  || (typeof globalThis !== 'undefined' && globalThis.supabase)
  || (typeof supabase !== 'undefined' && supabase)
  || null;

if (!supabaseGlobal) {
  console.warn('Supabase global not found. Check that the UMD script loaded before assets/supabase-client.js.');
}

const supabaseClient = supabaseGlobal
  ? supabaseGlobal.createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
  : null;

if (typeof window !== 'undefined') {
  window.supabaseClient = supabaseClient;
}
if (typeof globalThis !== 'undefined') {
  globalThis.supabaseClient = supabaseClient;
}

// Kömekçi: applications cədvəlinə müraciət yazmaq
async function submitApplication(payload) {
  if (!supabaseClient) throw new Error('Supabase client is not initialized.');
  const { data, error } = await supabaseClient
    .from('applications')
    .insert([payload])
    .select()
    .single();
  if (error) throw error;
  return data;
}
