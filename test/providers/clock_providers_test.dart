import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sanathana_dharma_clock/providers/clock_providers.dart';
import 'package:sanathana_dharma_clock/providers/location_providers.dart';
import 'package:sanathana_dharma_clock/services/location_resolver.dart';
import 'package:sanathana_dharma_clock/services/solar_calculator.dart';
import 'package:sanathana_dharma_clock/services/time_calculator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const kochi = EffectiveLocation(
    latitude: 9.93,
    longitude: 76.26,
    source: LocationSource.saved,
  );

  ProviderContainer containerAt(
    DateTime Function() now, {
    EffectiveLocation? location = kochi,
  }) {
    final container = ProviderContainer(
      overrides: [
        nowProvider.overrideWithValue(now),
        effectiveLocationProvider.overrideWithValue(location),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('snapshot dharma matches TimeCalculator for the resolved day', () {
    final now = DateTime(2026, 3, 20, 12);
    final container = containerAt(() => now);

    final snap = container.read(clockProvider);

    final day = const SolarCalculator().resolveDay(
      now,
      kochi.latitude,
      kochi.longitude,
    );
    final expected = const TimeCalculator().toDharmaTime(
      now: now,
      sunrise: day.sunrise.toLocal(),
      span: day.span,
    );

    expect(snap.dharma, expected);
    expect(snap.civilTime, now);
    expect(snap.isPolar, isFalse);
    expect(snap.source, LocationSource.saved);
  });

  test('no location gives a midnight-anchored, polar snapshot', () {
    final now = DateTime(2026, 3, 20, 12);
    final container = containerAt(() => now, location: null);

    final snap = container.read(clockProvider);

    expect(snap.isPolar, isTrue);
    expect(snap.source, isNull);
    expect(snap.dharma.span, const Duration(seconds: 86400));
  });

  test('keeps the same anchor within one dharma day (cache)', () {
    var current = DateTime(2026, 3, 20, 12);
    final container = containerAt(() => current);

    final first = container.read(clockProvider);
    current = DateTime(2026, 3, 20, 12, 5); // 5 minutes later, same day
    container.read(clockProvider.notifier).refresh();
    final second = container.read(clockProvider);

    expect(second.dharma.sunrise, first.dharma.sunrise);
  });

  test('rolls the anchor when now crosses into the next day', () {
    var current = DateTime(2026, 3, 20, 12);
    final container = containerAt(() => current);

    final first = container.read(clockProvider);
    current = DateTime(2026, 3, 21, 12); // next day, after the next sunrise
    container.read(clockProvider.notifier).refresh();
    final second = container.read(clockProvider);

    expect(second.dharma.sunrise, isNot(first.dharma.sunrise));
    final diff = second.dharma.sunrise.difference(first.dharma.sunrise);
    expect(diff.inHours, inInclusiveRange(20, 28));
  });
}
