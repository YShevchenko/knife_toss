import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/providers.dart';
import 'presentation/providers/settings_notifier.dart';
import 'presentation/screens/menu_screen.dart';

class KnifeTossApp extends ConsumerStatefulWidget {
  const KnifeTossApp({super.key});

  @override
  ConsumerState<KnifeTossApp> createState() => _KnifeTossAppState();
}

class _KnifeTossAppState extends ConsumerState<KnifeTossApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(progressProvider.notifier).load();

      // Wire IAP purchases -> stats + ads
      final stats = ref.read(progressProvider);
      if (stats.adsRemoved) {
        ref.read(adServiceProvider).setAdsRemoved(true);
      }

      ref.read(iapServiceProvider).addListener((productId, success) {
        if (success && productId == 'knife_toss_remove_ads') {
          ref.read(progressProvider.notifier).setAdsRemoved(true);
          ref.read(adServiceProvider).setAdsRemoved(true);
        }
      });

      // Wire sound setting -> audio service
      ref.read(audioServiceProvider).enabled =
          ref.read(settingsProvider).soundEnabled;
    });

    // Keep audio service in sync with settings
    ref.listenManual<SettingsState>(settingsProvider, (prev, next) {
      if (prev?.soundEnabled != next.soundEnabled) {
        ref.read(audioServiceProvider).enabled = next.soundEnabled;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Knife Toss',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: Locale(settings.locale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MenuScreen(),
    );
  }
}
