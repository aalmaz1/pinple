import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinple/app.dart';
import 'package:pinple/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Client ID via --dart-define=NAVER_MAP_CLIENT_ID=xxx , fallback for local dev
  const naverClientId = String.fromEnvironment(
    'NAVER_MAP_CLIENT_ID',
    defaultValue: 'num7515n0d',
  );

  await FlutterNaverMap().init(
    clientId: naverClientId,
    onAuthFailed: (ex) {
      debugPrint('===== NaverMap auth failed =====');
      debugPrint('type: ${ex.runtimeType}');
      debugPrint('message: $ex');
      debugPrint('================================');
    },
  );

  runApp(
    const ProviderScope(
      child: PinpleApp(),
    ),
  );
}
