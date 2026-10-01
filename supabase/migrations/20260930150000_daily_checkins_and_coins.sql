-- LivrCheck — migration 3: daily check-in log and coins.
--
-- How to apply: Supabase dashboard → SQL Editor → New query → paste this
-- whole file → Run. Run migrations 1 and 2 first. Safe to run more than once.

-- ─────────────────────────────────────────────────────────────────────────
-- daily_checkins: one row per user per day with that day's log (water,
-- food, exercise…) and the score it earned. A row with no log yet means
-- the user only tapped "Check in".
-- ─────────────────────────────────────────────────────────────────────────
create table if not exists public.daily_checkins (
  user_id        uuid not null default auth.uid() references auth.users (id) on delete cascade,
  day            date not null,
  water_ml       int  check (water_ml between 0 and 10000),
  calories       int  check (calories between 0 and 10000),
  exercise_min   int  check (exercise_min between 0 and 600),
  steps          int  check (steps between 0 and 100000),
  sleep_hours    numeric check (sleep_hours between 0 and 24),
  fruit_veg      int  check (fruit_veg between 0 and 30),
  sugary_items   int  check (sugary_items between 0 and 30),
  score          int  check (score between 0 and 100),
  logged_at      timestamptz,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  primary key (user_id, day)
);

alter table public.daily_checkins enable row level security;

drop policy if exists "daily_checkins: read own" on public.daily_checkins;
create policy "daily_checkins: read own" on public.daily_checkins
  for select using ((select auth.uid()) = user_id);

drop policy if exists "daily_checkins: insert own" on public.daily_checkins;
create policy "daily_checkins: insert own" on public.daily_checkins
  for insert with check ((select auth.uid()) = user_id);

drop policy if exists "daily_checkins: update own" on public.daily_checkins;
create policy "daily_checkins: update own" on public.daily_checkins
  for update using ((select auth.uid()) = user_id);

-- ─────────────────────────────────────────────────────────────────────────
-- coin_events: every coin a user earns. The balance is the sum of amount.
-- The unique key means each reward can only be earned once per day, and
-- the check fixes the amount per reason, so the app can't over-award.
--   checkin       +1   tapped "Check in" today
--   daily_log     +10  filled in today's log
--   daily_bonus   +20  today's log scored 90 or more
-- ─────────────────────────────────────────────────────────────────────────
create table if not exists public.coin_events (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  day        date not null,
  reason     text not null check (reason in ('checkin', 'daily_log', 'daily_bonus')),
  amount     int  not null,
  created_at timestamptz not null default now(),
  unique (user_id, day, reason),
  check (
    (reason = 'checkin'     and amount = 1)  or
    (reason = 'daily_log'   and amount = 10) or
    (reason = 'daily_bonus' and amount = 20)
  )
);

alter table public.coin_events enable row level security;

drop policy if exists "coin_events: read own" on public.coin_events;
create policy "coin_events: read own" on public.coin_events
  for select using ((select auth.uid()) = user_id);

drop policy if exists "coin_events: insert own" on public.coin_events;
create policy "coin_events: insert own" on public.coin_events
  for insert with check ((select auth.uid()) = user_id);
