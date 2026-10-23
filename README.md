# MEWVIO 🐱💜

MEWVIO Social is an Android-first Flutter social network beta combining original, demo-inspired short videos, matching, voice rooms, chat, feed and communities. Its visual design is original, not a clone of other companies' assets.

Registration, login, session restoration, profile editing and logout connect to Supabase. Profiles are visible only to their owner. The gallery cover-photo picker remains a local preview and does not upload photos. The new home feed provides demo posts, local comments and follows, safe sample groups, and entrypoints to bundled offline short videos, matching and voice rooms. Chat, live streaming, public communities, upload, real users and shopping are not server-connected in this beta.

## Build Android APK

Push commits to `main` or run **Actions → Build MEWVIO Android APK → Run workflow**. When build succeeds, download the `MEWVIO-Social-v0.5.0-Beta-APK` artifact ZIP from the workflow run. Extract `app-release.apk` and install it on Android. This build uses the repository's existing debug/release configuration and is intended for beta testing, not public store distribution.

## Local setup

```bash
flutter create --no-pub --platforms=android --project-name mewvio .
git restore --source=HEAD -- pubspec.lock
python3 scripts/configure_android_network.py
flutter pub get --enforce-lockfile
flutter test
flutter build apk --debug
```

## Accounts and database

Use Flutter 3.47.7 with the committed dependency lockfile, matching CI. The app contains only a Supabase publishable key; never add a service-role or secret key. `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` can be overridden with `--dart-define` for a separate project.

Apply `supabase/migrations/20261021194507_private_account_profiles.sql` to a new project before using accounts. It creates private `profiles` with owner-only RLS and column grants. It does not grant company admin membership. The existing `admin_members` table and Cloudflare Access policy remain separate. Run `supabase/tests/private_profiles.sql` as the migration owner to verify permissions; all fixtures are rolled back.

New accounts must confirm their email when confirmation is enabled. Open the email link, then return to the app and sign in. Native email-link routing and password recovery are not configured in this beta. Supabase's built-in mail service restricts recipients and delivery rates; configure production SMTP in Supabase before inviting public users. Do not disable confirmation to bypass mail restrictions.

## Safety

Before any public social launch, implement age-appropriate policies, abuse reporting, blocking, moderation and content review. Company data stays behind the private admin's independent access controls.


## MEWVIO Social Web (beta)

The repository homepage `index.html` is now the responsive MEWVIO Social web frontend. The previous promotional website remains available as `landing.html`.

**Online deployment:** `.github/workflows/pages.yml` deploys the static site from the default branch to GitHub Pages. In the repository, set **Settings → Pages → Build and deployment → Source: GitHub Actions** to enable it if not already enabled. The standard Pages address, after successful deployment, is `https://lensbykai-bit.github.io/MEWVIO/`. Confirm deployment status in the Actions tab; committing HTML alone does not guarantee a published website.

**Limits:** This website is a public frontend beta, not a production social network. Posts, chat messages, likes and follows are demos/browser-local; there is no real user sync, auth, media hosting, live voice or moderation backend wired into this web page. The Flutter Android prototype's private Supabase profiles are separate and must not be exposed. Implement privacy controls, blocking/reporting, moderation and production-grade authorization before inviting real users.

## MEWVIO Social Android 0.5.1

Removed all MEWVIO Wallet and demo diamond-shop navigation from Android guest profile, signed-in account menu, and the global create menu. The profile now displays Posts / Likes / Saved below interest chips without the wallet card. The inactive wallet/shop Dart files remain in the repository only for version history and are no longer imported by the running app. CI builds `MEWVIO-Social-v0.5.1-No-Wallet-APK`. No backend financial service is available.

## MEWVIO Social Android & Web 0.5.3

Unified **© 2026 MEWVIO Technologies. All rights reserved.** across the Android guest profile, the signed-in profile, the Social web profile and site footer, and the preserved landing page. Removed residual Wallet wording from the web Live preview. Tests now check that the Android copyright notice appears for both guest and signed-in profiles. The notice is for MEWVIO's original app/site material, not automatically for third-party sample media. APK CI artifact: `MEWVIO-Social-v0.5.3-App-Web-APK`.

## MEWVIO Social unified App & Web beta 0.6.0

The Android and responsive website now share the same official kitten SVG, dark navy / cyan / purple / pink visual language, main five-tab mobile navigation (**Home / Videos / + / Chat / Profile**), creator entrypoints, wallet-free profile presentation and copyright notice. The web mobile profile now follows the Flutter guest profile layout, using the same sample Unsplash image references, stats and Posts / Likes / Saved tabs. The web profile's edit preview saves only for the current browser session; neither site nor app demo social content is globally synchronized.

The native Flutter account registration/private profile functions still use Supabase; the static GitHub Pages web preview does **not** provide equivalent login or realtime social networking. Matching the visual UI does not imply backend parity, paid gifting, functional live voice, real uploads, public messaging, or unified accounts. Never display sample people/posts as real users. Implement age-appropriate safety, reporting and moderation before enabling user-generated content.

Android version: `0.6.0+22`. CI APK artifact: `MEWVIO-Social-v0.6.0-Unified-App-Web-APK`. Web deployments run `scripts/check_web_parity.js` before publishing.

## 0.6.1 Android creator hub layout fix

The native center-plus creator bottom sheet now scrolls inside available screen space, including smaller Android screens. The Flutter widget test dismisses the route using Navigator. Web and Android still share the same five primary mobile navigation destinations, artwork reference and copyright statement. App and Web are UI-aligned demos, not a shared production backend.
