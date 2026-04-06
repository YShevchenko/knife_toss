import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'data/repositories/prefs_progress_repository.dart';
import 'presentation/providers/providers.dart';
import 'presentation/providers/progress_notifier.dart';
import 'presentation/providers/settings_notifier.dart';
import 'services/iap_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Dark status bar for Neon Void theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  final prefs = await SharedPreferences.getInstance();

  final iapService = IAPService();
  try { await iapService.initialize(); } catch (_) {}

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        iapServiceProvider.overrideWithValue(iapService),
        // Wire internal providers used by notifiers
        progressRepoInternalProvider.overrideWith((ref) {
          return PrefsProgressRepository(prefs);
        }),
        sharedPrefsInternalProvider.overrideWithValue(prefs),
      ],
      child: const KnifeTossApp(),
    ),
  );
}
