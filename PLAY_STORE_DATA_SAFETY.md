# Play Store Data Safety — RoadRobos

This document maps every data type collected by RoadRobos to the exact fields in the **Google Play Store Data Safety** form (available in Play Console → App content → Data safety).

---

## Section 1: Does your app collect or share any of the required user data types?

**YES**

---

## Section 2: Is all of the user data collected by your app encrypted in transit?

**YES** — All data is transmitted over TLS 1.2+.

---

## Section 3: Do you provide a way for users to request that their data is deleted?

**YES** — Via **Settings → Privacy → Delete My Account** in-app, or by emailing privacy@roadrobos.com.

---

## Section 4: Data Types Collected & Shared

Fill in the Play Console Data Safety form using the table below. For each data type, check the corresponding boxes.

### 📍 Location

| Field | Value |
|-------|-------|
| **Data type** | Precise location |
| **Collected?** | ✅ Yes |
| **Shared?** | ✅ Yes (Google Maps Platform — for routing only) |
| **Required or optional?** | Required (core app functionality — cannot book a ride without location) |
| **Processed ephemerally?** | No — location is stored for trip records |
| **Purpose(s)** | App functionality, Fraud prevention, Security |

| Field | Value |
|-------|-------|
| **Data type** | Approximate location |
| **Collected?** | No |

---

### 👤 Personal Info

| Field | Value |
|-------|-------|
| **Data type** | Name |
| **Collected?** | ✅ Yes |
| **Shared?** | ✅ Yes (shown to driver/rider in-trip; Supabase sub-processor) |
| **Required or optional?** | Required |
| **Purpose(s)** | App functionality, Account management |

| Field | Value |
|-------|-------|
| **Data type** | Email address |
| **Collected?** | ✅ Yes (optional at sign-up) |
| **Shared?** | No (internal only) |
| **Required or optional?** | Optional |
| **Purpose(s)** | Account management, App functionality |

| Field | Value |
|-------|-------|
| **Data type** | User IDs |
| **Collected?** | ✅ Yes (internal UUID) |
| **Shared?** | ✅ Yes (Firebase — for push notification targeting) |
| **Required or optional?** | Required |
| **Purpose(s)** | App functionality |

| Field | Value |
|-------|-------|
| **Data type** | Phone number |
| **Collected?** | ✅ Yes |
| **Shared?** | ✅ Yes (shown to driver/rider during active trip only; Supabase) |
| **Required or optional?** | Required |
| **Purpose(s)** | App functionality, Account management |

| Field | Value |
|-------|-------|
| **Data type** | Address |
| **Collected?** | ✅ Yes (pickup/drop-off addresses from Maps search) |
| **Shared?** | ✅ Yes (driver; Google Maps Platform) |
| **Required or optional?** | Required |
| **Purpose(s)** | App functionality |

---

### 💳 Financial Info

| Field | Value |
|-------|-------|
| **Data type** | Purchase history |
| **Collected?** | ✅ Yes (trip payment records) |
| **Shared?** | ✅ Yes (Razorpay — payment processor) |
| **Required or optional?** | Required |
| **Purpose(s)** | App functionality, Account management |

| Field | Value |
|-------|-------|
| **Data type** | Credit/debit card numbers |
| **Collected?** | ❌ No — handled entirely by Razorpay's PCI-DSS vault; we store only payment tokens |
| **Shared?** | N/A |

---

### 💬 Messages

| Field | Value |
|-------|-------|
| **Data type** | In-app messages |
| **Collected?** | ✅ Yes (in-app chat between user and support) |
| **Shared?** | No (internal only; stored in Supabase) |
| **Required or optional?** | Optional (support feature) |
| **Purpose(s)** | App functionality |

---

### 📸 Photos and Videos

| Field | Value |
|-------|-------|
| **Data type** | Photos |
| **Collected?** | ✅ Yes (profile picture, KYC documents, vehicle images) |
| **Shared?** | No (stored privately in Supabase Storage with access controls) |
| **Required or optional?** | Optional for customers / Required for drivers & technicians |
| **Purpose(s)** | App functionality, Fraud prevention, Security |

---

### 📁 Files and Docs

| Field | Value |
|-------|-------|
| **Data type** | Files and docs |
| **Collected?** | ✅ Yes (KYC documents: Aadhaar, PAN, DL, RC — drivers/technicians only) |
| **Shared?** | No (private Supabase Storage bucket; admin review only) |
| **Required or optional?** | Required for partner onboarding |
| **Purpose(s)** | App functionality, Fraud prevention, Security |

---

### 📱 App Activity

| Field | Value |
|-------|-------|
| **Data type** | App interactions |
| **Collected?** | ✅ Yes (screens viewed, features tapped — Firebase Analytics) |
| **Shared?** | ✅ Yes (Firebase/Google) |
| **Required or optional?** | Required (analytics) |
| **Purpose(s)** | Analytics, App functionality |

| Field | Value |
|-------|-------|
| **Data type** | Crash logs |
| **Collected?** | ✅ Yes (Firebase Crashlytics + Sentry) |
| **Shared?** | ✅ Yes (Firebase/Google, Sentry) |
| **Required or optional?** | Required |
| **Purpose(s)** | App functionality (debugging) |

| Field | Value |
|-------|-------|
| **Data type** | Diagnostics |
| **Collected?** | ✅ Yes (performance data, ANRs — Firebase Performance) |
| **Shared?** | ✅ Yes (Firebase/Google) |
| **Required or optional?** | Required |
| **Purpose(s)** | App functionality |

---

### 🆔 Device or Other IDs

| Field | Value |
|-------|-------|
| **Data type** | Device or other IDs (FCM token, installation ID) |
| **Collected?** | ✅ Yes |
| **Shared?** | ✅ Yes (Firebase — for push notification delivery) |
| **Required or optional?** | Required |
| **Purpose(s)** | App functionality (notifications), Fraud prevention |

---

## Section 5: Security Practices (checkboxes in Play Console)

- ✅ **Data is encrypted in transit** — TLS 1.2+
- ✅ **You provide a way for users to request data deletion**
- ❌ **Data is collected from apps on your list** — Not applicable (no SDK sold to third parties)
- ❌ **Independent security review** — Not yet (consider completing a MASA audit before launch)

---

## Section 6: Privacy Policy URL

Enter your hosted privacy policy URL:

```
https://roadrobos.com/privacy
```

> [!IMPORTANT]
> This URL **must be live and publicly accessible** before submitting the app for review. Google reviewers visit this link. If the page returns a 404 or requires login, the submission will be rejected.

---

## Notes for the Form Reviewer

- Razorpay is a **payment processor**, not a data buyer — declare it as a "service provider" when prompted.
- Firebase / Google sub-processors should be listed as "service providers" not "data brokers".
- Location data collected in the background should be declared as "background location" is **not collected** unless the user is an active driver mid-trip (ephemeral session scope). For the Play Store form, declare **Precise Location** with "Background" checked, since background permission is requested from driver users.
