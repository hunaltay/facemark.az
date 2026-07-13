-- ============================================================
-- Facemark.az — Supabase sxemi (v1)
-- Bu fayl butun cedvelleri, RLS qaydalarini ve trigger-leri yaradir.
-- Supabase SQL Editor-da veya migration olaraq iceri verile biler.
-- ============================================================

create extension if not exists "pgcrypto"; -- gen_random_uuid() ucun

-- ------------------------------------------------------------
-- Umumi: updated_at avtomatik yenilensin
-- ------------------------------------------------------------
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- ------------------------------------------------------------
-- 1) PROFILES — admin/editor istifadecileri (auth.users-e baglidir)
-- ------------------------------------------------------------
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  role text not null default 'editor' check (role in ('admin','editor')),
  created_at timestamptz not null default now(),
  email text
);

-- Yeni auth.users qeydiyyatinda avtomatik profil yaratmaq
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, new.raw_user_meta_data ->> 'full_name');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- ------------------------------------------------------------
-- 2) SITE_CONTENT — homepage/about/services/partners/clients/testimonials
--    ucun umumi acar-deyer CMS bloklari (admin panel bunu redakte edir)
-- ------------------------------------------------------------
create table site_content (
  id uuid primary key default gen_random_uuid(),
  section text not null unique,        -- meselen: 'homepage_hero','about_story','services_intro'
  content_az jsonb not null default '{}',
  content_en jsonb not null default '{}',
  updated_by uuid references profiles(id),
  updated_at timestamptz not null default now()
);
create trigger trg_site_content_updated before update on site_content
  for each row execute function set_updated_at();

-- ------------------------------------------------------------
-- 3) EVENTS — 01_homepage ve 02_event_inner_page ucun
-- ------------------------------------------------------------
create table events (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title_az text not null,
  title_en text,
  subtitle_az text,
  subtitle_en text,
  description_az text,
  description_en text,
  status text not null default 'upcoming' check (status in ('active','upcoming','past','partner')),
  is_partner boolean not null default false,
  date_start date,
  date_end date,
  banner_url text,
  external_url text,
  venue text,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create trigger trg_events_updated before update on events
  for each row execute function set_updated_at();

create table event_speakers (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events(id) on delete cascade,
  name text not null,
  title_az text,
  title_en text,
  photo_url text,
  sort_order int not null default 0
);

create table event_program (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events(id) on delete cascade,
  day_label text,
  time_label text,
  title_az text,
  title_en text,
  speaker_name text,
  sort_order int not null default 0
);

create table event_sponsors (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events(id) on delete cascade,
  name text not null,
  logo_url text,
  tier text,
  sort_order int not null default 0
);

create table event_tickets (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events(id) on delete cascade,
  name_az text not null,
  name_en text,
  price numeric,
  currency text not null default 'AZN',
  perks_az text,
  perks_en text,
  is_active boolean not null default true,
  sort_order int not null default 0
);

-- ------------------------------------------------------------
-- 4) PARTNERS / CLIENTS / TESTIMONIALS
-- ------------------------------------------------------------
create table partners (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  logo_url text,
  website_url text,
  category text,
  sort_order int not null default 0
);

create table clients (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  logo_url text,
  sort_order int not null default 0
);

create table testimonials (
  id uuid primary key default gen_random_uuid(),
  author_name text not null,
  author_role text,
  author_company text,
  quote_az text,
  quote_en text,
  avatar_url text,
  sort_order int not null default 0
);

-- ------------------------------------------------------------
-- 5) TEAM / CAREERS (07_team, 08_careers)
-- ------------------------------------------------------------
create table team_members (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  role_az text,
  role_en text,
  photo_url text,
  bio_az text,
  bio_en text,
  linkedin_url text,
  sort_order int not null default 0
);

create table job_openings (
  id uuid primary key default gen_random_uuid(),
  title_az text not null,
  title_en text,
  department text,
  location text,
  employment_type text,
  description_az text,
  description_en text,
  is_active boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 6) APPLICATIONS — butun formalar (career apply, team apply,
--    homepage muraciet modali, sponsorluq) bir cedvelde
-- ------------------------------------------------------------
create table applications (
  id uuid primary key default gen_random_uuid(),
  form_type text not null check (form_type in ('career','team','contact','sponsorship','partner','subscribe')),
  full_name text not null,
  email text,
  phone text,
  subject text,
  message text,
  job_id uuid references job_openings(id),
  cv_url text,
  status text not null default 'new' check (status in ('new','reviewed','archived')),
  created_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 7) NEWS / TV / MARKETING AIR (03, 04, 05)
-- ------------------------------------------------------------
create table news_items (
  id uuid primary key default gen_random_uuid(),
  title_az text not null,
  title_en text,
  chip_label text,
  url text,
  published_at timestamptz not null default now(),
  is_active boolean not null default true,
  sort_order int not null default 0
);

create table tv_videos (
  id uuid primary key default gen_random_uuid(),
  title_az text not null,
  title_en text,
  category text,
  video_url text,
  thumbnail_url text,
  published_at timestamptz not null default now(),
  sort_order int not null default 0
);

create table air_programs (
  id uuid primary key default gen_random_uuid(),
  title_az text not null,
  title_en text,
  description_az text,
  description_en text,
  sort_order int not null default 0
);

create table air_trainers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  role_az text,
  role_en text,
  photo_url text,
  bio_az text,
  bio_en text,
  sort_order int not null default 0
);

-- ------------------------------------------------------------
-- 8) ACTIVITY LOG — admin panelde "Fealiyyet loqu"
-- ------------------------------------------------------------
create table activity_log (
  id uuid primary key default gen_random_uuid(),
  admin_id uuid references profiles(id),
  action text not null,
  meta jsonb,
  created_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 9) NOTIFICATIONS — admin panelde "Bildirisler" paneli
-- ------------------------------------------------------------
create table notifications (
  id uuid primary key default gen_random_uuid(),
  type text not null,
  title text not null,
  body text,
  link text,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

-- Yeni muraciet (applications) daxil olanda avtomatik bildiris yaradir
create or replace function notify_new_application()
returns trigger as $$
begin
  insert into public.notifications(type, title, body, link)
  values (
    'application',
    case new.form_type
      when 'career' then 'Yeni karyera müraciəti'
      when 'team' then 'Yeni komanda müraciəti'
      when 'sponsorship' then 'Yeni sponsorluq müraciəti'
      when 'partner' then 'Yeni partnyorluq müraciəti'
      when 'contact' then 'Yeni əlaqə mesajı'
      when 'subscribe' then 'Yeni abunəçi'
      else 'Yeni müraciət'
    end,
    trim(both ' — ' from coalesce(new.full_name,'') || case when new.email is not null then ' — ' || new.email else '' end),
    '#inquiries'
  );
  return new;
end;
$$ language plpgsql security definer set search_path = public;

create trigger trg_notify_new_application
  after insert on applications
  for each row execute function notify_new_application();

-- ============================================================
-- RLS — hamisinda aktiv edirik
-- ============================================================
alter table profiles enable row level security;
alter table site_content enable row level security;
alter table events enable row level security;
alter table event_speakers enable row level security;
alter table event_program enable row level security;
alter table event_sponsors enable row level security;
alter table event_tickets enable row level security;
alter table partners enable row level security;
alter table clients enable row level security;
alter table testimonials enable row level security;
alter table team_members enable row level security;
alter table job_openings enable row level security;
alter table applications enable row level security;
alter table news_items enable row level security;
alter table tv_videos enable row level security;
alter table air_programs enable row level security;
alter table air_trainers enable row level security;
alter table activity_log enable row level security;
alter table notifications enable row level security;

-- Komekci: cari istifadecinin admin/editor olub-olmadigini yoxlamaq
create or replace function is_staff()
returns boolean as $$
  select exists (select 1 from profiles where id = auth.uid());
$$ language sql stable security definer;

-- Public (anon) OXUMA — sayti gezen her kes gore bilsin
create policy "public read" on site_content for select using (true);
create policy "public read" on events for select using (true);
create policy "public read" on event_speakers for select using (true);
create policy "public read" on event_program for select using (true);
create policy "public read" on event_sponsors for select using (true);
create policy "public read active tickets" on event_tickets for select using (is_active = true);
create policy "public read" on partners for select using (true);
create policy "public read" on clients for select using (true);
create policy "public read" on testimonials for select using (true);
create policy "public read" on team_members for select using (true);
create policy "public read active jobs" on job_openings for select using (is_active = true);
create policy "public read active news" on news_items for select using (is_active = true);
create policy "public read" on tv_videos for select using (true);
create policy "public read" on air_programs for select using (true);
create policy "public read" on air_trainers for select using (true);

-- Public INSERT — formalar (career/team/contact/sponsorship)
create policy "public insert" on applications for insert with check (true);

-- Staff (admin/editor) — hamisina tam CRUD
create policy "staff full access" on profiles for all using (is_staff()) with check (is_staff());
create policy "staff write" on site_content for all using (is_staff()) with check (is_staff());
create policy "staff write" on events for all using (is_staff()) with check (is_staff());
create policy "staff write" on event_speakers for all using (is_staff()) with check (is_staff());
create policy "staff write" on event_program for all using (is_staff()) with check (is_staff());
create policy "staff write" on event_sponsors for all using (is_staff()) with check (is_staff());
create policy "staff write" on event_tickets for all using (is_staff()) with check (is_staff());
create policy "staff write" on partners for all using (is_staff()) with check (is_staff());
create policy "staff write" on clients for all using (is_staff()) with check (is_staff());
create policy "staff write" on testimonials for all using (is_staff()) with check (is_staff());
create policy "staff write" on team_members for all using (is_staff()) with check (is_staff());
create policy "staff write" on job_openings for all using (is_staff()) with check (is_staff());
create policy "staff read/update applications" on applications for select using (is_staff());
create policy "staff update applications" on applications for update using (is_staff()) with check (is_staff());
create policy "staff write" on news_items for all using (is_staff()) with check (is_staff());
create policy "staff write" on tv_videos for all using (is_staff()) with check (is_staff());
create policy "staff write" on air_programs for all using (is_staff()) with check (is_staff());
create policy "staff write" on air_trainers for all using (is_staff()) with check (is_staff());
create policy "staff read log" on activity_log for select using (is_staff());
create policy "staff insert log" on activity_log for insert with check (is_staff());
create policy "staff read" on notifications for select using (is_staff());
create policy "staff update" on notifications for update using (is_staff()) with check (is_staff());
create policy "staff insert" on notifications for insert with check (is_staff());
