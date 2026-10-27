-- LivrCheck — migration 7: integrity fixes.
--
-- How to apply: Supabase dashboard → SQL Editor → New query → paste this
-- whole file → Run. Run migrations 1–6 first. Safe to run more than once.
--
-- What this changes
--   award_coins()          refuses coins for another user (no probing of
--                          other users' check-ins / surveys through errors)
--   daily_checkins         new trigger: day must be about today, a "logged"
--                          row needs at least one item, score kept in 0–100
--   special_surveys        users can still read surveys they answered after
--                          the survey closes (completed list, "Survey star")
--
-- RLS stays on for every table; no policy is loosened beyond the user's
-- own answered surveys.

-- ─────────────────────────────────────────────────────────────────────────
-- award_coins(): same as migration 4, plus the user check at the top.
-- Callers through the API (anon / authenticated) may only award
-- themselves; the SQL editor and service role (admin backfills) are not
-- affected.
-- ─────────────────────────────────────────────────────────────────────────
create or replace function public.award_coins()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  rule public.reward_rules%rowtype;
begin
  if coalesce(auth.role(), '') in ('anon', 'authenticated')
     and new.user_id is distinct from auth.uid() then
    raise exception 'Coins can only be claimed for yourself';
  end if;

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
    -- Known limitation: `score` is computed by the app, so the 90+ bonus
    -- still trusts it (it is only clamped to 0–100 below). Fix by scoring
    -- the day on the server.
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
-- daily_checkins: sanity checks on every write.
--   The app writes (lib/daily/daily_store.dart):
--     check in  → insert {user_id, day = today}            (logged_at null)
--     save log  → upsert today's items, score, meals, logged_at, updated_at
--   Both are for "today" in the user's time zone, which is within
--   current_date ± 1 on the server.
-- ─────────────────────────────────────────────────────────────────────────
create or replace function public.check_daily_checkin()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  -- New rows, and updates that change the day or the logged data, must
  -- be for about today. (Updates that change nothing logged — e.g.
  -- updated_at only — are allowed on older rows.)
  if tg_op = 'INSERT'
     or new.day is distinct from old.day
     or (new.water_ml, new.calories, new.exercise_min, new.steps,
         new.sleep_hours, new.fruit_veg, new.sugary_items, new.score,
         new.logged_at, new.meals)
        is distinct from
        (old.water_ml, old.calories, old.exercise_min, old.steps,
         old.sleep_hours, old.fruit_veg, old.sugary_items, old.score,
         old.logged_at, old.meals) then
    if new.day is null or new.day not between current_date - 1 and current_date + 1 then
      raise exception 'Daily logs can only be saved for today';
    end if;

    -- A saved log must have at least one item filled in (the app only
    -- enables Save when one is).
    if new.logged_at is not null and num_nonnulls(
         new.water_ml, new.calories, new.exercise_min, new.steps,
         new.sleep_hours, new.fruit_veg, new.sugary_items) = 0 then
      raise exception 'A daily log needs at least one item';
    end if;
  end if;

  -- Known limitation: the score is still computed by the app, so the 90+
  -- bonus trusts it; here it is only kept within 0–100.
  if new.score is not null then
    new.score := least(100, greatest(0, new.score));
  end if;
  return new;
end;
$$;

drop trigger if exists daily_checkins_check on public.daily_checkins;
create trigger daily_checkins_check
  before insert or update on public.daily_checkins
  for each row execute function public.check_daily_checkin();

-- ─────────────────────────────────────────────────────────────────────────
-- special_surveys: also let users read surveys they have answered, so the
-- completed list and the "Survey star" badge survive the survey closing.
-- (Policies are OR-ed with "read live ones" from migration 4.)
-- ─────────────────────────────────────────────────────────────────────────
drop policy if exists "special_surveys: read answered ones" on public.special_surveys;
create policy "special_surveys: read answered ones" on public.special_surveys
  for select to authenticated
  using (exists (
    select 1 from public.special_survey_responses r
     where r.survey_id = special_surveys.id
       and r.user_id = (select auth.uid())
  ));
