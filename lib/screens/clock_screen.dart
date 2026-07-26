import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_localizations.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/dharma_units.dart';
import '../core/constants/muhurta_names.dart';
import '../models/clock_snapshot.dart';
import '../models/muhurta_window.dart';
import '../providers/clock_providers.dart';
import '../providers/location_providers.dart';
import '../providers/muhurta_providers.dart';
import '../services/location_resolver.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/dharma_dial_painter.dart';
import '../widgets/location_permission_banner.dart';
import '../widgets/window_colors.dart';

/// The main screen: the analog dharma dial and the digital readout, driven by
/// the once-per-second [clockProvider]. The whole reading also carries a
/// screen-reader label (architecture §16).
class ClockScreen extends ConsumerWidget {
  const ClockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(clockProvider);

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.settingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Semantics(
          label: _semanticLabel(snapshot),
          container: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const _LocationHeader(),
                      const LocationPermissionBanner(),
                      const SizedBox(height: 16),
                      _Dial(snapshot: snapshot),
                      const SizedBox(height: 16),
                      const _ArcLegend(),
                      const _Legend(),
                      const SizedBox(height: 24),
                      _Readout(snapshot: snapshot),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// A plain-English one-line reading for screen readers.
  String _semanticLabel(ClockSnapshot s) {
    final d = s.dharma;
    return 'Dharma time: Ghatika ${d.ghatika}, Vinadi ${d.vinadi}, '
        'Prana ${d.prana}. Muhurta ${d.muhurta + 1} of '
        '${AppConstants.muhurtaPerDay}, ${MuhurtaNames.at(d.muhurta)}. '
        'Civil time ${_hms(s.civilTime)}. Sunrise ${_hm(d.sunrise)}. '
        '${_sinceSunrise(s.civilTime, d.sunrise)}.';
  }
}

/// The square analog dial, sized to the available width. It also converts the
/// day's special windows (Abhijit + kālas) into [DialArc] fractions, so the
/// painter itself never sees times or the kāla rules.
class _Dial extends ConsumerWidget {
  const _Dial({required this.snapshot});

  final ClockSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kalas = ref.watch(muhurtaDayProvider.select((d) => d.kalas));
    final side = MediaQuery.sizeOf(context).width.clamp(0.0, 360.0);
    return SizedBox(
      width: side,
      height: side,
      child: CustomPaint(
        painter: DharmaDialPainter(
          dharma: snapshot.dharma,
          muhurtaName: MuhurtaNames.at(snapshot.dharma.muhurta),
          accent: AppTheme.vermillion,
          foreground: AppTheme.vermillionDark,
          muted: AppTheme.muted,
          faceColor: AppTheme.chandanSurface,
          arcs: _arcs(kalas),
        ),
      ),
    );
  }

  /// Window → arc: start/end as fractions of the dharma day, clamped to 0..1.
  /// Empty in (and out) on days without a sunset — the dial then draws no arcs.
  List<DialArc> _arcs(List<MuhurtaWindow> kalas) {
    final sunrise = snapshot.dharma.sunrise.toUtc();
    final spanMicros = snapshot.dharma.span.inMicroseconds;
    if (spanMicros <= 0) return const [];

    return [
      for (final w in kalas)
        DialArc(
          startFraction:
              (w.start.difference(sunrise).inMicroseconds / spanMicros).clamp(
                0.0,
                1.0,
              ),
          endFraction: (w.end.difference(sunrise).inMicroseconds / spanMicros)
              .clamp(0.0, 1.0),
          color: windowColor(w),
        ),
    ];
  }
}

/// A one-line key for the dial's window arcs: a colour dot and the window name
/// for each arc shown. Hidden when there are no arcs (no sunset today).
class _ArcLegend extends ConsumerWidget {
  const _ArcLegend();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kalas = ref.watch(muhurtaDayProvider.select((d) => d.kalas));
    if (kalas.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 14,
        runSpacing: 4,
        children: [
          for (final w in kalas)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: windowColor(w),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  w.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.muted,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// A small key under the dial telling the user which hand is which. Each row
/// draws a short line in the same colour and thickness as that hand, then the
/// unit name and its civil-time size (e.g. "Ghaṭikā · 24 minutes").
///
/// The three hand styles mirror [DharmaDialPainter]: Ghaṭikā is the thick dark
/// hand, Vināḍī the medium vermillion hand, and Prāṇa the thin vermillion hand.
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      runSpacing: 8,
      children: [
        _LegendItem(
          unit: DharmaUnits.ghatika,
          color: AppTheme.vermillionDark,
          thickness: 4,
        ),
        _LegendItem(
          unit: DharmaUnits.vinadi,
          color: AppTheme.vermillion,
          thickness: 3,
        ),
        _LegendItem(
          unit: DharmaUnits.prana,
          color: AppTheme.vermillion,
          thickness: 1.5,
        ),
      ],
    );
  }
}

/// One legend row: a line sample matching a hand, then its name and analogy.
class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.unit,
    required this.color,
    required this.thickness,
  });

  final DharmaUnit unit;
  final Color color;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: thickness,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(thickness),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${unit.name} · ${unit.civil}',
          style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.muted),
        ),
      ],
    );
  }
}

/// The digital readout under the dial (idea doc §5).
class _Readout extends StatelessWidget {
  const _Readout({required this.snapshot});

  final ClockSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = snapshot.dharma;

    return Column(
      children: [
        Text(
          'Ghaṭikā ${d.ghatika} : Vināḍī ${d.vinadi} : Prāṇa ${d.prana}',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Civil ${_hms(snapshot.civilTime)}    '
          'Sunrise ${_hm(d.sunrise)}',
          style: theme.textTheme.bodyLarge?.copyWith(color: AppTheme.muted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          _sinceSunrise(snapshot.civilTime, d.sunrise),
          style: theme.textTheme.bodyLarge?.copyWith(color: AppTheme.muted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// The location indicator shown at the top of the clock. It says where the
/// anchor came from — and, when there is a real location, shows the coordinates
/// — so the user knows when the midnight fallback is in effect (CLAUDE.md hard
/// rule 4).
///
/// The coordinates are only *shown* on the user's own screen; they are never
/// logged or sent anywhere (CLAUDE.md hard rule 3). It reads only providers —
/// never `shared_preferences` or the plugin (architecture rule): the effective
/// location for the source and numbers, and [locationProvider] to explain the
/// no-location state (a live fetch may still be running, or live may be on but
/// the last fetch failed). This avoids a confusing "No location" message while
/// the user has live location switched on.
class _LocationHeader extends ConsumerWidget {
  const _LocationHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effective = ref.watch(effectiveLocationProvider);

    final IconData icon;
    final String text;
    String? coords;

    if (effective != null) {
      final isLive = effective.source == LocationSource.live;
      icon = isLive ? Icons.my_location : Icons.place_outlined;
      text = isLive ? 'Live location' : 'Saved location';
      coords = '${_coord(effective.latitude)}, ${_coord(effective.longitude)}';
    } else {
      // No anchor: explain the no-location state using the live-fetch progress.
      final location = ref.watch(locationProvider);
      final failed =
          location.liveResult != null && !location.liveResult!.isSuccess;
      if (location.isFetching) {
        icon = Icons.my_location;
        text = 'Getting location…';
      } else if (location.useLive && failed) {
        icon = Icons.error_outline;
        text = _liveFailureMessage(location.liveResult!.status);
      } else {
        icon = Icons.schedule;
        text = 'No location — midnight-anchored day';
      }
    }

    final theme = Theme.of(context);
    final mutedSmall = theme.textTheme.bodySmall?.copyWith(
      color: AppTheme.muted,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.muted),
            const SizedBox(width: 6),
            Flexible(
              child: Text(text, textAlign: TextAlign.center, style: mutedSmall),
            ),
          ],
        ),
        if (coords != null) ...[
          const SizedBox(height: 2),
          Text(coords, textAlign: TextAlign.center, style: mutedSmall),
        ],
      ],
    );
  }

  /// One coordinate at a fixed 4 decimals for the on-screen readout.
  String _coord(double value) => value.toStringAsFixed(4);

  /// A plain-English reason a live fetch failed, ending with the midnight
  /// fallback the clock is using. Never includes coordinates (security.md §9).
  String _liveFailureMessage(LocationStatus status) {
    switch (status) {
      case LocationStatus.serviceDisabled:
        return 'Location is off on the device — using midnight-anchored day';
      case LocationStatus.permissionDenied:
        return 'Location permission denied — using midnight-anchored day';
      case LocationStatus.permissionDeniedForever:
        return 'Location permission blocked — using midnight-anchored day';
      case LocationStatus.error:
      case LocationStatus.success:
        return 'No location fix yet — using midnight-anchored day';
    }
  }
}

// --- small local formatting helpers (no `intl` dependency) ---

String _two(int n) => n.toString().padLeft(2, '0');

/// `HH:mm:ss` in local time.
String _hms(DateTime t) {
  final l = t.toLocal();
  return '${_two(l.hour)}:${_two(l.minute)}:${_two(l.second)}';
}

/// How long after today's sunrise it is now, as `Xh Ym Zs after sunrise`.
/// Clamped at zero so it never reads negative near the day boundary.
String _sinceSunrise(DateTime civil, DateTime sunrise) {
  var d = civil.difference(sunrise);
  if (d.isNegative) d = Duration.zero;
  return '${d.inHours}h ${d.inMinutes % 60}m ${d.inSeconds % 60}s after sunrise';
}

/// `HH:mm` in local time.
String _hm(DateTime t) {
  final l = t.toLocal();
  return '${_two(l.hour)}:${_two(l.minute)}';
}
