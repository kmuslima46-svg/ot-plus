# OT PLUS — Flutter + Firebase starter project

This is a starter source project for the OT PLUS Android app:
- Pink/white clean UI
- Local overtime records stored with SQLite (`sqflite`)
- Monthly totals and OT calculation
- PLUS Jobs screens with Firebase Firestore integration points
- Firebase Auth and Firestore setup instructions

## Important
This is source code, not a built or tested APK. To run the online jobs feature, create a Firebase project and add your own Android Firebase configuration. Never publish service-account keys in the app.

## Requirements
- Flutter stable SDK
- Android Studio / Android SDK
- Firebase project
- FlutterFire CLI (recommended)

## Setup
1. Install Flutter and verify with `flutter doctor`.
2. In this folder, run `flutter create .` if platform folders are missing.
3. Run `flutter pub get`.
4. Create a Firebase project and register the Android app using package name `com.otplus.app`.
5. Install FlutterFire CLI and run `flutterfire configure`.
6. Enable Firebase Authentication (Email/Password for starter; phone auth can be added later).
7. Create a Cloud Firestore database.
8. Deploy `firebase/firestore.rules` using Firebase CLI.
9. Run `flutter run`.

## OT calculation
OT amount = (whole hours + extra minutes / 60) × hourly OT rate.
Example: 2 hours 30 minutes × ৳125/hour = ৳312.50.

Records are saved locally on this device. Cloud backup/sync for personal OT entries is not implemented in this starter.

## Online job posts
The app uses Firestore collection `jobs`. The UI includes sample fallback listings if Firebase is not configured; those are clearly labeled as demo content. Configure Firebase to use real posts.

Before production:
- Add phone/email verification and profile completion.
- Add moderation/reporting and employer verification.
- Add pagination, indexes, spam prevention, and admin tools.
- Review security rules and privacy/legal requirements.
- Test on real devices and build a release APK/AAB.


## Build an APK online with GitHub Actions

This repository includes `.github/workflows/build-apk.yml`. To build:
1. Upload/unzip this project into a new GitHub repository (include hidden `.github` folder).
2. Open the repository's **Actions** tab and enable Actions if prompted.
3. Choose **Build OT PLUS Android APK** → **Run workflow**.
4. Wait for the workflow to finish successfully.
5. Open the completed run, then download the `ot-plus-debug-apk` artifact.
6. Extract the artifact ZIP and install `app-debug.apk` on an Android device.

This creates a debug APK for testing, not a signed Play Store release. The online Firebase jobs feature still requires your own Firebase project and Android configuration; a build alone does not activate cloud services.
