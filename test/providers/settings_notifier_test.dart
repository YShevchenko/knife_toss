import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:knife_toss/presentation/providers/settings_notifier.dart';
import 'package:knife_toss/presentation/providers/providers.dart';

void main() {
  group('SettingsNotifier', () {
    test('should provide initial state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(settingsProvider);
      
      expect(state, isNotNull);
    });

    test('notifier should be accessible', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(settingsProvider.notifier);
      
      expect(notifier, isA<SettingsNotifier>());
    });

    // TODO: Add specific tests for SettingsNotifier methods
  });
}
