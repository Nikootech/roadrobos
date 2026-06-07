# RoadRobos Deployment Guide

This document covers building RoadRobos for production, how to securely inject secrets and API keys at build time, how to manage Android release signing, and how to submit to both the Google Play Store and Apple App Store.

---

## Security Architecture

We **never** commit production secrets to version control. This includes:
- Supabase API keys and URLs
- Razorpay API keys
- Google Maps API keys
- Sentry DSNs
- Firebase API keys (Web, Android, iOS)

Instead, we use Dart's `--dart-define-from-file` feature to inject these values at compile time.

---

## Setting up your Environment

1. Look at the `.dart_defines.example.json` file in the root of the project.
2. Ask your team lead or check your password manager for the production credentials.
3. Create a file named `.env.production` based on the example — this file is gitignored.

Your `.env.production` file should look like this:

```json
{
  "ENV": "prod",
  "SUPABASE_URL": "https://...",
  "SUPABASE_ANON_KEY": "...",
  "SUPABASE_SERVICE_KEY": "...",
  "GOOGLE_CLIENT_ID": "...",
  "RAZORPAY_KEY_ID": "rzp_live_...",
  "MAPS_API_KEY": "AIzaSy...",
  "SENTRY_DSN": "https://...",
  "FIREBASE_API_KEY_WEB": "AIzaSy...",
  "FIREBASE_API_KEY_ANDROID": "AIzaSy...",
  "FIREBASE_API_KEY_IOS": "AIzaSy..."
}
```

> [!WARNING]
> Ensure your environment file is **never** committed to version control. The `.gitignore` is already set up to ignore `.env`, `.env.*`, and `*.json` (except specific allowed ones), but always double-check before committing.

---

## Android Release Signing

### Generating a Keystore (One-time Setup)

```bash
keytool -genkey -v \
  -keystore roadrobos-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

> [!CAUTION]
> **Back up your keystore file and passwords securely.** If you lose the keystore, you will **not** be able to publish updates to the same Play Store listing. Google cannot help recover a lost keystore.

Store the generated `.jks` file in a secure location (e.g., 1Password, AWS Secrets Manager, or a private CI/CD secret). **Never commit it to Git.**

### Local Developer Setup

Create `android/key.properties` (already gitignored in `android/.gitignore`):

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/path/to/roadrobos-release.jks
```

The `android/app/build.gradle` is already configured to fall back to this file for local builds.

### CI/CD Environment Variables

For CI/CD pipelines (GitHub Actions, Bitrise, Codemagic), set these environment variables instead of committing `key.properties`:

| Variable | Description |
|----------|-------------|
| `KEYSTORE_PATH` | Absolute path to the `.jks` file on the CI runner |
| `KEY_ALIAS` | Keystore alias (e.g., `upload`) |
| `KEY_PASSWORD` | Key password |
| `STORE_PASSWORD` | Store password |

The `android/app/build.gradle` `signingConfigs.release` block already reads all 4 variables via `System.getenv()`.

#### Example: GitHub Actions Workflow Snippet

```yaml
- name: Decode Keystore
  run: |
    echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > $RUNNER_TEMP/roadrobos-release.jks

- name: Build App Bundle
  env:
    KEYSTORE_PATH: ${{ runner.temp }}/roadrobos-release.jks
    KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
    KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
    STORE_PASSWORD: ${{ secrets.STORE_PASSWORD }}
  run: |
    flutter build appbundle --release --dart-define-from-file=.env.production
```

---

## Building for Production

Once you have your environment file ready, build the application using the `--dart-define-from-file` flag.

### Android APK (for testing / sideloading)
```bash
flutter build apk --release --dart-define-from-file=.env.production
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release --dart-define-from-file=.env.production
```
Output: `build/app/outputs/bundle/release/app-release.aab`

> [!IMPORTANT]
> Upload the `.aab` (App Bundle), not the `.apk`, to the Google Play Console. Google Play will generate optimised APKs for each device configuration automatically.

### iOS (for App Store)
```bash
flutter build ipa --release --dart-define-from-file=.env.production
```
Output: `build/ios/ipa/*.ipa`

Prerequisites for iOS build:
- macOS with Xcode 15+
- Active Apple Developer account membership
- Provisioning profiles configured in Xcode / Apple Developer Portal
- Certificates installed in the macOS Keychain

### Web
```bash
flutter build web --release --dart-define-from-file=.env.production
```

---

## Running Locally against Production

If you need to test the production environment locally:
```bash
flutter run --dart-define-from-file=.env.production
```

---

## Firebase Options Note

The `lib/firebase_options.dart` file has been manually modified to read its API keys using `String.fromEnvironment`.

> [!CAUTION]
> If you run `flutterfire configure`, it will overwrite `lib/firebase_options.dart` with hardcoded keys again. You will need to manually revert those lines to use `String.fromEnvironment('FIREBASE_API_KEY_...')` before committing, or the CI secrets audit will fail.

---

## Regenerating App Icons & Splash Screens

If you update the app icon (`assets/app_icon.png`) or splash configuration, regenerate the platform assets:

```bash
# Regenerate launcher icons (Android, iOS, Web)
dart run flutter_launcher_icons

# Regenerate native splash screens (Android, iOS, Web)
dart run flutter_native_splash:create
```

---

## Play Store Submission Checklist

- [ ] `android/app/build.gradle`: `applicationId` set to `com.roadrobos.roadrobos`
- [ ] `android/app/build.gradle`: `compileSdk 34`, `minSdk 21`, `targetSdk 34`
- [ ] `android/app/build.gradle`: `minifyEnabled true`, `shrinkResources true`
- [ ] Release signing configured via env vars (`KEYSTORE_PATH`, `KEY_ALIAS`, `KEY_PASSWORD`, `STORE_PASSWORD`)
- [ ] `pubspec.yaml`: `version` is updated (e.g., `1.0.1+3`)
- [ ] App Bundle (`.aab`) built with `--release` flag
- [ ] Privacy Policy URL live at `https://roadrobos.com/privacy`
- [ ] Data Safety form completed in Play Console (see `PLAY_STORE_DATA_SAFETY.md`)
- [ ] App content rating questionnaire completed in Play Console
- [ ] Target audience & content settings configured
- [ ] Store listing: screenshots for phone, 7-inch tablet, 10-inch tablet
- [ ] Feature graphic (1024 × 500 px) uploaded
- [ ] App icon (512 × 512 px) uploaded to Play Console
- [ ] Short description (≤ 80 chars) and full description (≤ 4000 chars) filled in
- [ ] Contact details (email) set on store listing

---

## App Store (iOS) Submission Checklist

- [ ] `ios/Runner/Info.plist`: All permission strings present (NSLocation, NSCamera, NSPhotoLibrary, NSFaceID)
- [ ] `ios/Runner/Info.plist`: `CFBundleDisplayName` = `RoadRobos`
- [ ] `CFBundleShortVersionString` matches pubspec version
- [ ] Bundle identifier matches App Store Connect entry
- [ ] App icons generated for all sizes (`dart run flutter_launcher_icons` with `remove_alpha_ios: true`)
- [ ] Native splash screens regenerated
- [ ] IPA built with `--release` flag
- [ ] App uploaded via Xcode Organiser or `xcrun altool` / `xcrun notarytool`
- [ ] Privacy Policy URL set in App Store Connect
- [ ] App Privacy Nutrition Labels completed in App Store Connect (mirrors Data Safety form)
- [ ] Age rating questionnaire completed
- [ ] Screenshots for iPhone 6.5" and 5.5" (minimum), iPad if applicable
- [ ] App preview videos (optional but recommended)
- [ ] Release notes / "What's New" written for this version

---

## Version Bump Procedure

1. Update `version` in `pubspec.yaml` — format: `major.minor.patch+buildNumber`
   ```yaml
   version: 1.0.1+3   # version name: 1.0.1, build number: 3
   ```
2. Rebuild icons and splash if assets changed.
3. Run a clean build: `flutter clean && flutter pub get`
4. Build the release artifact (APK/AAB/IPA).
5. Tag the Git commit: `git tag v1.0.1`
