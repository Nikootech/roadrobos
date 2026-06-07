# roadrobos

RoAdRoBos - Vehicle Service & Ride Booking App (Flutter)

# roadrobos

RoAdRoBos - Vehicle Service & Ride Booking App (Flutter)

## Getting Started

### Prerequisites
- Flutter SDK >=3.3.4
- A `.dart_defines` file at the project root (see `.dart_defines.example`)

### Running the app

```bash
flutter run --dart-define-from-file=.dart_defines
```

### Building a release APK

> **Note:** To build a signed release APK locally, you must have `android/key.properties` and the `upload-keystore.jks` file on your disk. Do not commit these files!
> If you don't have them, copy `android/dev.key.properties.template` to `android/key.properties` and obtain the keystore and password from your lead engineer.

```bash
flutter build apk --dart-define-from-file=.dart_defines
```

> **Note:** Never commit `.dart_defines` or `.env` to version control. These contain API keys and secrets.

## Resources

- [Flutter documentation](https://docs.flutter.dev/)
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

## CI/CD Deployment

To enable GitHub Actions CI/CD workflows, you must set the following **Repository Secrets** in your GitHub repository settings (Settings > Secrets and variables > Actions):

- SUPABASE_URL: Your Supabase project URL
- SUPABASE_ANON_KEY: Your Supabase anon key
- RAZORPAY_KEY_ID: Your Razorpay Key ID (Test or Live)
- GOOGLE_CLIENT_ID: Your Google OAuth Client ID
- MAPS_API_KEY: Your Google Maps API Key
- FIREBASE_APP_ID: Firebase App ID for App Distribution (e.g., 1:1234567890:android:abcdef123456)
- CREDENTIAL_FILE_CONTENT: The contents of your Firebase Service Account JSON key file.
- ANDROID_KEYSTORE_PASSWORD: The keystore password (e.g. roadrobos_secure_2026)
- ANDROID_KEY_PASSWORD: The key password (e.g. roadrobos_secure_2026)
- ANDROID_KEY_ALIAS: The key alias (e.g. upload)
- ANDROID_KEYSTORE_BASE64: The base64-encoded string of the upload-keystore.jks file
