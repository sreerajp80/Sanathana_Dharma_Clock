import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_localizations.dart';
import '../models/muhurta_window.dart';
import '../providers/clock_providers.dart';
import '../providers/muhurta_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/window_colors.dart';
import '../widgets/window_labels.dart';

/// The Muhurta & Kalas tab: today's named windows in civil time.
///
/// Two sections, both from [muhurtaDayProvider]:
/// 1. **Kālas & special windows** — Abhijit Muhūrta and the three inauspicious
///    kālas (Rāhu, Yamagaṇḍa, Gulika), split from the sunrise→sunset daytime.
///    When there is no sunset (no location, polar date) a friendly message is
///    shown instead of fake times (CLAUDE.md hard rule 4).
/// 2. **The 30 muhūrtas** — every muhūrta of the elastic sunrise-to-sunrise
///    day with its traditional name; matches the clock and dial exactly.
///
/// The row holding "now" is highlighted and scrolled into view on open. The
/// highlight follows the clock at minute precision, so this screen does not
/// rebuild every second.
class MuhurtaScreen extends ConsumerStatefulWidget {
  const MuhurtaScreen({super.key});

  @override
  ConsumerState<MuhurtaScreen> createState() => _MuhurtaScreenState();
}

class _MuhurtaScreenState extends ConsumerState<MuhurtaScreen> {
  /// Marks the current muhūrta row so it can be scrolled into view on open.
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
    final day = ref.watch(muhurtaDayProvider);
    // Minute precision is enough for the highlight; this avoids a rebuild of
    // the whole list every second.
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

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.muhurtaTab),
        actions: [
          IconButton(
            tooltip: l10n.settingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionHeader(
                title: l10n.kalasTitle,
                subtitle: l10n.kalasSubtitle,
              ),
              if (day.kalas.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.kalasEmpty,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                )
              else
                ...day.kalas.map(
                  (w) => _WindowCard(window: w, now: now, l10n: l10n),
                ),
              const SizedBox(height: 16),
              _SectionHeader(
                title: l10n.muhurtaListTitle,
                subtitle: day.isApproximate
                    ? l10n.muhurtaListSubtitleApprox
                    : l10n.muhurtaListSubtitle,
              ),
              for (var i = 0; i < day.muhurtas.length; i++)
                _MuhurtaRow(
                  key: day.muhurtas[i].contains(now) ? _currentRowKey : null,
                  index: i,
                  window: day.muhurtas[i],
                  isCurrent: day.muhurtas[i].contains(now),
                  l10n: l10n,
                ),
            ],
          ),
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

/// One special window (Abhijit or a kāla) as a card: colour dot, name,
/// auspicious/inauspicious tag, start–end, and a "Now" chip when active.
class _WindowCard extends StatelessWidget {
  const _WindowCard({
    required this.window,
    required this.now,
    required this.l10n,
  });

  final MuhurtaWindow window;
  final DateTime now;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = window.contains(now);
    final color = windowColor(window);

    return Card(
      shape: active
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: color, width: 1.5),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    windowName(window, l10n),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    window.kind == WindowKind.auspicious
                        ? l10n.auspicious
                        : l10n.inauspicious,
                    style: theme.textTheme.bodySmall?.copyWith(color: color),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_hm(window.start)} – ${_hm(window.end)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (active) ...[
                  const SizedBox(height: 2),
                  _NowChip(color: color, label: l10n.now),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One row of the 30-muhūrta list: number, name, times; highlighted when it
/// holds "now"; Brahma Muhūrta carries its auspicious tag.
class _MuhurtaRow extends StatelessWidget {
  const _MuhurtaRow({
    super.key,
    required this.index,
    required this.window,
    required this.isCurrent,
    required this.l10n,
  });

  final int index;
  final MuhurtaWindow window;
  final bool isCurrent;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auspicious = window.kind == WindowKind.auspicious;

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
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    windowName(window, l10n),
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (auspicious) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.spa_outlined,
                    size: 14,
                    color: AppTheme.auspicious,
                  ),
                ],
              ],
            ),
          ),
          if (isCurrent) ...[
            _NowChip(color: AppTheme.vermillion, label: l10n.now),
            const SizedBox(width: 8),
          ],
          Text(
            '${_hm(window.start)} – ${_hm(window.end)}',
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

/// The small "Now" pill shown on the active window.
class _NowChip extends StatelessWidget {
  const _NowChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
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
