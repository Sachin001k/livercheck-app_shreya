# LivrCheck — complete project guide

The single source of truth for this project: what the app is, how to run
it, how every part works, what has been built, what's pending, and the
rules to follow when changing it. **Update this file whenever something
changes.**

---

## 1. What the app is

LivrCheck is a free Flutter app (web, Android, iOS) for people in India. It:

- screens for **fatty liver (NAFLD/MASLD)** and related risks to the liver,
  heart, kidneys, lungs and blood sugar, through a 2-minute health check
  survey (optionally with FIB-4 from a blood report);
- builds a **daily habit loop**: check in every day and log water, food,
  exercise, steps, sleep, fruit & veg and sweets against personal targets;
- rewards consistency with **coins, levels, streaks and badges**;
- teaches through **food cards, health suggestions and an FAQ**;
- is available in **9 languages** (English, Hindi, Tamil, Telugu, Kannada,
  Malayalam, Marathi, Gujarati, Odia).

Stack: Flutter 3.44 (Dart ^3.12) · Supabase (Auth + Postgres) ·
packages `supabase_flutter`, `url_launcher`.

> ⚠️ All medical content, targets and translations are **drafts** until
> reviewed by a doctor/dietitian and native speakers. It is a screening
> tool, not a diagnosis.

---

## 2. Current status (snapshot)

| Area | Status |
|---|---|
| Welcome slides (first launch) | ✅ Built |
| Consent screen + privacy policy | ✅ Built · policy is a draft |
| Delete my account | ✅ Working (tested) |
| Login (email + password) | ✅ Working with Supabase Auth |
| Profile setup after sign-up | ✅ Working |
| Home: health check card + daily check-in card | ✅ Built |
| Meal picker for calories | ✅ Built |
| Polish: skeletons, friendly errors, large text, haptics | ✅ Built |
| Home: food cards with detail pop-ups, tips, FAQ | ✅ Built · dummy content |
| Health check survey + results | ✅ Built · saving confirmed (bug fixed) |
| Profile: score, coins, streak, Every day, badges | ✅ Built |
| Coins & reward rules (server-checked) | ✅ Built |
| Special surveys | ✅ Screen, Home banner, Rewards list · sample in `supabase/samples/` |
| Rewards tab (coins, how to earn, badges, history, redeem placeholder) | ✅ Built |
| Settings (language, reminder placeholder, account, privacy & data, about) | ✅ Built |
| Download my data | ✅ Built (copy as JSON) |
| Phone OTP / Google sign-in | 🟡 Code ready · hidden until configured |
| Translations | 🟡 All 197 `en.dart` keys in 9 languages · survey/results/daily log/meal names still hardcoded English (Part B) |
| Git / GitHub | ✅ **Public** repo [Sachin001k/livercheck-app_shreya](https://github.com/Sachin001k/livercheck-app_shreya), branch `main` |

**Supabase migrations applied (last checked 1 Oct 2026):** 1 ✅ · 2 ✅ · 3 ✅ · 4 ✅ · 5 ✅ · 6 ✅

---

## 3. Run it

```bash
flutter run -d web-server --web-port 8080 --dart-define-from-file=env.json
```

- Open **http://localhost:8080** (VS Code: Cmd+Shift+P → *Simple Browser: Show*).
- In **that same terminal**: `r` hot reload · `R` hot restart (needed for
  new files, new classes, changed fields) · `q` quit.
- Always keep **port 8080** — Supabase redirect URLs expect it.
- **Port busy:** `lsof -ti tcp:8080 | xargs kill`, then run again.
- Without `--dart-define-from-file=env.json` the app shows
  "Supabase is not configured".
- After big changes, stop (`q`), run again, and hard-reload the browser
  (Cmd+Shift+R).

Checks: `flutter analyze lib test` (must be clean) · `flutter test` (48 tests, all passing).

Save work to GitHub: `git add . && git commit -m "What changed" && git push`.
The repo is **public** — never commit `env.json` or real keys (check `git status` before committing).

---

## 4. Setup (one time)

### 4.1 Supabase keys — `env.json`
```json
{ "SUPABASE_URL": "https://<project>.supabase.co", "SUPABASE_ANON_KEY": "<anon / publishable key>" }
```
- From Supabase → Project Settings → API. Use the **anon/publishable** key only.
- **Never** use the `service_role` key in the app.
- `env.json` is in `.gitignore`. `env.example.json` is the safe template
  (placeholders only — never put real keys in it).
- Read at build time by `lib/config.dart` (`String.fromEnvironment`).

### 4.2 Database — run the migrations
Supabase → **SQL Editor** → New query → paste a file → **Run**. Run each
**once, oldest first**. All are safe to re-run.

| # | File | Adds | Applied |
|---|---|---|---|
| 1 | `20260929120000_initial_schema.sql` | `profiles` (+ auto-create trigger, email/phone sync), `assessments`, `daily_activity`, `survey_responses` | ✅ |
| 2 | `20260930120000_survey_results_and_habits.sql` | `survey_responses.result` + `.tier`, `daily_habits` (now unused) | ✅ |
| 3 | `20260930150000_daily_checkins_and_coins.sql` | `daily_checkins`, `coin_events` | ✅ |
| 4 | `20260930180000_rewards_and_special_surveys.sql` | `reward_rules`, `special_surveys`, `special_survey_responses`, `coin_balances` view, `award_coins` trigger | ✅ |
| 5 | `20261001120000_consent_and_meals.sql` | `profiles.consent_at` + `consent_version`, `daily_checkins.meals` | ✅ |

| 6 | `20261001150000_delete_my_account.sql` | `delete_my_account()` function (deletes the caller's account; all their rows cascade) | ✅ |

> Without migration 5, signed-in users get stuck on the consent screen
> ("Could not save your consent") because the consent columns don't exist.

### 4.3 Supabase dashboard settings
- **Authentication → URL Configuration:** Site URL `http://localhost:8080`;
  Redirect URLs `http://localhost:8080` and `io.livrcheck.app://login-callback`.
- **Authentication → Providers:**
  - Email: on. "Confirm email" is **on** — new users must click the email
    link. Turn off while testing if needed.
  - Phone: off (Twilio selected but not enabled). Needs an SMS provider.
  - Google: off. Needs a Google Cloud OAuth client.

---

## 4.4 Deploying

**Web (shareable link, Vercel):** `./scripts/deploy_web.sh` builds with
`env.json` and runs `vercel deploy --prod` from `build/web`
(`--preview` for a separate test link). The project link is kept in
`.vercel-web/` (git-ignored). After the first deploy, add the site URL to
Supabase → Authentication → URL Configuration (**Site URL** and
**Redirect URLs**), or sign-up confirmation emails link back to
localhost. Custom domain: Vercel → project → Settings → Domains.
The anon key ends up in the public JavaScript — that's expected; RLS
protects the data.

**Android (Play Store):** step-by-step guide in
[`docs/PLAY_STORE_GUIDE.md`](docs/PLAY_STORE_GUIDE.md). Before the first
upload the package name must change from `com.example.livrcheck_app`
(permanent once published), and an upload keystore must be created.

## 5. Architecture

### 5.1 App flow
```
main.dart ── OnboardingPrefs.init ── Supabase.initialize (if env present) ── LivrCheckApp
   └─ LanguageScope (app-wide language, above the Navigator)
       └─ AuthGate
           ├─ first launch (device) .. WelcomeScreen (4 slides)
           ├─ signed out ............. LoginScreen
           ├─ loading profile ........ branded splash
           ├─ no consent (or old) .... ConsentScreen
           ├─ incomplete profile ..... ProfileSetupScreen
           └─ ready .................. MainShell (bottom tabs)
                                        ├─ Home     HomeScreen
                                        ├─ Check    HealthSurveyScreen
                                        ├─ Rewards  RewardsScreen
                                        └─ Profile  ProfileScreen ── ⚙️ SettingsScreen
```
- `AuthGate` listens to Supabase auth changes; switching accounts reloads
  everything (keyed by user id). Also handles the password-recovery link.
- `DataService.changes` (a `ValueNotifier`) is bumped after every write;
  Home and Profile listen and reload.

### 5.2 Code map

| File | What it does |
|---|---|
| `lib/main.dart` | Starts Supabase, theme, language scope, "not configured" screen |
| `lib/config.dart` | Reads `SUPABASE_URL` / `SUPABASE_ANON_KEY`; mobile redirect `io.livrcheck.app://login-callback` |
| `lib/theme.dart` | Colours `tealDark #1F5E55`, `tealLight #5FA79A`, `mintCard #E8F4F1`; app theme |
| `lib/app_language.dart` | `appLanguage` notifier, `LanguageScope`, `context.t('key')`, `LanguageDropdown` (saves choice to profile) |
| `lib/translations.dart` | `AppLanguage` enum with native names; `tr()` with English fallback |
| `lib/translations/*.dart` | All UI text, one file per language (`en.dart` is the source) |
| `lib/fib4.dart` | FIB-4 + BMI formulas (BMI still used by Profile; FIB-4 form removed) |
| `lib/streak.dart` | `currentStreak` / `longestStreak` (calendar-day based) |
| `lib/services/auth_service.dart` | Sign in/up, password reset, phone OTP, Google, `describeError` (shows raw error in debug) |
| `lib/services/data_service.dart` | `Profile`, `Assessment` models; profiles, FIB-4 rows, body stats, language, daily_activity |
| `lib/screens/auth_gate.dart` | Routing by auth/profile state; set-new-password dialog |
| `lib/screens/login_screen.dart` | Email + password login/sign-up (teal design) |
| `lib/screens/profile_setup_screen.dart` | Name, age, gender, height, weight (first run + Edit profile) |
| `lib/screens/main_shell.dart` | App bar with language picker + 3 bottom tabs |
| `lib/screens/home_screen.dart` | Greeting, liver-risk card + daily check-in card, food cards, tips, FAQ |
| `lib/screens/food_detail_sheet.dart` | Food pop-up (nutrition, safe amounts, benefits, risks, swaps, precautions) |
| `lib/screens/profile_screen.dart` | Header, score ring, streak, stats, score chart, Every day, activity grid, badges |
| `lib/data/home_content.dart` | **Dummy content**: 8 foods (with full details), 5 health tips, 6 FAQs |
| `lib/survey/questions.dart` | Health check questions (15, one conditional) |
| `lib/survey/assess.dart` | Scoring: organs, overall score, tests, plan; FIB-4; JSON (de)serialise |
| `lib/survey/health_survey_screen.dart` | One-question-per-screen survey, blood report step, save |
| `lib/survey/results_screen.dart` | Score ring, save banner, body map, organ detail, tests, plan tabs |
| `lib/survey/body_map.dart` | Tappable body outline with 5 coloured organs |
| `lib/survey/health_ui.dart` | Level colours, `BigButton`, `SurfaceCard`, disclaimer |
| `lib/survey/progress_store.dart` | Health check history (`survey_responses`), FIB-4 copy to `assessments`, profile body stats |
| `lib/daily/daily_targets.dart` | Personal daily targets + day scoring + coin constants |
| `lib/daily/daily_items.dart` | The 7 daily log items (ranges, steps, goals, hints) |
| `lib/daily/daily_store.dart` | Check-in, save log, award coins, load days + coin total |
| `lib/daily/daily_checkin_card.dart` | Home card: check-in, swipeable log, meal picker button, animations, celebration, haptics |
| `lib/daily/meal_catalog.dart` | 41 Indian foods with portions and kcal; `mealTotals()` |
| `lib/daily/meal_picker_sheet.dart` | Meal picker bottom sheet (search, −/+ counts, live kcal vs goal) |
| `lib/onboarding/onboarding_prefs.dart` | Device flag "welcome slides seen" (`shared_preferences`) |
| `lib/onboarding/welcome_screen.dart` | 4 animated first-launch slides with language picker |
| `lib/onboarding/consent_screen.dart` | What/why/who/choices + 2 required ticks (no age limit); saves consent |
| `lib/screens/delete_account_dialog.dart` | "Delete my account" dialog (type DELETE to confirm) |
| `lib/onboarding/privacy_policy_screen.dart` | **Draft** privacy policy (DPDP Act principles); contact email is a placeholder |
| `lib/rewards/reward_store.dart` | Reward rules, coin history, special surveys (load + submit) |
| `lib/rewards/rewards_screen.dart` | Rewards tab |
| `lib/rewards/special_survey_screen.dart` | Answer a special survey (choice / multi / scale / text) |
| `lib/rewards/badges.dart` | 10 badges and their unlock rules |
| `lib/daily/weekly_summary.dart` | This week vs last week maths |
| `lib/screens/settings_screen.dart` | Settings + Download my data dialog |
| `lib/widgets/home_extras.dart` | Special survey banner, Tip of the day |
| `lib/widgets/skeleton.dart` | Shimmer placeholders (`Skeleton`, `SkeletonList`) |
| `lib/widgets/friendly_state.dart` | Friendly empty/error states; `friendlyError()` plain-language messages |
| `supabase/migrations/*.sql` | Database schema (see §6) |
| `test/*.dart` | Unit + widget tests (see §10) |

Platform config: Android manifest has INTERNET permission, the
`io.livrcheck.app://login-callback` deep link and an https `<queries>`
entry; iOS `Info.plist` has the `io.livrcheck.app` URL scheme.

---

## 6. Database (Supabase)

Row Level Security is **on for every table**: a user can only read/write
their own rows, even though the app ships the public anon key.

| Table | One row per | Key columns | Written by |
|---|---|---|---|
| `profiles` | user | email, phone, full_name, age, gender, height_cm, weight_kg, preferred_language, consent_at, consent_version | trigger on sign-up; consent screen; setup screen; survey (age/height/weight) |
| `assessments` | FIB-4 result | age, ast, alt, platelets (×10⁹/L), fib4_score, risk_tier, bmi | health check when blood values entered |
| `survey_responses` | health check | answers (jsonb), score, tier, result (jsonb, full result), survey_version | health check |
| `daily_checkins` | user per day | water_ml, calories, exercise_min, steps, sleep_hours, fruit_veg, sugary_items, meals (jsonb `{food id: portions}`), score, logged_at (null = check-in only) | Home check-in card |
| `coin_events` | coin reward | day, reason, amount (set by server), ref_id (special survey) | check-in card (amount overridden by trigger) |
| `reward_rules` | way to earn | reason, amount, description, active | you (edit amounts here) |
| `special_surveys` | announced survey | title, description, questions (jsonb), reward_coins, starts_at, ends_at, is_active | you (Table Editor / SQL) |
| `special_survey_responses` | user per survey | survey_id, answers (jsonb) | (future app screen) |
| `coin_balances` (view) | user | total, from_checkins, from_daily_logs, from_bonuses, from_special_surveys | — |
| `daily_activity` | user per day opened | activity_date | AuthGate on login (no longer displayed) |
| `daily_habits` | — | — | **unused** (replaced by daily log) |

Triggers:
- `on_auth_user_created` → creates the `profiles` row (name from sign-up
  form or Google, email, phone).
- `on_auth_user_contact_changed` → keeps profile email/phone in sync.
- `coin_events_award` (`award_coins()`) → sets `amount` from `reward_rules`
  and **rejects** unearned coins: check-in needs a `daily_checkins` row,
  daily_log needs `logged_at`, bonus needs `score ≥ 90`, special survey
  needs an open survey + a response; day-based rewards only for today (±1
  day for time zones).

Uniqueness: day rewards once per `(user, day, reason)`; special survey
once per `(user, survey)`.

**Adding data later:** a single fact about a person → new column on
`profiles`; something repeated over time → new table with one row per
entry. Always via a **new** migration file.

---

## 7. Features in detail

### 7.0 First run: welcome slides & consent
- **Welcome slides** (first launch on a device, before login): Know your
  liver · Build healthy days · Earn coins · Your data stays yours. Animated
  emoji, chips, dots, Skip / Next / Get started, language picker. Seen-flag
  stored on the device, so they show again on a new device or after
  clearing browser data.
- **Consent** (after sign-in, before profile setup): four cards (what we
  store, why, who can see it, your choices), link to the privacy policy,
  two required ticks (not a diagnosis, agree to storage). No age limit —
  anyone can use the app. Saved as
  `consent_at` + `consent_version`. Bump `currentConsentVersion`
  (`data_service.dart`) when the text changes to ask everyone again.
- **Privacy policy** screen: also linked from the Profile. **Draft** —
  needs legal review and a real contact email.

- **Delete my account** (Profile, under Sign out): explains what is lost,
  user types DELETE, then `rpc('delete_my_account')` removes the auth user
  and — via ON DELETE CASCADE — every row in every LivrCheck table, and
  the app returns to the login screen. Without migration 6 it shows
  "Could not delete your account".

### 7.1 Login & accounts
- Email + password sign-in and "Create an account" (name, email, password
  ≥ 6). Forgot password sends a reset link; opening it shows a
  set-new-password dialog.
- Phone OTP (+91) and Google are implemented in `AuthService` but
  **hidden** in the UI until configured in Supabase.
- Sessions persist automatically (no "Remember me").
- After sign-up/confirmation → profile setup (name + age required) → Home.

### 7.2 Home
1. **Check your liver risk** card (gradient, floating 🩺, organ chips) →
   Check tab.
2. **Daily check-in** card, side by side on wide screens (≥ 620 px),
   stacked on phones; both 440 px tall:
   - 🔥 streak and 🪙 coin pills (numbers count up).
   - Pulsing **Check in** button (+1).
   - **Log today** → swipeable cards, one per item, each with −/+ buttons,
     slider, progress bar to goal, Skip/Add, hint; dots show progress and
     the live score updates. Last card: **Save · +10 🪙**.
   - **Meal picker** (Food eaten card → "Pick what you ate"): 41 common
     Indian foods in 4 groups with portions and kcal, search, −/+ per food,
     running total vs goal. "Use N kcal" fills calories, and also fills
     fruit & veg and sweets if those are still empty. Picks are saved with
     the log (`meals`) and reloaded when editing. Values are **draft**.
   - "+N coins" celebration overlay after earning.
   - Once logged: animated score ring, coloured chip per item, **Edit**.
3. **Food for a healthy liver** — 8 cards (5 eat-more, 3 limit), each opens
   a pop-up: kcal per serving + 6 nutrients, safe daily amount for
   children / adults / elders, "Helps keep away" (benefits), "Too much can
   affect" (organ risks), "Healthier swaps" (limit foods), precautions.
   Sources: USDA FoodData Central, IFCT 2017, ICMR-NIN, WHO. **Draft.**
4. **Health suggestions** (5) and **Fatty liver FAQ** (6). **Dummy.**

### 7.3 Health check (Check tab)
- Intro card → 15 questions, one per screen (auto-advance on single
  choice): sex, age, height, weight, waist (or estimate), activity, sugar,
  fried food, sleep, tobacco, alcohol, conditions (PCOS only for women),
  family history, blood report? → AST/ALT/platelets (unit auto-detected:
  lakh/cmm, /µL, ×10⁹/L).
- Pre-filled from the profile; a retake keeps lifestyle answers but asks
  about the blood report again.
- **Scoring (`assess.dart`)**, per organ (low / mod / high):
  - Pancreas: Indian Diabetes Risk Score (age, activity, family, waist).
  - Liver: BMI (Asian cut-offs 23/25), waist, diabetes, BP, cholesterol,
    sitting, sugar, fried food, alcohol, family, PCOS, thyroid; **FIB-4**
    overrides when labs given (cut-offs 1.3 — or 2.0 at 65+ — and 2.67).
  - Heart, kidneys (risk factors); lungs (tobacco).
  - Overall score = 100 − 9 per "mod" − 18 per "high" − 4 for poor sleep
    (min 10). Tiers: Thriving ≥ 80 · Strong ≥ 60 · Building ≥ 40 · Needs care.
- **Results:** score ring, save banner (Saved / Not saved + Retry), see-a-
  doctor warning, tappable body map + organ chips, reasons, tests to ask
  for, plan tabs (Eat more / Eat less / Exercise / Habits), Track my habits
  (→ Profile) or Take the check again.
- **Saved:** `survey_responses` (answers + full result); `assessments` if
  FIB-4; profile age/height/weight updated.

### 7.4 Profile
Header (initials, email, member since, age, edit) → health score ring with
change since last check + level bar → streak card (last 7 days) → stats
(Coins/level, Checks done, Latest FIB-4, BMI) → score chart (last 10
checks) → **Every day** (one card per day: check-in, daily log score,
coins, health checks — tap to reopen results; last 14 active days) →
activity grid (shade = check-in / logged / 90+) → badges (First check,
Improved score, 3- and 7-day streak, 90+ day, 100 coins, Blood report
added) → Sign out.

### 7.5 Coins & rewards
| Action | Coins | Limit |
|---|---|---|
| Check in (Home) | +1 | once a day (logging also counts) |
| Save today's log | +10 | once a day (edits don't pay again) |
| Today's log scores ≥ 90 | +20 | once a day |
| Special survey | set per survey (default 50) | once per survey |

Level = coins ÷ 100 + 1. Streak = consecutive days with a check-in or log.
Amounts live in `reward_rules` (change them there; the app shows its own
constants in `daily_targets.dart` — keep both in sync).

### 7.6 Daily targets & scoring (`daily_targets.dart`)
| Item | Target |
|---|---|
| Water | ≈ 35 ml/kg, 2.0–3.5 L |
| Calories | Mifflin-St Jeor BMR × 1.375; −500 if BMI ≥ 23; min 1500 (m) / 1200 (f); rounded to 50 |
| Exercise | 30 min |
| Steps | 8,000 (6,000 at 60+) |
| Sleep | 7–9 h |
| Fruit & veg | 5 servings |
| Sweets / sugary drinks | 0 |

Day score = average of the items filled in (skipped items don't count) ×
100. Calories: full marks within ±10 %, zero at ±40 %. Sleep: loses marks
per hour outside 7–9. Sweets: 0 → 1, 1 → 0.6, 2 → 0.3, 3+ → 0.

### 7.7 Languages
- 9 languages; picker in the login screen and app bar; saved per user.
- Text via `context.t('key')`; missing keys fall back to English.
- **English only for now:** health check, results, daily check-in,
  profile additions, food content.
- Edit only the text on the **right** of each line; keys on the left must
  match `en.dart`.

---

### 7.8 App blueprint (where every component lives)

| Screen | Components (top to bottom) |
|---|---|
| First run | Welcome slides → Login → Consent → Profile setup |
| **Home** | Greeting · Special survey banner (only when one is open) · Liver-risk card + Daily check-in card (side by side / stacked) · Tip of the day · Food cards · Health suggestions · FAQ |
| **Check** | Your last check (score, date, next due in 90 days, See results) · Intro → 15 questions → Results |
| **Rewards** | Coin balance + level · How to earn (from `reward_rules`) · Special surveys (open + completed) · Badges (10, hints when locked) · Redeem rewards (**placeholder**) · Coin history |
| **Profile** | Header (⚙️ settings, ✏️ edit) · Health score + level · Streak · This week (avg score, days logged, best day, vs last week) · Stats · Score chart · Every day · Activity grid |
| **Settings** | Language · Daily reminder (**placeholder**) · Edit profile · Sign out · Privacy policy · Download my data · Delete account · Version · Contact |
| **Special survey** | Header with reward → questions as cards → Submit → "+N coins" |

### 7.9 Special surveys — how to publish one
Insert a row into `special_surveys` (Table Editor or SQL; example in
`supabase/samples/sample_special_survey.sql`). `questions` is a JSON array:
```json
[{"id": "glasses", "type": "choice", "title": "How many glasses a day?",
  "options": [{"v": "lt4", "label": "Fewer than 4", "emoji": "🥤"}]},
 {"id": "energy", "type": "scale", "title": "Energy 1–5?"},
 {"id": "notes",  "type": "text",  "title": "Anything else?"}]
```
Types: `choice`, `multi`, `scale` (1–5), `text`. It shows while
`is_active` and between `starts_at` / `ends_at`. Answers go to
`special_survey_responses`; coins (`reward_coins`) are paid once by the server.

## 8. Design system & UX polish
- Loading: **skeleton shimmer** shaped like the content (daily card,
  Profile); branded splash while the profile loads.
- Errors: `FriendlyState.error` with plain words ("No internet
  connection…") and Try again; raw error shown under it in debug only.
- Large text: Home cards and food row grow with the phone's text size
  (up to 1.6–1.7×); tested at 1.5×.
- Haptics: check-in, save, −/+ steps, survey answers.
- Pull to refresh on Home and Profile.
- `SurfaceCard` contains a transparent `Material`, so ripples on ListTiles
  inside white cards are visible.

- Colours: `tealDark`, `tealLight`, `mintCard` (`theme.dart`); risk colours
  `kLow` green, `kMod` amber, `kHigh` red (`health_ui.dart`).
- **`SurfaceCard`** — white card, soft border + shadow; use it for any
  content that sits on the tinted background.
- `BigButton` — 56 px full-width primary / outlined button.
- Layouts cap width (Home 720, survey 520–560) so web looks phone-shaped.
- Animations: `AnimatedSwitcher` (fade + slide) between states,
  `TweenAnimationBuilder` for counters/rings/progress, repeating
  controllers for pulse/float. **Create controllers in `initState`.**

---

## 9. Progress tracker

Legend: ✅ done · 🟡 in progress / needs checking · ⬜ not started

### Foundation
- ✅ FIB-4 + BMI logic with tests
- ✅ 9 languages (drafts); per-language files
- ✅ Folder structure (screens / services / survey / daily / data)

### Accounts & storage
- ✅ Welcome slides (first launch)
- ✅ Consent screen + draft privacy policy (DPDP principles)
- ✅ Migration 5 applied
- ⬜ Legal review of the privacy policy; real contact email
- ✅ Delete-my-account (Profile → Delete my account) · ✅ migration 6 applied
- ⬜ "Download my data" export (DPDP right to a copy)
- ✅ Supabase Auth email/password, sign-up, password reset
- ✅ Profile auto-created on sign-up (name, email) + setup screen
- ✅ Migrations 1 & 2 applied
- ✅ Migrations 3, 4 & 5 applied
- 🟡 Phone OTP (needs Twilio enabled) · Google (needs OAuth client)

### Home
- ✅ Liver-risk card + daily check-in card side by side
- ✅ Food cards with full detail pop-ups (8/8)
- ✅ Health tips + FAQ (dummy)
- ⬜ Replace dummy content with reviewed content; move to a Supabase table

### Health check survey — Step 1
- ✅ Survey, scoring, results, body map (user-supplied code, adapted)
- ✅ Saved to Supabase; FIB-4 copied to `assessments`; profile updated
- ✅ Fixed "setState() callback returned a Future" (made saves look failed)
- ✅ Card styling; save banner with Retry
- ✅ Profile "Every day" history; habit ticks removed
- 🟡 Confirm end to end after a full restart

### Daily check-in — Step 2
- ✅ Check-in, swipeable log, personal targets, live score, animations
- ✅ Saved to `daily_checkins`, editable same day
- ⬜ Evening reminder notifications
- ✅ Meal picker for calories (41 foods, auto-fills fruit & veg and sweets)
- ⬜ Review food kcal values with a dietitian; add more regional foods
- ⬜ Step sync from Google Fit / Apple Health

### Coins — Step 3
- ✅ +1 / +10 / +20 rules, server-checked (`reward_rules`, `award_coins`)
- ✅ Coins, levels, badges on Profile
- ✅ Tables for special surveys with their own rewards
- ✅ Special survey screen, Home banner, Rewards list, sample survey SQL
- ⬜ Decide what coins are spent on (rewards, themes, challenges)

### UX polish — done 1 Oct 2026
- ✅ Skeleton loaders, friendly errors, branded splash
- ✅ Large-text support on Home, haptics, pull to refresh, visible ripples
- ⬜ Dark mode
- ⬜ Screen-reader labels review

### App structure — done 1 Oct 2026
- ✅ 4 tabs: Home · Check · Rewards · Profile
- ✅ Rewards tab (balance, how to earn, surveys, badges, redeem placeholder, history)
- ✅ Settings screen; Profile is progress-only (badges → Rewards; account items → Settings)
- ✅ Home: special survey banner, tip of the day
- ✅ Check: "Your last check" summary
- ✅ Profile: weekly summary
- ✅ Download my data (JSON copy)
- ⬜ Redeem rewards (placeholder) — decide what coins buy
- ⬜ Daily reminder (placeholder) — needs notifications
- ⬜ Real support email (`supportEmail` in `config.dart`)

### Later / release
- ⬜ Web deploy to Vercel (script ready; waiting for the right Vercel account) + Supabase URL config
- ⬜ Play Store: developer account (👤), package name, icon, signing key, AAB build, listing, policies — see `docs/PLAY_STORE_GUIDE.md`
- ⬜ Public pages on the website: privacy policy, account-deletion request
- ⬜ **Data safety:** upgrade Supabase to Pro (daily backups) **when publishing to the Play Store** — decided 1 Oct 2026. Until then the free plan is used daily (it only pauses after 7 idle days) and has no automatic backups.
- ⬜ Offline saving: queue check-ins / logs without internet and sync later (today they fail with an error)
- ⬜ Streak freeze: spend coins to protect a missed day (good first "Redeem rewards" item)
- ✅ Translations Part A: every `en.dart` key translated into all 8 languages (drafts)
- ⬜ Translations Part B: move hardcoded text (survey questions, results, assess reasons, daily log items, meal names, profile labels, privacy policy) into `en.dart`, then translate
- ⬜ Native-speaker review of translations; doctor/dietitian review of all health text
- ⬜ Weekly summary on Profile (average daily score, trend)
- ⬜ More user details (to be provided by product owner)
- ✅ Delete-my-account, consent and draft privacy policy
- ⬜ App icon, splash screen, real share link, store listings
- ✅ Local git repo created (`main`, initial commit); `env.json` and `livrcheck_flutter/` excluded
- ✅ Pushed to GitHub: https://github.com/Sachin001k/livercheck-app_shreya (public)

---

## 10. Testing
`flutter test` — 41 tests:
| File | Covers |
|---|---|
| `fib4_test.dart` | FIB-4 formula, tiers, BMI, invalid input |
| `streak_test.dart` | current/longest streak, gaps, month boundaries |
| `assess_test.dart` | healthy vs high-risk scoring, FIB-4 from labs, units, JSON round trip |
| `daily_targets_test.dart` | water/calorie targets, day scoring |
| `health_survey_test.dart` | taps through every question to results |
| `home_screen_test.dart` | food card opens pop-up; all 8 pop-ups lay out; Home at 1.5× text has no overflow |
| `onboarding_test.dart` | welcome slides advance to Get started; consent needs both ticks; delete needs "DELETE" typed |
| `meal_catalog_test.dart` | meal totals (kcal, fruit & veg, sweets), unique food ids |
| `rewards_test.dart` | badge thresholds, weekly summary maths, special survey JSON parsing |

Notes: Supabase isn't initialised in tests, so saves fail there (the UI
must still work — it does). Home has repeating animations, so **don't use
`pumpAndSettle`** on it; pump fixed durations.

Visual checks: build a temporary `lib/_preview.dart` entry point that
renders one screen with sample data (`flutter build web -t lib/_preview.dart`),
screenshot with headless Chrome, then **delete the preview files**.

---

## 11. Troubleshooting (problems already hit)
| Symptom | Cause / fix |
|---|---|
| "Supabase is not configured" | Started without `--dart-define-from-file=env.json` |
| Screen shows key names (`loginTitle`) | Stale hot reload — press `R` (translations map is `const` so `r` normally works) |
| Changes don't appear | Old server still running or `r` used for new files → `q`, run again, Cmd+Shift+R |
| "Hot reload rejected… Const class cannot remove fields" | Press `R` |
| "Could not find the table 'public.…'" | Migration not run |
| "Something went wrong" / "setState() callback returned a Future" | Arrow `setState(() => x = future())` — use a block body. Fixed in `auth_gate.dart` |
| "Looking up a deactivated widget's ancestor" on close | `late final AnimationController` first created in `dispose()` — create in `initState` |
| `q` / `r` "command not found" | Typed in a normal shell, not the terminal running `flutter run` |
| "Target file not found" | Wrong command; use the exact run command in §3 |
| Port 8080 in use | `lsof -ti tcp:8080 \| xargs kill` |
| Confirmation email opens localhost:3000 | Set Site URL (§4.3) |
| Stuck on "Before we start" / "Could not save your consent" | Run migration 5 |
| Welcome slides show again | Expected on a new device/browser or after clearing site data (flag is per device) |
| Daily check-in card: "null is not a subtype of String" after a special survey | Fixed 1 Oct: special survey coins have `day = null`; `sumCoins()` skips them per day but counts them in the total (`daily_store_test.dart`) |
| Ripple not visible / "ListTile … DecoratedBox" assertion | Put ListTiles inside `SurfaceCard` (it provides a Material) |

---

## 12. Decisions log
- Email-only login for now; phone and Google hidden until configured.
- Old FIB-4 form removed; FIB-4 lives inside the health check.
- Survey code supplied by the product owner; kept as written except
  Supabase storage, profile merge, save banner, styling, small fixes
  (🫁→🍃 for liver, PCOS dropped when sex changes).
- Survey FIB-4 cut-offs 1.3 / 2.67 (2.0 at 65+) — the standard NAFLD
  cut-offs; the old form used 3.25.
- Habit ticks + XP replaced by the daily log + coins (one daily loop, one
  currency). Streak = days with check-in or log.
- Coin amounts set and verified server-side (trigger), not trusted from the app.
- WhatsApp share button was part of the removed FIB-4 form — not currently in the app.
- Welcome-seen flag is stored on the device (not Supabase) because the
  slides show before sign-in.
- Consent is versioned (`currentConsentVersion`) so changed terms re-ask.
- Meal picker fills calories and only *empty* fruit & veg / sweets items,
  so it never overwrites what the user set.

## 13. Known issues
- **Decision pending — children:** the app has no age limit, but the health
  check is built for adults (age slider 18–90; scoring validated for
  adults). Option: let under-18s use the daily log/food/coins and show
  "designed for adults" on the health check.
- **Legal pending — DPDP Act:** data from under-18s needs verifiable
  parent/guardian consent. Add a parent-consent step or an age limit
  before public launch (confirm with a legal adviser).
- Privacy policy contact email is a placeholder (`privacy@livrcheck.example`).
- Meal names and the privacy policy are English only (welcome/consent text is in `en.dart`).
- App name spelling is mixed: older `appTitle` entries use local script (e.g. लिवरचेक), newer strings use Latin "LivrCheck". Pick one.
- `livrcheck_flutter/` is an outdated copy of the original code and doesn't
  compile — delete once `SETUP.md` isn't needed.
- `daily_habits` table and `daily_activity` logging are unused leftovers.
- Unused old translation keys (FIB-4 form, username/remember me) remain.
- Coin amounts exist in two places (`reward_rules` and `daily_targets.dart`).
- `livrcheck_flutter/` is git-ignored (kept locally only).

## 14. Rules for working on this project
- Keep `flutter analyze lib test` clean and `flutter test` green.
- Database changes = a **new** file in `supabase/migrations/`; never edit
  one that has been run. Every new table gets RLS policies.
- Never put the `service_role` key in the app or real keys in `env.example.json`.
- Medical content stays marked as draft until reviewed.
- New UI text goes in `lib/translations/en.dart` (other languages fall back).
- Use `SurfaceCard` for content on the tinted background.
- Create animation controllers in `initState`; never return a Future from a
  `setState` callback.
- **Update this file** (status, tracker, migrations table) with every change.
