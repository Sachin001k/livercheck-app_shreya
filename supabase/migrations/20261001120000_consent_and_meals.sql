-- LivrCheck — migration 5: user consent and meal details.
--
-- How to apply: Supabase dashboard → SQL Editor → New query → paste this
-- whole file → Run. Run migrations 1–4 first. Safe to run more than once.

-- When the user agreed to the terms, and which version they saw. The app
-- asks again if consent_version is older than the current one.
alter table public.profiles add column if not exists consent_at timestamptz;
alter table public.profiles add column if not exists consent_version text;

-- Foods picked in the daily log's meal picker, e.g. {"roti": 3, "dal": 1}.
-- The calories column still holds the total.
alter table public.daily_checkins add column if not exists meals jsonb;
