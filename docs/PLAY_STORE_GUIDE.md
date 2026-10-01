# Publishing LivrCheck on Google Play — step by step

Google changes Play rules from time to time. Facts below were correct at
the time of writing; the Play Console always shows the current
requirement when something is missing.

**Who does what:** steps marked 👤 need you (accounts, payments, ID,
decisions). Steps marked 🛠️ are code/build work that can be done in the
project.

---

## Overview and timeline

| Stage | What happens | Typical time |
|---|---|---|
| 1. Developer account | Register, pay, verify identity | 1–3 days (personal) · up to ~4 weeks (organisation, needs D-U-N-S) |
| 2. Prepare the app | Package name, icon, signing, release build | 1–2 days of dev work |
| 3. Store listing & policies | Text, screenshots, privacy, data safety, health declaration | 1 day |
| 4. Testing tracks | Internal test → closed test (**12 testers for 14 days** for new personal accounts) | 2–3 weeks |
| 5. Production review | Google reviews, then the app goes live | a few days |

---

## 1. Create the Google Play developer account 👤

1. **Choose the account type.**
   - **Personal** — quicker. New personal accounts must run a **closed test
     with at least 12 testers for 14 days in a row** before they can
     publish to everyone.
   - **Organisation** — for a company/NGO. Needs a free **D-U-N-S number**
     (apply at dnb.com; can take up to ~30 days), an official website and
     email, and organisation documents. No 12-tester rule.
   - LivrCheck is a **health app**. Google applies extra rules to health
     and medical apps and may require an organisation account for some
     of them. If you have (or plan) a registered company, an organisation
     account is the safer choice. Check the "Health apps" policy in the
     Play Console Help Center before registering.
2. Use a **dedicated Google account** for the business (not a personal
   Gmail you might lose access to). Turn on 2-step verification.
3. Go to **play.google.com/console/signup**, sign in, pick the account type.
4. Fill in developer name (shown publicly on the store), contact email,
   phone, address.
5. Pay the **one-time US$25** registration fee.
6. **Verify your identity**: upload a government ID (and for
   organisations, the D-U-N-S / business details). Google also verifies
   your phone and email, and may ask you to install the Play Console app
   on an Android phone to verify you have a real device.
7. Wait for the verification email.

---

## 2. Prepare the app 🛠️ (can be done in the project)

| Task | Status | Notes |
|---|---|---|
| Unique package name | ⬜ | Today it is `com.example.livrcheck_app`. Google rejects `com.example`. Pick e.g. `in.livrcheck.app` — **it can never change after the first upload** |
| App name | ✅ | "LivrCheck" (AndroidManifest) |
| App icon + splash | ⬜ | 512×512 icon; generate all sizes with `flutter_launcher_icons` |
| Upload signing key | ⬜ | Create a keystore once (`keytool`), keep it **and its passwords** safe in 2 places. Losing it means you cannot update the app |
| Play App Signing | ⬜ | Accept it at first upload (Google keeps the final signing key) |
| Release build | ⬜ | `flutter build appbundle --release --dart-define-from-file=env.json` → `build/app/outputs/bundle/release/app-release.aab` |
| Version number | ✅ | `version: 1.0.0+1` in pubspec.yaml — **increase the `+N` number for every upload** |
| Target API level | ✅ | Flutter's default meets Google's current target; Play Console warns if not |
| Supabase redirect | ✅ | `io.livrcheck.app://login-callback` is configured for email links |

---

## 3. Create the app and fill in the policy forms 👤 (with help)

In Play Console → **Create app**: name, default language, App (not
game), Free, accept the declarations.

Then **Dashboard → Set up your app** lists every required item:

1. **Privacy policy URL** — must be a public web page. Host the in-app
   policy on the website (Vercel), e.g. `https://<your-site>/privacy`.
   Needs legal review and a real contact email first.
2. **App access** — LivrCheck needs a login, so give Google reviewers a
   **test account** (email + password) that is already confirmed.
3. **Ads** — "No, my app does not contain ads."
4. **Content rating** — answer the questionnaire (IARC). A health
   information app usually rates "Everyone"/"3+".
5. **Target audience** — pick the age groups. ⚠️ This ties to the open
   under-18 decision. Choosing under-13s brings in Google's **Families**
   rules and parental-consent requirements; choosing **18+** is simplest.
6. **Data safety** — declare what the app collects:
   - Personal info: email, name
   - Health and fitness: health check answers, blood test values, daily
     logs (water, food, exercise, sleep)
   - App activity: check-ins, coins
   - Collected, **not shared**, **encrypted in transit**, users **can
     delete** their data
7. **Account deletion** — apps with accounts must offer deletion **in the
   app** ✅ (Profile → Settings → Delete my account) **and** a **web
   link** where people can request deletion without the app. ⬜ Add a
   simple page on the website.
8. **Health apps declaration** — Google asks health apps to declare their
   health features. Describe it as a wellness/screening tool, not a
   medical device, and keep the disclaimer in the listing.
9. **Government apps / financial / news** — answer "No".

---

## 4. Store listing 👤 (with help for text)

| Item | Requirement |
|---|---|
| App name | up to 30 characters — "LivrCheck: Liver Health Check" |
| Short description | up to 80 characters |
| Full description | up to 4,000 characters; include "This is a screening tool, not a diagnosis" |
| App icon | 512 × 512 PNG |
| Feature graphic | 1024 × 500 PNG/JPG |
| Phone screenshots | at least 2 (up to 8), e.g. Home, Check, Results, Rewards, Profile |
| Category | Health & Fitness (or Medical) |
| Contact | email (required), website, phone (optional) |
| Translations | optional: add Hindi and other listings later |

---

## 5. Testing tracks 👤 + 🛠️

1. **Internal testing** (instant, up to 100 testers) — upload the `.aab`,
   add testers' Gmail addresses, share the opt-in link. Use this first.
2. **Closed testing** — required for new **personal** accounts: at least
   **12 testers opted in for 14 days in a row**. Testers install from the
   Play Store link and should actually use the app. Collect their feedback.
3. **Apply for production** (Dashboard). Google asks a few questions about
   your testing.
4. **Production** — create a release, roll out (optionally to a
   percentage first). Review usually takes a few days.

---

## 6. Before you press "Publish" — checklist

- [ ] Supabase upgraded to **Pro** (daily backups)
- [ ] Real support/privacy email in the app (`lib/config.dart`) and policy
- [ ] Privacy policy reviewed by a lawyer and hosted publicly
- [ ] Account-deletion web page live
- [ ] Under-18 decision made (parental consent or 18+ only)
- [ ] Doctor/dietitian review of health text and calorie values
- [ ] Native-speaker review of translations
- [ ] Reviewer test account confirmed and working
- [ ] Release build tested on a real Android phone

---

## Sharing the app for testing before Play Store

- **Web link (Vercel):** `./scripts/deploy_web.sh` publishes the web
  version; anyone with the link can use it in a browser.
- **Android without the Store:** build an APK
  (`flutter build apk --release --dart-define-from-file=env.json`) and
  share the file; testers must allow "install unknown apps". Fine for a
  few friends; use Play internal testing for anything bigger.
