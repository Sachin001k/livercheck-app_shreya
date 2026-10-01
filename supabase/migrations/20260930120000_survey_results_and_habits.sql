-- LivrCheck — migration 2: health check results and daily habits.
--
-- How to apply: Supabase dashboard → SQL Editor → New query → paste this
-- whole file → Run. Run migration 1 first. Safe to run more than once.

-- ─────────────────────────────────────────────────────────────────────────
-- survey_responses: keep the full result so past checks can be reopened.
-- ─────────────────────────────────────────────────────────────────────────
alter table public.survey_responses add column if not exists tier text;
alter table public.survey_responses add column if not exists result jsonb;

drop policy if exists "survey_responses: delete own" on public.survey_responses;
create policy "survey_responses: delete own" on public.survey_responses
  for delete using ((select auth.uid()) = user_id);

-- ─────────────────────────────────────────────────────────────────────────
-- daily_habits: which healthy habits the user ticked on each day. Powers
-- the streak (3+ habits = a streak day), XP and the activity grid.
-- ─────────────────────────────────────────────────────────────────────────
create table if not exists public.daily_habits (
  user_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  day        date not null,
  habits     text[] not null default '{}',
  updated_at timestamptz not null default now(),
  primary key (user_id, day)
);

alter table public.daily_habits enable row level security;

drop policy if exists "daily_habits: read own" on public.daily_habits;
create policy "daily_habits: read own" on public.daily_habits
  for select using ((select auth.uid()) = user_id);

drop policy if exists "daily_habits: insert own" on public.daily_habits;
create policy "daily_habits: insert own" on public.daily_habits
  for insert with check ((select auth.uid()) = user_id);

drop policy if exists "daily_habits: update own" on public.daily_habits;
create policy "daily_habits: update own" on public.daily_habits
  for update using ((select auth.uid()) = user_id);
