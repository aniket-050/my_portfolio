# Production Deployment

This portfolio is deploy-ready for Firebase Hosting with Firebase Auth,
Firestore and Storage.

## 1. Create Firebase Project

1. Create a Firebase project on the Spark plan.
2. Enable Authentication > Email/Password.
3. Create your admin user in Authentication.
4. Enable Firestore Database.
5. Enable Storage.

## 2. Add Admin Allowlist

Create this document in Firestore:

Path: `admins/{ADMIN_USER_UID}`

Data:

```json
{
  "email": "your-admin-email@example.com",
  "role": "owner"
}
```

Only users listed in `admins/{uid}` can edit website content.

## 3. Configure App

Run with your Firebase web app values:

```sh
flutter run -d chrome \
  --dart-define=FIREBASE_API_KEY=xxx \
  --dart-define=FIREBASE_APP_ID=xxx \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=xxx \
  --dart-define=FIREBASE_PROJECT_ID=xxx \
  --dart-define=FIREBASE_AUTH_DOMAIN=xxx.firebaseapp.com \
  --dart-define=FIREBASE_STORAGE_BUCKET=xxx.appspot.com
```

Build:

```sh
flutter build web --release \
  --dart-define=FIREBASE_API_KEY=xxx \
  --dart-define=FIREBASE_APP_ID=xxx \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=xxx \
  --dart-define=FIREBASE_PROJECT_ID=xxx \
  --dart-define=FIREBASE_AUTH_DOMAIN=xxx.firebaseapp.com \
  --dart-define=FIREBASE_STORAGE_BUCKET=xxx.appspot.com
```

## 4. Contact Email

For direct inbox delivery, configure at least one option below.

Option A: Provide a secure backend endpoint:

```sh
--dart-define=CONTACT_EMAIL_ENDPOINT=https://your-worker-or-form-endpoint.example.com
```

Option B: Use Web3Forms (quickest for static websites):

```sh
--dart-define=WEB3FORMS_ACCESS_KEY=your_web3forms_access_key
```

Optional: Save inquiries to Firestore as a secondary store (disabled by default):

```sh
--dart-define=CONTACT_FIRESTORE_ENABLED=true
```

Recommended options:

- Cloudflare Workers free tier with Resend or another email provider.
- Web3Forms access key flow.

Do not put private email API keys in Flutter code. Use a server-side endpoint.

## 5. Deploy

```sh
npm install -g firebase-tools
firebase login
cp .firebaserc.example .firebaserc
# edit .firebaserc with your Firebase project id
firebase deploy --only hosting,firestore:rules,storage
```

## Security Notes

- Admin route has no visible public button and requires Firebase Auth.
- Firestore writes to website content are admin-only.
- Contact submissions are create-only, validated and not readable publicly.
- Storage uploads are admin-only and restricted to images under 5 MB.
- Firebase Hosting sends security headers from `firebase.json`.
- No frontend app can guarantee zero attacks. Keep Firebase rules deployed,
  use strong unique admin passwords and enable MFA on the Google/Firebase
  account.
