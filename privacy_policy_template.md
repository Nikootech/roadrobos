# Privacy Policy — RoadRobos

**Effective Date**: [DD Month YYYY]  
**Last Updated**: [DD Month YYYY]

---

This Privacy Policy describes how **RoadRobos Technologies Pvt. Ltd.** ("RoadRobos", "we", "us", or "our") collects, uses, stores, and shares your personal data when you use the RoadRobos mobile application ("App") and related services for vehicle ride-booking, roadside assistance, vehicle servicing, and goods delivery.

By using the App, you agree to the collection and use of information in accordance with this Policy. If you do not agree, please discontinue use of the App.

---

## 1. Data We Collect, Why We Collect It & How Long We Keep It

| Data Type | What We Collect | Purpose | Legal Basis | Retention Period |
|-----------|----------------|---------|-------------|-----------------|
| **Name** | First and last name | Account creation, identity verification, communication | Contract performance | Duration of account + 3 years |
| **Phone Number** | Mobile number with country code | OTP-based login, ride notifications, driver–rider communication | Contract performance | Duration of account + 3 years |
| **Email Address** | Email address (optional) | Account recovery, invoices, support | Legitimate interest | Duration of account + 3 years |
| **Precise Location** | GPS coordinates (foreground & background) | Matching riders with nearby drivers, real-time trip tracking, navigation, ETA calculation | Contract performance | Trip records: 3 years; Raw location logs: 90 days |
| **Payment Information** | Card/UPI/wallet tokens (not raw card numbers — processed via Razorpay PCI-DSS vault) | Processing payments and refunds | Contract performance | Transaction records: 7 years (GST compliance) |
| **KYC Documents** | Driver's licence, vehicle registration certificate (RC), Aadhaar/PAN (driver/technician only) | Partner identity verification and regulatory compliance | Legal obligation | Duration of active partnership + 7 years |
| **Profile Photo** | User-uploaded profile picture | In-app identity display | Consent | Until account deletion |
| **Vehicle Photos** | Images of the partner's vehicle | Partner verification, damage documentation | Contract performance | Duration of active partnership + 3 years |
| **Device Information** | Device model, OS version, app version, IP address, crash logs | Analytics, debugging, fraud prevention | Legitimate interest | 13 months |
| **Usage Data** | Screens visited, features used, session duration | App improvement, personalisation | Legitimate interest | 13 months |
| **Biometric Data** | Face ID / fingerprint authentication result (processed on-device; we never receive raw biometric data) | Quick secure login | Consent | Not stored on our servers |
| **Chat Messages** | In-app messages between users and support | Customer support resolution | Contract performance | 6 months after ticket closure |
| **Ratings & Feedback** | Star ratings and written reviews | Service quality improvement | Legitimate interest | Duration of account |
| **Financial Earnings** | Driver/technician payout records | Payment disbursement, tax records | Legal obligation | 7 years |

---

## 2. How We Use Your Data

- **Service Delivery**: Match riders with drivers, dispatch technicians, process payments, generate invoices.
- **Safety & Trust**: KYC verification for drivers/technicians, fraud detection, SOS alerts.
- **Communications**: Booking confirmations, status updates, promotional offers (opt-out available in Settings → Notifications).
- **Legal Compliance**: GST, TDS, and other statutory reporting obligations under Indian law.
- **Product Improvement**: Aggregate analytics to improve app features, pricing algorithms, and route optimisation.

We do **not** sell your personal data to third parties.

---

## 3. Data Sharing — Third-Party Processors

We share your data only with trusted sub-processors under strict data processing agreements:

| Processor | Data Shared | Purpose | Region |
|-----------|-------------|---------|--------|
| **Supabase** | All user data (database & storage) | Backend infrastructure | EU (Frankfurt) |
| **Razorpay** | Payment tokens, transaction amounts | Payment processing | India |
| **Firebase (Google)** | Device tokens, crash reports, analytics events | Push notifications, crash analytics | USA |
| **Sentry** | Anonymised error logs, stack traces | Error monitoring | USA |
| **Google Maps Platform** | Location queries | Map rendering, geocoding, routing | USA |

All international transfers to the USA/EU are governed by standard contractual clauses (SCCs) or adequacy decisions. Supabase (EU region) and Razorpay (India) process data within or equivalent to India's data localisation requirements.

---

## 4. Location Data — Special Notice

- **Foreground location** is used when the app is open to display your position on the map, find nearby services, and calculate fares.
- **Background location** (Android only, with explicit permission) is used **only while a trip is active** to provide continuous navigation and allow the other party to track the trip's progress.
- We **do not** collect location when no trip is active and no background permission is active.

---

## 5. Cookies & Analytics

The App uses Firebase Analytics (Google) with anonymised user identifiers. Analytics data is aggregated and does not identify individual users. You may opt out via **Settings → Privacy → Analytics** in the App.

---

## 6. Data Security

- All data in transit is encrypted with TLS 1.2 or higher.
- Sensitive fields (encryption keys, tokens) are stored in device-level secure storage (`flutter_secure_storage`).
- KYC documents are stored in a private, access-controlled Supabase storage bucket with row-level security policies.
- Payment card data is **never stored on our servers** — Razorpay's PCI-DSS Level 1 vault is used.
- The App uses AES-256-GCM encryption for locally cached sensitive data.

---

## 7. Children's Privacy

The App is **not intended for users under 18 years of age**. We do not knowingly collect personal data from children under 18. If you believe we have inadvertently collected such data, please contact us immediately at [support email] so we can delete it.

---

## 8. Your Rights

Under India's **Digital Personal Data Protection (DPDP) Act, 2023**, and applicable international privacy laws, you have the right to:

- **Access** the personal data we hold about you.
- **Correction** of inaccurate or outdated data.
- **Erasure** ("right to be forgotten") — request deletion of your account and associated data, subject to statutory retention obligations.
- **Grievance Redressal** — raise a complaint with our Data Protection Officer.
- **Nomination** — nominate a person to exercise rights on your behalf in the event of death or incapacity.

To exercise these rights, use the **Settings → Privacy → Delete My Account** flow in the App, or email us at **privacy@roadrobos.com**.

---

## 9. Data Retention & Deletion

- You may request account deletion at any time via the App.
- Upon deletion, your personal profile, location history, and usage data will be erased within **30 days**.
- Certain records (financial transactions, KYC documents) are retained for **7 years** as required by Indian tax and regulatory law and cannot be deleted on request during this period.
- Anonymised, aggregated analytics data is not subject to deletion requests.

---

## 10. Changes to This Policy

We may update this Privacy Policy periodically. Material changes will be communicated via an in-app notification and email (if provided). Continued use of the App after changes constitutes acceptance of the updated Policy. The "Last Updated" date at the top reflects the latest revision.

---

## 11. Contact Us — Data Protection Officer

**RoadRobos Technologies Pvt. Ltd.**  
Grievance Officer / Data Protection Officer  
Email: **privacy@roadrobos.com**  
Address: [Registered Office Address], India  

For complaints under the DPDP Act, you may also approach India's **Data Protection Board** at [dpboard.gov.in](https://dpboard.gov.in) once operational.

---

*This policy is governed by the laws of India. Any disputes shall be subject to the exclusive jurisdiction of courts in [City], India.*
