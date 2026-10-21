# MEWVIO 🐱💜

MEWVIO is a Flutter Android social app beta with Supabase email/password accounts and private profiles.

Registration, login, session restoration, profile editing and logout connect to Supabase. Profiles are visible only to their owner. The gallery cover-photo picker remains a local preview and does not upload photos. Chat, matching, voice rooms, videos and shopping remain demo features.

## Build Android APK

Push commits to `main` or run **Actions → Build MEWVIO Android APK → Run workflow**. When build succeeds, download the APK artifact from the workflow run.

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
