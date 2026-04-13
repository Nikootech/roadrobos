# How to Run RoadRobos in VS Code

This guide explains how to properly run and debug the RoadRobos application during development.

## 🚀 Running the App

### Option 1: Using VS Code (Recommended)
1. Open the project folder in VS Code.
2. Ensure you have the **Flutter** and **Dart** extensions installed.
3. Open the **Run and Debug** view (`Ctrl+Shift+D`).
4. Select your target device from the bottom status bar (e.g., Chrome, Android Emulator, or iOS Simulator).
5. Press **F5** or click the **Start Debugging** play button.

### Option 2: Using Terminal
Run the following command in the root directory:
```bash
flutter run -d chrome --web-port 8081
```

---

## 🛠️ Required Setup (Web Platform)

If you are running on **Chrome (Web)**, you must configure Google Sign-In:

1. **Google Client ID**:
   Open `web/index.html` and ensure the following meta tag exists inside the `<head>` section:
   ```html
   <meta name="google-signin-client_id" content="YOUR_CLIENT_ID.apps.googleusercontent.com">
   ```
   *Replace `YOUR_CLIENT_ID` with your actual Client ID from the [Google Cloud Console](https://console.cloud.google.com/).*

2. **Supabase Config**:
   Ensure your `.env` file is present in the root directory with:
   ```env
   SUPABASE_URL=your_project_url
   SUPABASE_ANON_KEY=your_anon_key
   ```

---

## ❓ Troubleshooting

### "Failed to initialize GoogleSignIn"
If you see this error, it means the `google-signin-client_id` meta tag is missing or incorrect in `web/index.html`. 

### "Connection refused" on Port 8081
If port 8081 is busy, you can change it in the command or in `.vscode/launch.json`.

### Firebase / Supabase Conflicts
Ensure you have run the following if you added new dependencies:
```bash
flutter pub get
```
