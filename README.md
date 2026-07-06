# Facemark Saytı — Production Hazırlığı

Bu qovluqda saytın mockup versiyası var. `01_homepage.html`, `02_event_inner_page.html`, `03_business_radar.html`, `04_fmr_tv.html`, `05_marketing_air.html`, `06_about.html`, `07_team.html`, `08_careers.html` və `admin_panel.html` statik HTML səhifələr kimi işləyir.

## Ən asan yol — statik hostinq

1. `index.html` faylı artıq əlavə edilib və `01_homepage.html`-ə yönləndirir.
2. Bu qovluğu birbaşa Netlify, Vercel, Cloudflare Pages, GitHub Pages və ya hər hansı digər statik hostinqə yükləyə bilərsiniz.
3. Hostinq `index.html`-i avtomatik açacaq, sonra sizi `01_homepage.html`-ə yönləndirəcək.

### Statik hostinq üçün sadə addımlar

- GitHub Pages:
  - Repo kökündə `index.html` varsa, sayt `https://<istifadəçi>.github.io/<repo>/` ünvanında açılacaq.
- Netlify / Vercel / Cloudflare Pages:
  - Bu qovluğu deploy edin.
  - Build və ya çıxış barədə heç bir əlavə konfiqurasiya olmadan işləməlidir.

- GitHub Pages üçün:
  - Bu qovluğun GitHub repo kökündə `index.html` olmalıdır.
  - `.nojekyll` faylı əlavə edildi, beləliklə GitHub Pages Jekyll filtrləməsini keçəcək.
  - Repo-nu GitHub-a push etdikdən sonra `Settings -> Pages`-də `main` branch və `root` mənbə seçin.

## Dinamik backend və forma bağlantısı

Bu layihəyə artıq local backend əlavə edilmişdir. `backend/server.js` Node/Express serveridir və `POST /api/applications` endpoint-i vasitəsilə `07_team.html` və `08_careers.html` formalarını qəbul etməyə hazırdır.

### Local backend üçün quraşdırma

1. `cd backend`
2. `npm install`
3. `npm start`
4. Formalar `http://localhost:4000/api/applications` ünvanına göndərilir.

### Supabase və ya real prod üçün

- Əgər Supabase istifadə etmək istəyirsinizsə, `backend/schema.sql`-i Supabase layihəsinə tətbiq edin.
- Sonra HTML formalarını həmin layihənin API endpoint-lərinə uyğunlaşdırın.
- `admin_panel.html`-i Supabase Auth və ya başqa server auth mexanizmi ilə qorumaq lazım olacaq.

## Növbəti təklif

- Əgər `07_team.html` və `08_careers.html` fayllarında formalar varsa, onları Supabase-ə bağlamaq üçün JavaScript kodu əlavə etmək lazımdır.
- Saytın real prod sisteminə çıxması üçün `index.html`-in olması yaxşıdır; bu artıq yerinə yetirildi.

## Qeyd

Bu qovluq hələ layihənin bütün dinamik tələblərini tam qarşılamır. Statik hosting üçün tam uyğundur, amma real “production” istifadə üçün backend inteqrasiyası və forma/administrator təhlükəsizliyi tamamlanmalıdır.
