-- LivrCheck — migration 1: initial schema.
--
-- How to apply: Supabase dashboard → SQL Editor → New query → paste this
-- whole file → Run. It is safe to run more than once.
--
-- After running, check Table Editor: you should see profiles, assessments,
-- daily_activity and survey_responses. Every new sign-up then gets a row in
-- `profiles` automatically (name + email).
--
-- Every table has Row Level Security (RLS) on, so a signed-in user can only
-- ever read and write their own rows — even though the app ships with the
-- public anon key.

-- ─────────────────────────────────────────────────────────────────────────
-- profiles: one row per user, created automatically on sign-up.
-- ─────────────────────────────────────────────────────────────────────────
create table if not exists public.profiles (
  id                 uuid primary key references auth.users (id) on delete cascade,
  email              text,
  phone              text,
  full_name          text,
  age                int check (age between 1 and 120),
  gender             text check (gender in ('male', 'female', 'other', 'prefer_not')),
  height_cm          numeric check (height_cm > 0),
  weight_kg          numeric check (weight_kg > 0),
  preferred_language text not null default 'en',
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "profiles: read own" on public.profiles;
create policy "profiles: read own" on public.profiles
  for select using ((select auth.uid()) = id);

drop policy if exists "profiles: insert own" on public.profiles;
create policy "profiles: insert own" on public.profiles
  for insert with check ((select auth.uid()) = id);

drop policy if exists "profiles: update own" on public.profiles;
create policy "profiles: update own" on public.profiles
  for update using ((select auth.uid()) = id);

-- Older copies of this file had no email/phone columns.
alter table public.profiles add column if not exists email text;
alter table public.profiles add column if not exists phone text;

-- Create a profile whenever a new user signs up, copying their email/phone
-- and the name entered on the sign-up form (or from Google).
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, email, phone, full_name)
  values (
    new.id,
    new.email,
    new.phone,
    coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Keep profiles.email / phone in sync if the user changes them.
create or replace function public.handle_user_contact_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.profiles
     set email = new.email, phone = new.phone, updated_at = now()
   where id = new.id;
  return new;
end;
$$;

drop trigger if exists on_auth_user_contact_changed on auth.users;
create trigger on_auth_user_contact_changed
  after update of email, phone on auth.users
  for each row execute function public.handle_user_contact_change();

-- Accounts created before this migration ran get a profile too.
insert into public.profiles (id, email, phone, full_name)
select u.id,
       u.email,
       u.phone,
       coalesce(u.raw_user_meta_data ->> 'full_name', u.raw_user_meta_data ->> 'name')
  from auth.users u
on conflict (id) do update
  set email = excluded.email,
      phone = excluded.phone,
      full_name = coalesce(public.profiles.full_name, excluded.full_name);

-- ─────────────────────────────────────────────────────────────────────────
-- assessments: every FIB-4 check a user runs.
-- ─────────────────────────────────────────────────────────────────────────
create table if not exists public.assessments (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null default auth.uid() references auth.users (id) on delete cascade,
  age            numeric not null,
  ast            numeric not null,
  alt            numeric not null,
  platelets      numeric not null,
  fib4_score     numeric not null,
  risk_tier      text not null check (risk_tier in ('low', 'intermediate', 'high')),
  height_cm      numeric,
  weight_kg      numeric,
  bmi            numeric,
  has_diabetes   text check (has_diabetes in ('yes', 'no', 'notSure')),
  family_history text check (family_history in ('yes', 'no', 'notSure')),
  created_at     timestamptz not null default now()
);

create index if not exists assessments_user_created_idx
  on public.assessments (user_id, created_at desc);

alter table public.assessments enable row level security;

drop policy if exists "assessments: read own" on public.assessments;
create policy "assessments: read own" on public.assessments
  for select using ((select auth.uid()) = user_id);

drop policy if exists "assessments: insert own" on public.assessments;
create policy "assessments: insert own" on public.assessments
  for insert with check ((select auth.uid()) = user_id);

drop policy if exists "assessments: delete own" on public.assessments;
create policy "assessments: delete own" on public.assessments
  for delete using ((select auth.uid()) = user_id);

-- ─────────────────────────────────────────────────────────────────────────
-- daily_activity: one row per user per day they opened the app. Powers the
-- streak and the activity grid on the profile screen.
-- ─────────────────────────────────────────────────────────────────────────
create table if not exists public.daily_activity (
  user_id       uuid not null default auth.uid() references auth.users (id) on delete cascade,
  activity_date date not null,
  primary key (user_id, activity_date)
);

alter table public.daily_activity enable row level security;

drop policy if exists "daily_activity: read own" on public.daily_activity;
create policy "daily_activity: read own" on public.daily_activity
  for select using ((select auth.uid()) = user_id);

drop policy if exists "daily_activity: insert own" on public.daily_activity;
create policy "daily_activity: insert own" on public.daily_activity
  for insert with check ((select auth.uid()) = user_id);

-- ─────────────────────────────────────────────────────────────────────────
-- survey_responses: ready for the upcoming survey. `answers` is JSON so the
-- questions can change without a schema change; bump `survey_version` when
-- they do.
-- ─────────────────────────────────────────────────────────────────────────
create table if not exists public.survey_responses (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null default auth.uid() references auth.users (id) on delete cascade,
  survey_version text not null default 'v1',
  answers        jsonb not null,
  score          numeric,
  created_at     timestamptz not null default now()
);

create index if not exists survey_responses_user_created_idx
  on public.survey_responses (user_id, created_at desc);

alter table public.survey_responses enable row level security;

drop policy if exists "survey_responses: read own" on public.survey_responses;
create policy "survey_responses: read own" on public.survey_responses
  for select using ((select auth.uid()) = user_id);

drop policy if exists "survey_responses: insert own" on public.survey_responses;
create policy "survey_responses: insert own" on public.survey_responses
  for insert with check ((select auth.uid()) = user_id);
