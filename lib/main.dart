import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'src/app.dart';
import 'src/core/firebase/firebase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  if (FirebaseConfig.isConfigured) {
    try {
      await Firebase.initializeApp(options: FirebaseConfig.options);
    } catch (error) {
      // The portfolio must still render if Firebase is unreachable.
      debugPrint('Firebase initialisation failed: $error');
    }
  }

  runApp(const PortfolioApp());
}
