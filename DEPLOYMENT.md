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

---

## Supabase Production Backup & Restore Procedure

RoadRobos uses Supabase as its primary backend datastore (PostgreSQL, Auth, and Storage). Securing and restoring these resources is critical for business continuity.

### 1. Automated Database Backups (Supabase Hosted)

Supabase manages automated daily physical backups of your database.
- **Availability**: Standard on Pro and Enterprise tiers (Staging and Production).
- **Retention**: 
  - **Pro Plan**: 7 days of daily history.
  - **Enterprise Plan**: 30 days of daily history.
- **Verification**: Go to **Supabase Dashboard → Database → Backups** to view the history of successfully completed daily backups.
- **Restore via Dashboard**:
  1. Navigate to **Database → Backups**.
  2. Choose the daily backup corresponding to the desired restore date.
  3. Click **Restore**. Note that this replaces the current database in-place. Ensure the app is placed in temporary maintenance mode before initiating.

### 2. Point-in-Time Recovery (PITR)

For production, standard physical backups are supplemented by **Point-in-Time Recovery (PITR)**.
- **What it does**: Logs every database transaction to write-ahead logs (WAL). This allows you to restore the database to any exact second in the retention window.
- **Setup**: Must be enabled in the project settings (**Dashboard → Project Settings → Add-ons → Point-in-Time Recovery**).
- **How to Restore**: 
  1. Open the restore drawer under the Backups section.
  2. Select **Point-in-Time Recovery**.
  3. Input the exact UTC timestamp to revert to.

### 3. Manual Database Backups (Supabase CLI)

In addition to automated cloud backups, manual logical backups must be taken before major database migrations or schema upgrades.

To perform a manual dump, install the Supabase CLI and run:

```bash
# 1. Log in to your Supabase account
supabase login

# 2. Dump Schema (contains table structures, policies, functions, triggers, etc.)
supabase db dump --project-ref hxoncblbripckfuxijav -f schema_backup.sql

# 3. Dump Data Only (logical insert statements for all table rows)
supabase db dump --project-ref hxoncblbripckfuxijav --data-only -f data_backup.sql

# 4. Full Dump (Both Schema and Data using pg_dump utility)
supabase db dump --project-ref hxoncblbripckfuxijav --use-go-pgdump -f full_production_backup.sql
```
*Note: Keep these backup files encrypted and stored securely in a private, access-controlled vault (e.g., S3 Glacier, Google Cloud Storage, or enterprise vault). Never commit them to Git.*

### 4. Manual Database Restore Procedure

To restore a manual logical backup (`full_production_backup.sql`) to your Supabase instance:

#### Option A: Via SQL Editor (For small data fixes)
1. Open the backup `.sql` file in a text editor.
2. Copy the relevant lines/inserts.
3. Paste them into the **Supabase Dashboard → SQL Editor** and click **Run**.

#### Option B: Via Command Line (Recommended for full restores)
Run the sql dump against the Supabase PostgreSQL connection pool directly using `psql` (the database password is required):

```bash
psql -h db.hxoncblbripckfuxijav.supabase.co -U postgres -d postgres -f full_production_backup.sql
```

#### Option C: Reset and Apply Migrations (For Staging/Dev sync)
If syncing a local/dev environment to match production schema:
```bash
# Apply all local migrations to the target database
supabase db push --project-ref hxoncblbripckfuxijav
```

### 5. Storage Buckets Backup & Restore

Supabase Storage files (e.g., `kyc-documents`, `delivery-proofs`) are **NOT** backed up by automated database backups. They must be backed up separately.

- **Backup via RClone**:
  Supabase storage endpoints are S3-compatible. You can use tools like `rclone` to sync buckets to an external secure backup location:
  ```bash
  rclone sync supabase-prod:kyc-documents s3-backup-vault:roadrobos-kyc-backups
  ```
- **Restore**:
  Re-sync the files back to the storage bucket folder using the same S3 interface.

