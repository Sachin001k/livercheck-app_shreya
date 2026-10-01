# LivrCheck

A free Flutter app that helps people in India check their risk of liver
fibrosis (scarring) from a routine blood test. It uses the **FIB-4** score,
which needs only age, AST (SGOT), ALT (SGPT) and platelet count. It also
teaches people about fatty liver disease (NAFLD), which is often *not*
caused by alcohol.

Runs on Android, iOS and the web. Text is available in 9 languages. Accounts
and data are stored in **Supabase**.

> ⚠️ LivrCheck is a screening tool, not a diagnosis. All medical text and
> translations must be reviewed by qualified people before a public release.

---

## Where we are

**Last updated:** 29 Sep 2026

| Area | Status | Notes |
|---|---|---|
| FIB-4 calculator | ✅ Done | Formula, risk tiers, age warning, BMI (Asian cut-offs), unit tests |
| Languages (9) | 🟡 Drafts | en, hi, ta, te, kn, ml, mr, gu, or. None reviewed by a native speaker yet. Newer screens are English only for now |
| Login UI | ✅ Done | Teal design, email + password. Phone OTP and Google are coded but hidden until set up in Supabase |
| Login backend (Supabase Auth) | 🟡 Code done | Needs dashboard setup (see [Setup](#setup)) |
| Profile setup after sign-up | ✅ Done | Name and age required before the home page |
| Home page cards | 🟡 Dummy data | Food, health suggestions, FAQ in `lib/data/home_content.dart` |
| Profile page | ✅ Real data | Health score, XP, daily habits, streak, check history, badges — all from Supabase |
| Saving FIB-4 results | ✅ Done | Saved to `assessments` when a check includes blood values |
| Health check survey | 🟡 Built | One question per screen, organ scoring (`lib/survey/`), results saved to Supabase. English only. Needs migration 2 |
| App icon, store listing, privacy policy | ❌ Not started | |

Legend: ✅ done · 🟡 in progress or needs input · ❌ not started

### How finished each screen is

The login screen is the benchmark for "finished": custom design, loading
states, error messages and a working backend.

| Screen | Look & feel | Real data | Still to do |
|---|---|---|---|
| Login | ✅ Polished | ✅ Supabase | Translate the new strings; test phone OTP once SMS is set up |
| Profile setup | 🟡 Plain form | ✅ | Match login styling; add a progress indicator |
| Home | 🟡 Good | ❌ Dummy | Real content; "tip of the day"; content from a Supabase table |
| Check (FIB-4) | 🟡 Basic form | ✅ Saves results | Step-by-step flow; scan the blood report; score gauge animation |
| Profile | ✅ Polished | 🟡 Survey is a sample | FIB-4 trend chart; real survey score; share progress |
| Survey | ❌ | ❌ | Build it |

---

## Project structure

```
lib/
  main.dart                  App start: connects Supabase, picks first screen
  config.dart                Reads SUPABASE_URL / SUPABASE_ANON_KEY from env.json
  theme.dart                 Colours and theme
  app_language.dart          Current language + language dropdown
  fib4.dart                  FIB-4 and BMI formulas
  streak.dart                Streak maths for the profile page
  translations.dart          List of languages
  translations/<code>.dart   All text, one file per language (en.dart is the source)
  data/home_content.dart     Home page cards (DUMMY DATA — edit here)
  services/
    auth_service.dart        Sign in / sign up / sign out (Supabase Auth)
    data_service.dart        Profiles, FIB-4 results, daily activity (Supabase DB)
  screens/
    auth_gate.dart           Signed out → Login · no profile → Setup · else → App
    login_screen.dart        Email, phone OTP and Google sign-in
    profile_setup_screen.dart Name, age, gender, height, weight
    main_shell.dart          Bottom tabs: Home · Check · Profile
    home_screen.dart         Check card, food, health tips, FAQ
    fib4_screen.dart         FIB-4 calculator
    profile_screen.dart      Streak, stats, activity, achievements, history
supabase/migrations/         Database changes, run in order in the SQL Editor
test/                        Unit tests (FIB-4, BMI, streaks)
env.json                     Your Supabase keys (NOT committed to git)
env.example.json             Template for env.json
```

### How to change things

| I want to… | Edit |
|---|---|
| Change any text on screen | `lib/translations/en.dart`, plus the same key in the other language files. Only change the text on the **right**; the key on the left must stay the same |
| Change food, tips or FAQ | `lib/data/home_content.dart` |
| Change colours | `lib/theme.dart` |
| Add a language | Create `lib/translations/<code>.dart`, then add it in `lib/translations.dart` |

---

## Setup

### 1. Supabase keys

Copy `env.example.json` to `env.json` and fill in the values from
**Supabase → Project Settings → API**:

- `SUPABASE_URL`: the Project URL
- `SUPABASE_ANON_KEY`: the **anon / publishable** key

Never use the `service_role` / secret key in the app. `env.json` is in
`.gitignore`, so it stays out of GitHub.

### 2. Create the database tables

Supabase → **SQL Editor** → New query → paste all of
[`supabase/migrations/20260929120000_initial_schema.sql`](supabase/migrations/20260929120000_initial_schema.sql) → **Run**. It's safe to run
again. Future database changes will be new files in `supabase/migrations/`;
run each new one once, oldest first.

This creates:

| Table | What it holds |
|---|---|
| `profiles` | One row per user: name, age, gender, height, weight, language. Created automatically on sign-up |
| `assessments` | Every FIB-4 check: inputs, score, risk tier, date |
| `daily_activity` | One row per day the user opened the app (powers the streak) |
| `survey_responses` | Ready for the survey: answers as JSON, plus a score |

Row Level Security is on for every table, so users can only read and write
their own rows.

### 3. Turn on sign-in methods (Supabase → Authentication → Providers)

| Method | What to do |
|---|---|
| **Email** | On by default. For testing you can turn off "Confirm email" so sign-up logs straight in. Turn it back on for release |
| **Phone (OTP)** | Enable Phone and connect an SMS provider (Twilio, MessageBird, Vonage or Textlocal). Without one, "Send OTP" fails. Costs money per SMS |
| **Google** | Create an OAuth client in Google Cloud Console (APIs & Services → Credentials, type "Web application"). Add the callback URL Supabase shows you as an authorised redirect URI, then paste the Client ID and Secret into Supabase |

### 4. Redirect URLs (Supabase → Authentication → URL Configuration)

Add these under **Redirect URLs**, so Google sign-in and email links can
return to the app:

```
http://localhost:8080
io.livrcheck.app://login-callback
```

Add your real website address once the web version is deployed.

### 5. Run

```bash
flutter pub get
flutter run -d web-server --web-port 8080 --dart-define-from-file=env.json
```

Open http://localhost:8080. In VS Code: Cmd+Shift+P → **Simple Browser: Show**.
Keep port **8080**, because it matches the redirect URL above.

For Android/iOS: `flutter run --dart-define-from-file=env.json`.

### 6. Test

```bash
flutter test
```

---

## Roadmap

### Phase 1: Foundation ✅
- [x] FIB-4 calculator with tests
- [x] 9 languages (drafts)
- [x] Login screen design

### Phase 2: Accounts & storage 🟡 (current)
- [x] Supabase Auth: email/password, phone OTP, Google
- [x] Profile setup before the home page
- [x] Save FIB-4 results; daily activity for streaks
- [x] Password reset
- [x] Bottom navigation: Home · Check · Profile
- [ ] Run the migration and configure providers in the Supabase dashboard
- [ ] Test all three sign-in methods end to end on web and on a phone
- [ ] Google sign-in on Android/iOS with the native flow (`google_sign_in` package) for a smoother experience

### Phase 3: Content & survey
- [ ] Get the survey questions and build the survey screen, saving to `survey_responses`
- [ ] Replace the sample survey score on the profile with the real one
- [ ] Replace dummy home content with doctor-reviewed content
- [ ] Move home content into a Supabase table, so it can change without an app update
- [ ] Translate all new strings (login, profile, home) into the 8 other languages

### Phase 4: Make it engaging and interactive
- [ ] FIB-4 trend chart on the profile
- [ ] Animated score gauge on the result
- [ ] Step-by-step check flow instead of one long form
- [ ] Daily reminder notifications to keep streaks going
- [ ] More achievements, with a celebration animation when one unlocks
- [ ] Onboarding slides for first-time users
- [ ] Dark mode
- [ ] Style the profile setup screen to match login

### Phase 5: Release
- [ ] Native-speaker review of every language
- [ ] Medical review of all health text
- [ ] Consent screen and privacy policy (health data; India's DPDP Act)
- [ ] "Delete my account and data" option
- [ ] App icon and splash screen
- [ ] Replace the placeholder share link `livrcheck.example.com`
- [ ] Play Store and App Store listings

---

## Known issues
- The old `livrcheck_flutter/` folder is the original copy of the code. It's
  out of date and doesn't compile; delete it once `SETUP.md` is no longer
  needed.
- `hi.dart` uses different key names for 5 login strings, so they show in
  English in Hindi.
- Screens added after the translation pass (login, profile, home) show English
  in every language until translated.
