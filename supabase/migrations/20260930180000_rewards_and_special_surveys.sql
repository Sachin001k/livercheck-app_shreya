-- LivrCheck — migration 4: reward rules, server-checked coins, special surveys.
--
-- How to apply: Supabase dashboard → SQL Editor → New query → paste this
-- whole file → Run. Run migrations 1–3 first. Safe to run more than once.
--
-- What this adds
--   reward_rules              one row per way to earn coins (edit amounts here)
--   coin_events (changed)     amount is now set and checked by the server
--   special_surveys           surveys you announce later, each with its own reward
--   special_survey_responses  users' answers to those surveys
--   coin_balances (view)      each user's total coins, split by source
--
-- To add a new way to earn coins later: insert a row into reward_rules and
-- add its check to award_coins() below.

-- ─────────────────────────────────────────────────────────────────────────
-- reward_rules
-- ─────────────────────────────────────────────────────────────────────────
create table if not exists public.reward_rules (
  reason      text primary key,
  amount      int  not null check (amount >= 0),
  description text not null,
  active      boolean not null default true
);

insert into public.reward_rules (reason, amount, description) values
  ('checkin',        1,  'Tapped Check in on the Home page (once a day)'),
  ('daily_log',      10, 'Filled in the daily health log (once a day)'),
  ('daily_bonus',    20, 'Daily log scored 90 or more (once a day)'),
  ('special_survey', 0,  'Completed a special survey (amount comes from the survey)')
on conflict (reason) do update
  set description = excluded.description;

alter table public.reward_rules enable row level security;

drop policy if exists "reward_rules: anyone signed in can read" on public.reward_rules;
create policy "reward_rules: anyone signed in can read" on public.reward_rules
  for select to authenticated using (true);

-- ─────────────────────────────────────────────────────────────────────────
-- special_surveys: created by you in the Table Editor (or SQL). `questions`
-- is JSON so each survey can have its own questions.
-- ─────────────────────────────────────────────────────────────────────────
create table if not exists public.special_surveys (
  id           uuid primary key default gen_random_uuid(),
  title        text not null,
  description  text,
  questions    jsonb not null default '[]'::jsonb,
  reward_coins int  not null default 50 check (reward_coins >= 0),
  starts_at    timestamptz not null default now(),
  ends_at      timestamptz,
  is_active    boolean not null default true,
  created_at   timestamptz not null default now()
);

alter table public.special_surveys enable row level security;

drop policy if exists "special_surveys: read live ones" on public.special_surveys;
create policy "special_surveys: read live ones" on public.special_surveys
  for select to authenticated
  using (is_active and starts_at <= now() and (ends_at is null or ends_at > now()));

create table if not exists public.special_survey_responses (
  id         uuid primary key default gen_random_uuid(),
  survey_id  uuid not null references public.special_surveys (id) on delete cascade,
  user_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  answers    jsonb not null,
  created_at timestamptz not null default now(),
  unique (survey_id, user_id)
);

alter table public.special_survey_responses enable row level security;

drop policy if exists "special_survey_responses: read own" on public.special_survey_responses;
create policy "special_survey_responses: read own" on public.special_survey_responses
  for select using ((select auth.uid()) = user_id);

drop policy if exists "special_survey_responses: insert own" on public.special_survey_responses;
create policy "special_survey_responses: insert own" on public.special_survey_responses
  for insert with check ((select auth.uid()) = user_id);

-- ─────────────────────────────────────────────────────────────────────────
-- coin_events: generalise for special surveys and let the server set the
-- amount. Day-based rewards stay unique per day; special surveys are
-- unique per survey.
-- ─────────────────────────────────────────────────────────────────────────
alter table public.coin_events add column if not exists ref_id uuid;
alter table public.coin_events alter column day drop not null;
alter table public.coin_events drop constraint if exists coin_events_check;
alter table public.coin_events drop constraint if exists coin_events_reason_check;
alter table public.coin_events drop constraint if exists coin_events_reason_fkey;
alter table public.coin_events
  add constraint coin_events_reason_fkey foreign key (reason) references public.reward_rules (reason);

create unique index if not exists coin_events_special_survey_once
  on public.coin_events (user_id, ref_id) where reason = 'special_survey';

-- Runs before every coin insert: sets the amount from the rules and refuses
-- rewards that weren't actually earned.
create or replace function public.award_coins()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  rule public.reward_rules%rowtype;
begin
  select * into rule from public.reward_rules where reason = new.reason and active;
  if not found then
    raise exception 'No active reward for %', new.reason;
  end if;

  if new.reason = 'special_survey' then
    select s.reward_coins into new.amount
      from public.special_surveys s
     where s.id = new.ref_id
       and s.is_active and s.starts_at <= now()
       and (s.ends_at is null or s.ends_at > now());
    if not found then
      raise exception 'That survey is not open';
    end if;
    if not exists (select 1 from public.special_survey_responses r
                    where r.survey_id = new.ref_id and r.user_id = new.user_id) then
      raise exception 'Answer the survey first';
    end if;
    new.day := null;
  else
    -- Day-based rewards: only for about today (allowing for time zones).
    if new.day is null or new.day not between current_date - 1 and current_date + 1 then
      raise exception 'Rewards can only be claimed for today';
    end if;
    new.amount := rule.amount;

    if new.reason = 'checkin' and not exists (
         select 1 from public.daily_checkins c
          where c.user_id = new.user_id and c.day = new.day) then
      raise exception 'Check in first';
    end if;
    if new.reason = 'daily_log' and not exists (
         select 1 from public.daily_checkins c
          where c.user_id = new.user_id and c.day = new.day and c.logged_at is not null) then
      raise exception 'Save the daily log first';
    end if;
    if new.reason = 'daily_bonus' and not exists (
         select 1 from public.daily_checkins c
          where c.user_id = new.user_id and c.day = new.day and c.score >= 90) then
      raise exception 'The bonus needs a daily score of 90 or more';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists coin_events_award on public.coin_events;
create trigger coin_events_award
  before insert on public.coin_events
  for each row execute function public.award_coins();

-- ─────────────────────────────────────────────────────────────────────────
-- coin_balances: totals per user, split by source. Handy in the Table
-- Editor; each user can only see their own row.
-- ─────────────────────────────────────────────────────────────────────────
create or replace view public.coin_balances
with (security_invoker = true) as
select
  user_id,
  coalesce(sum(amount), 0)::int                                        as total,
  coalesce(sum(amount) filter (where reason = 'checkin'), 0)::int        as from_checkins,
  coalesce(sum(amount) filter (where reason = 'daily_log'), 0)::int      as from_daily_logs,
  coalesce(sum(amount) filter (where reason = 'daily_bonus'), 0)::int    as from_bonuses,
  coalesce(sum(amount) filter (where reason = 'special_survey'), 0)::int as from_special_surveys
from public.coin_events
group by user_id;
