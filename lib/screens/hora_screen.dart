import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_localizations.dart';
import '../models/hora_window.dart';
import '../providers/clock_providers.dart';
import '../providers/hora_providers.dart';
import '../theme/app_theme.dart';

/// The Hora tab: today's 24 planetary hours in civil time.
class HoraScreen extends ConsumerStatefulWidget {
  const HoraScreen({super.key});

  @override
  ConsumerState<HoraScreen> createState() => _HoraScreenState();
}

class _HoraScreenState extends ConsumerState<HoraScreen> {
  /// Marks the current horā row so it can be scrolled into view on open.
  final GlobalKey _currentRowKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _currentRowKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          alignment: 0.35,
          duration: const Duration(milliseconds: 400),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final horas = ref.watch(horaDayProvider);
    final l10n = AppLocalizations.of(context);
    final now = ref.watch(
      clockProvider.select(
        (s) => DateTime(
          s.civilTime.year,
          s.civilTime.month,
          s.civilTime.day,
          s.civilTime.hour,
          s.civilTime.minute,
        ),
      ),
    );
    final theme = Theme.of(context);

    final dayHoras = horas.where((h) => h.isDay).toList();
    final nightHoras = horas.where((h) => !h.isDay).toList();
    HoraWindow? current;
    for (final h in horas) {
      if (h.contains(now)) {
        current = h;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.horaTab),
        actions: [
          IconButton(
            tooltip: l10n.settingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: horas.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Horās need a sunrise and sunset. Set a location in '
                      'Settings (or wait for a live fix) to see them.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (current != null)
                      _CurrentHoraCard(hora: current, now: now),
                    _SectionHeader(
                      title: 'Day horās',
                      subtitle: 'Sunrise → sunset split into 12',
                    ),
                    for (final h in dayHoras)
                      _HoraRow(
                        key: identical(h, current) ? _currentRowKey : null,
                        index: dayHoras.indexOf(h),
                        hora: h,
                        isCurrent: identical(h, current),
                      ),
                    const SizedBox(height: 16),
                    _SectionHeader(
                      title: 'Night horās',
                      subtitle: 'Sunset → next sunrise split into 12',
                    ),
                    for (final h in nightHoras)
                      _HoraRow(
                        key: identical(h, current) ? _currentRowKey : null,
                        index: nightHoras.indexOf(h),
                        hora: h,
                        isCurrent: identical(h, current),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// The big card on top: the horā running right now.
class _CurrentHoraCard extends StatelessWidget {
  const _CurrentHoraCard({required this.hora, required this.now});

  final HoraWindow hora;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = hora.end.difference(now.toUtc());
    final mins = remaining.inMinutes;
    final left = mins >= 60
        ? '${mins ~/ 60} h ${mins % 60} min left'
        : '$mins min left';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.vermillion, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current horā',
              style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.muted),
            ),
            const SizedBox(height: 4),
            Text(
              hora.lord,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${hora.isDay ? 'Day' : 'Night'} horā · '
              '${_hm(hora.start)} – ${_hm(hora.end)} · $left',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A section title with a small explaining line under it.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}

/// One row of a horā list: number, ruling planet, times; highlighted when it
/// holds "now".
class _HoraRow extends StatelessWidget {
  const _HoraRow({
    super.key,
    required this.index,
    required this.hora,
    required this.isCurrent,
  });

  final int index;
  final HoraWindow hora;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrent ? AppTheme.chandanSurface : null,
        borderRadius: BorderRadius.circular(12),
        border: isCurrent
            ? Border.all(color: AppTheme.vermillion, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${index + 1}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              hora.lord,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          if (isCurrent) ...[
            const _NowChip(color: AppTheme.vermillion),
            const SizedBox(width: 8),
          ],
          Text(
            '${_hm(hora.start)} – ${_hm(hora.end)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isCurrent ? null : AppTheme.muted,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

/// The small "Now" pill shown on the active row.
class _NowChip extends StatelessWidget {
  const _NowChip({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Now',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppTheme.chandan,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// `HH:mm` in local time (windows are stored in UTC).
String _hm(DateTime t) {
  final l = t.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(l.hour)}:${two(l.minute)}';
}
