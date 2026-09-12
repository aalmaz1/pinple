import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinple/app.dart';
import 'package:pinple/features/settings/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    final prefs = await SharedPreferences.getInstance();

    // Safe connection to Firebase
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    // Initialize Naver Map
    await FlutterNaverMap().init(
      clientId: 'num7515n0d',
      onAuthFailed: (ex) {
        debugPrint('NaverMap Auth Failed: $ex');
      },
    );

    runApp(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const PinpleApp(),
      ),
    );
  } catch (e) {
    debugPrint('Critical Init Error: $e');
    // Final fallback: try to run the app even if some inits failed
    runApp(
      ProviderScope(
        overrides: [], // Can't override without prefs, but let's try to show UI
        child: PinpleAppFallback(error: e.toString()),
      ),
    );
  }
}

class PinpleAppFallback extends StatelessWidget {
  final String error;
  const PinpleAppFallback({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Initialization Error',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(error, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => main(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
