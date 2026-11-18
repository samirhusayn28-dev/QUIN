import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tally_counter/data/providers.dart';

void main() {
  group('history pagination', () {
    test('starts at one page and grows by a page at a time', () {
      final container = ProviderContainer.test();

      expect(container.read(historyPageLimitProvider), historyPageSize);

      container.read(historyPageLimitProvider.notifier).showMore();
      expect(container.read(historyPageLimitProvider), historyPageSize * 2);

      container.read(historyPageLimitProvider.notifier).showMore();
      expect(container.read(historyPageLimitProvider), historyPageSize * 3);

      container.read(historyPageLimitProvider.notifier).reset();
      expect(container.read(historyPageLimitProvider), historyPageSize);
    });
  });
}
