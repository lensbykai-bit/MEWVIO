# MEWVIO 🐱💜

MEWVIO is a Flutter Android social app prototype with short video, chat, matching, voice rooms and profile screens.

This is a Stage 1 prototype. Chat, matching and voice rooms do **not** connect to real users yet.

## Build Android APK

Push commits to `main` or run **Actions → Build MEWVIO Android APK → Run workflow**. When build succeeds, download the APK artifact from the workflow run.

## Local setup

```bash
flutter pub get
flutter create --platforms=android .
flutter build apk --debug
```

## Safety

Before any public social launch, implement age-appropriate policies, authentication, abuse reporting, blocking, moderation, privacy and content review.
