-- LivrCheck — migration 6: let users delete their own account.
--
-- How to apply: Supabase dashboard → SQL Editor → New query → paste this
-- whole file → Run. Run migrations 1–5 first. Safe to run more than once.
--
-- The app calls this with supabase.rpc('delete_my_account'). It deletes the
-- signed-in user from auth.users; every LivrCheck table references
-- auth.users with ON DELETE CASCADE, so all of their rows go with it:
-- profiles, assessments, survey_responses, daily_checkins, coin_events,
-- daily_activity, daily_habits, special_survey_responses.

create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'Not signed in';
  end if;
  delete from auth.users where id = uid;
end;
$$;

-- Only signed-in users may call it, and it only ever deletes themselves.
revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
