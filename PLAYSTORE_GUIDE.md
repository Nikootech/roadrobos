# 🚀 Google Play Store Build Guide

This guide explains how to build the release App Bundle (`.aab`) for the RoadRobos app directly from VS Code, without needing Android Studio.

## Prerequisites

Ensure you have your keystore set up.

1. You must have your keystore file (e.g., `roadrobos-keystore.jks`) inside the `android/app/` directory.
2. You must have a `key.properties` file inside the `android/` directory with the following structure:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=key0
storeFile=roadrobos-release.jks
```

> **⚠️ Security Warning:** Never commit `key.properties` or your `.jks` keystore file to GitHub. Add them to your `.gitignore` file to keep your app secure!

## How to Build the App Bundle

Whenever you are ready to create a new release for the Google Play Store, open your VS Code terminal and run this single command:

```bash
flutter build appbundle --release
```

## Where is the file?

Once the build finishes successfully, Flutter will generate your App Bundle. You can find it at this exact path on your computer:

📁 `e:\roadrobosapp\android app\android\app\release\app-release.aab`

> **Note:** Every time you run `flutter build appbundle --release`, the new file will be saved to this same path, overwriting the previous one.

## Next Steps

1. Open your web browser and go to the **Google Play Console**.
2. Navigate to your app's **Production** or **Testing** track.
3. Click **Create new release**.
4. Drag and drop the `app-release.aab` file into the upload box.
5. Save, review, and roll out your update!
