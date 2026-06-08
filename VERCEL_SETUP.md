# Vercel Deployment Setup Guide — RoadRobos

This guide covers every manual step needed to make RoadRobos work on Vercel.

---

## Step 1 — Set Environment Variables in Vercel

> **ISSUE-01**: The `.dart_defines` file is gitignored and never uploaded to Vercel.
> The `vercel-build.sh` script reads all keys from Vercel's own Environment Variables.

Go to: **Vercel Dashboard → Your Project → Settings → Environment Variables**

Add the following variables (set scope to **Production** and **Preview**):

| Variable | Description | Example Value |
|----------|-------------|---------------|
| `SUPABASE_URL` | Your Supabase project URL | `https://hxoncblbripckfuxijav.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase public anon key | `eyJhbGci...` (full JWT) |
| `GOOGLE_CLIENT_ID` | Google OAuth **web** client ID (from Google Cloud Console) | `372021446388-xxx.apps.googleusercontent.com` |
| `RAZORPAY_KEY_ID` | Razorpay key (`rzp_test_` or `rzp_live_`) | `rzp_live_xxxxxxxx` |
| `FIREBASE_API_KEY_WEB` | Firebase API key for the web platform | `AIzaSyD068jX...` |
| `SENTRY_DSN` | Sentry error tracking DSN | `https://xxx@o123.ingest.sentry.io/456` |
| `MAPS_API_KEY` | Google Maps key (optional — OSM works without one) | Leave blank for OSM |
| `ENV` | Build environment | `prod` |

> [!IMPORTANT]
> Do NOT copy these from `.dart_defines` into Vercel — use your actual production values.
> The `RAZORPAY_KEY_ID` on Vercel should be `rzp_live_...` not the test placeholder.

---

## Step 2 — Register Google OAuth Redirect URIs

> **ISSUE-03**: Google Sign-In fails with `redirect_uri_mismatch` if your Vercel domain
> is not registered in both Google Cloud Console and Supabase.

### A. Google Cloud Console
1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Navigate to **APIs & Services → Credentials**
3. Click your **OAuth 2.0 Client ID** (the Web type)
4. Under **Authorized redirect URIs**, add:
   ```
   https://YOUR-VERCEL-DOMAIN.vercel.app/login-callback
   ```
   Replace `YOUR-VERCEL-DOMAIN` with your actual Vercel project domain.
5. Also add your **custom domain** if you have one:
   ```
   https://www.yourapp.com/login-callback
   ```
6. Click **Save**.

### B. Supabase Dashboard
1. Go to your Supabase project → **Authentication → URL Configuration**
2. Under **Redirect URLs**, add:
   ```
   https://YOUR-VERCEL-DOMAIN.vercel.app/login-callback
   https://YOUR-VERCEL-DOMAIN.vercel.app/**
   ```
3. Click **Save**.

> [!TIP]
> For preview deployments (pull request previews), Vercel generates a unique URL per
> deployment. You can add a wildcard like `https://*.vercel.app/login-callback` to
> Supabase's allowed list to cover all previews.

---

## Step 3 — Add Firebase Web Config

Firebase on web reads config from `firebase_options.dart` which is compiled into the app.
The `FIREBASE_API_KEY_WEB` env var is used in the build. Ensure it matches your Firebase
project's Web API key exactly.

> [!NOTE]
> Firebase rules (`firestore.rules`, `storage.rules`) are not deployed by `vercel-build.sh`.
> Deploy them separately via the Firebase CLI:
> ```bash
> firebase deploy --only firestore:rules,storage
> ```

---

## Step 4 — Build and Deploy

Once all env vars are set, trigger a deployment:

```bash
# Option 1: Push to your connected Git branch (auto-deploys)
git push origin main

# Option 2: Manual deploy via Vercel CLI
npx vercel --prod
```

The `vercel-build.sh` script will:
1. Download Flutter SDK
2. Validate that `SUPABASE_URL` and `SUPABASE_ANON_KEY` are set (fails fast if missing)
3. Generate `.dart_defines` from Vercel env vars
4. Run `flutter build web --release`

---

## Vercel Checklist

- [ ] `SUPABASE_URL` set in Vercel → Production
- [ ] `SUPABASE_ANON_KEY` set in Vercel → Production
- [ ] `GOOGLE_CLIENT_ID` set in Vercel → Production (web OAuth client, not Android)
- [ ] `RAZORPAY_KEY_ID` set with live key in Vercel → Production
- [ ] `FIREBASE_API_KEY_WEB` set in Vercel → Production
- [ ] `SENTRY_DSN` set in Vercel → Production
- [ ] `ENV=prod` set in Vercel → Production
- [ ] Vercel domain added to Google Cloud OAuth redirect URIs
- [ ] Vercel domain added to Supabase → Authentication → Redirect URLs
- [ ] Firebase rules deployed via Firebase CLI (not Vercel)
- [ ] Test Google Sign-In on Vercel domain after deploy
- [ ] Test payment flow on Vercel domain (Razorpay modal should now open — ISSUE-02 fixed)
