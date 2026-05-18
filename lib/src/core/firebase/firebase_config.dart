import 'package:firebase_core/firebase_core.dart';

abstract final class FirebaseConfig {
  static const apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyBUTQotUyl0ln9uurekIzfr_NAj3Pi2oEA',
  );
  static const appId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:746888936470:web:195e1053ce4f73d0958937',
  );
  static const messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '746888936470',
  );
  static const projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'aniket-portfolio-91101',
  );
  static const authDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: 'aniket-portfolio-91101.firebaseapp.com',
  );
  static const storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'aniket-portfolio-91101.firebasestorage.app',
  );
  static const measurementId = String.fromEnvironment(
    'FIREBASE_MEASUREMENT_ID',
    defaultValue: 'G-QL2JL1B2BK',
  );
  static const contactEmailEndpoint = String.fromEnvironment(
    'CONTACT_EMAIL_ENDPOINT',
  );
  static const web3FormsAccessKey = String.fromEnvironment(
    'WEB3FORMS_ACCESS_KEY',
  );
  static const contactFirestoreEnabled = bool.fromEnvironment(
    'CONTACT_FIRESTORE_ENABLED',
    defaultValue: false,
  );

  static bool get isConfigured {
    return apiKey.isNotEmpty &&
        appId.isNotEmpty &&
        messagingSenderId.isNotEmpty &&
        projectId.isNotEmpty &&
        authDomain.isNotEmpty;
  }

  static FirebaseOptions get options {
    return const FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain: authDomain,
      storageBucket: storageBucket,
      measurementId: measurementId,
    );
  }
}
