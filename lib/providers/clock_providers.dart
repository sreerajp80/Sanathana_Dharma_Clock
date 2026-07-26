import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/date_utils.dart';
import '../models/clock_snapshot.dart';
import '../services/location_resolver.dart';
import '../services/solar_calculator.dart';
import 'location_providers.dart';
import 'service_providers.dart';

/// The source of "now", injected so tests can feed a fixed instant.
///
/// Production uses the real wall clock. A test overrides this with a function
/// that returns a chosen `DateTime`, then drives the clock with
/// [ClockNotifier.refresh] instead of waiting on the real timer.
final nowProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Drives the once-per-second clock tick.
///
/// Each tick it produces a fresh [ClockSnapshot] for "now". The expensive
/// sunrise resolution ([SolarCalculator.resolveDay]) is **cached and reused**
/// within a dharma day and only recomputed when "now" crosses the cached day's
/// end — the day-boundary roll (architecture §19: recompute sunrises once per
/// day, not every tick).
///
/// Lifecycle (architecture §6) is handled with an [AppLifecycleListener]: the
/// timer stops on pause/hide to save battery and restarts on resume/show, and a
/// resume recomputes immediately so a date change while paused is caught. The
/// timer and listener are cleaned up on dispose and on every rebuild (a location
/// change rebuilds this notifier and re-resolves the day).
///
/// When there is no location at all, it falls back to a midnight-anchored day
/// with a fixed 86,400 s span, so the clock never crashes on a missing anchor
/// (CLAUDE.md hard rule 4).
class ClockNotifier extends Notifier<ClockSnapshot> {
  Timer? _timer;
  AppLifecycleListener? _lifecycle;
  SolarDay? _day;
  EffectiveLocation? _location;

  @override
  ClockSnapshot build() {
    // A location change rebuilds this notifier; drop the cached day so the next
    // compute re-resolves for the new coordinates.
    _location = ref.watch(effectiveLocationProvider);
    _day = null;

    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
      _lifecycle?.dispose();
      _lifecycle = null;
    });

    _startTimer();
    _lifecycle = AppLifecycleListener(
      onPause: _stopTimer,
      onHide: _stopTimer,
      onResume: _onResume,
      onShow: _onResume,
    );

    return _compute();
  }

  /// Recomputes the snapshot now. Public for tests and for the resume path.
  void refresh() => state = _compute();

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => refresh());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _onResume() {
    refresh();
    _startTimer();
  }

  ClockSnapshot _compute() {
    final now = ref.read(nowProvider)();
    final day = _resolveDay(now);
    final dharma = ref
        .read(timeCalculatorProvider)
        .toDharmaTime(
          now: now,
          // Local for the "Sunrise 06:11" readout; the mapping itself works in
          // UTC internally, so passing the local value is exact.
          sunrise: day.sunrise.toLocal(),
          span: day.span,
        );
    return ClockSnapshot(
      civilTime: now,
      dharma: dharma,
      isPolar: day.isPolar,
      source: _location?.source,
    );
  }

  /// Returns the cached dharma day when "now" still falls inside it, otherwise
  /// resolves a fresh one. This is what keeps sunrise math to once per day.
  SolarDay _resolveDay(DateTime now) {
    final nowUtc = now.toUtc();
    final cached = _day;
    if (cached != null &&
        !nowUtc.isBefore(cached.sunrise) &&
        nowUtc.isBefore(cached.sunrise.add(cached.span))) {
      return cached;
    }

    final location = _location;
    final day = location == null
        ? _midnightDay(nowUtc)
        : ref
              .read(solarCalculatorProvider)
              .resolveDay(now, location.latitude, location.longitude);
    _day = day;
    return day;
  }

  /// The no-location fallback: a plain midnight-anchored day with a fixed span,
  /// mirroring [SolarCalculator]'s own polar fallback shape.
  SolarDay _midnightDay(DateTime nowUtc) => SolarDay(
    sunrise: DateUtils.startOfDayUtc(nowUtc),
    span: const Duration(seconds: AppConstants.secondsPerDay),
    isPolar: true,
  );
}

/// The current clock reading, ticking once per second.
final clockProvider = NotifierProvider<ClockNotifier, ClockSnapshot>(
  ClockNotifier.new,
);
