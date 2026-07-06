# Facemark.az — Backend (Node.js, Supabase-siz)

## Vəziyyət
Tam işlək, vahid (frontend + backend eyni serverdə) Node/Express backend. Xarici servisə (Supabase və s.) ehtiyac yoxdur — verilənlər lokal `data.json` faylında saxlanılır, CV faylları `uploads/`-da. Test edilib, işləyir.

## Fayllar
- `server.js` — Express server: həm statik HTML səhifələrini (`../`) serverə verir, həm də `/api/*` endpoint-lərini işlədir. Eyni port, eyni origin — CORS problemi yoxdur.
- `package.json` — asılılıqlar (express, cors, multer).
- `data.json` — müraciətlərin saxlandığı fayl (avtomatik yaranır, git-ə əlavə olunmur).
- `uploads/` — yüklənən CV faylları (avtomatik yaranır).
- `schema.sql` — əvvəlki Supabase planı üçün sxem (hazırda istifadə olunmur, referans üçün saxlanılıb).

## İşə salmaq
```
cd backend
npm install
npm start
```
Server `http://localhost:4000`-də açılır və eyni zamanda bütün HTML səhifələrini (`http://localhost:4000/01_homepage.html` və s.) də verir.

## API
- `GET /api/health` — server statusu.
- `POST /api/applications` (`multipart/form-data`) — iş müraciətini qəbul edir:
  `form_type` (career/team), `first_name`, `last_name`, `email`, `phone`, `direction`, `message`, `linkedin` (optional), `cv` (fayl, optional).

## Bağlı səhifələr
`07_team.html` və `08_careers.html`-dəki formalar artıq bu API-yə bağlıdır (`http://localhost:4000/api/applications` lokal backend ünvanı ilə).

## Deploy
Bu server Node.js dəstəkləyən bir hostinq tələb edir (Hostinger-in "Node.js App" funksiyası olan planları, və ya bir VPS). Deploy addımları:
1. `backend/` və bütün HTML faylları serverə yüklə.
2. Serverdə `npm install --production` işlət.
3. `npm start` (və ya prosesi daimi saxlamaq üçün `pm2 start server.js`).
4. Domeni bu Node prosesinə yönləndir (port 4000, yaxud `PORT` env dəyişəni ilə istənilən port).

## Növbəti addımlar
- Events (tədbirlər), site_content (admin panel redaktəsi) üçün oxşar məntiqlə əlavə endpoint-lər və `data.json`-a bənzər fayllar (və ya real MySQL, Hostinger artıq verir) qurmaq.
- Admin panel-ə sadə login (məsələn sabit istifadəçi/şifrə + sessiya cookie) əlavə etmək.
