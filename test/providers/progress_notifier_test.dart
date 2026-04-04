import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:knife_toss/presentation/providers/progress_notifier.dart';
import 'package:knife_toss/presentation/providers/providers.dart';

void main() {
  group('ProgressNotifier', () {
    test('should provide initial state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(progressProvider);
      
      expect(state, isNotNull);
    });

    test('notifier should be accessible', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(progressProvider.notifier);
      
      expect(notifier, isA<ProgressNotifier>());
    });

    // TODO: Add specific tests for ProgressNotifier methods
  });
}
