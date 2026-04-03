import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/prefs_progress_repository.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/player_stats.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../services/ad_service.dart';
import '../../services/audio_service.dart';
import '../../services/iap_service.dart';
import 'game_notifier.dart';
import 'progress_notifier.dart';
import 'settings_notifier.dart';

// -- Foundation --

/// Must be overridden in main() via ProviderScope(overrides: [...]).
final sharedPrefsProvider = Provider<SharedPreferences>((_) {
  throw UnimplementedError(
    'sharedPrefsProvider must be overridden with an actual SharedPreferences '
    'instance before the app starts.',
  );
});

// -- Repositories --

final progressRepoProvider = Provider<ProgressRepository>((ref) {
  return PrefsProgressRepository(ref.watch(sharedPrefsProvider));
});

// -- Services --

final adServiceProvider = Provider<AdServiceBase>((_) {
  return AdService();
});

final iapServiceProvider = Provider<IAPServiceBase>((_) {
  return IAPService();
});

final audioServiceProvider = Provider<AudioService>((_) {
  return AudioService();
});

// -- State notifiers --

final progressProvider =
    NotifierProvider<ProgressNotifier, PlayerStats>(() {
  return ProgressNotifier();
});

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});

final gameProvider =
    NotifierProvider<GameNotifier, GameState?>(() {
  return GameNotifier();
});
