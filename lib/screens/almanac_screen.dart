import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_localizations.dart';
import '../models/almanac_year.dart';
import '../providers/almanac_providers.dart';
import '../theme/app_theme.dart';

/// The Almanac tab: a whole year at the saved place — the six sun events and
/// every day's sunrise/sunset (plan 20260723_181354).
///
/// Reads only [almanacYearProvider] — the scan/bisection math lives in
/// `AlmanacCalculator` (architecture §7). The provider recomputes once per
/// year or location change, so this screen never rebuilds on the clock tick.
///
/// With no location at all a friendly message is shown instead of a fake
/// table (CLAUDE.md hard rule 4).
class AlmanacScreen extends ConsumerWidget {
  const AlmanacScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final almanac = ref.watch(almanacYearProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.almanacTab),
        actions: [
          IconButton(
            tooltip: l10n.settingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: almanac == null
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'The almanac needs a location. Set one in Settings '
                      '(or wait for a live fix) to see the year.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _YearSelector(year: almanac.year),
                  _EventsCard(events: almanac.events),
                  const SizedBox(height: 4),
                  for (var month = 1; month <= 12; month++)
                    _MonthSection(almanac: almanac, month: month),
                ],
              ),
      ),
    );
  }
}

/// The year row: back/next arrows around the shown year.
class _YearSelector extends ConsumerWidget {
  const _YearSelector({required this.year});

  final int year;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifier = ref.read(selectedAlmanacYearProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'Previous year',
          icon: const Icon(Icons.chevron_left),
          onPressed: notifier.previous,
        ),
        Text(
          '$year',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        IconButton(
          tooltip: 'Next year',
          icon: const Icon(Icons.chevron_right),
          onPressed: notifier.next,
        ),
      ],
    );
  }
}

/// The year's six sun events, in date order, each with a plain-word note.
class _EventsCard extends StatelessWidget {
  const _EventsCard({required this.events});

  final List<AlmanacEvent> events;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              'Sun events of the year',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
            for (final event in events) _EventRow(event: event),
          ],
        ),
      ),
    );
  }
}

/// One event: name, local date and time, and its one-line note.
class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final AlmanacEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = event.instantUtc.toLocal();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _eventName(event.kind),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '${_dayDate(local)} · ${_hm(local)}',
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            _eventNote(event.kind),
            style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}

/// One month: an expandable section listing every day's sunrise, sunset, and
/// day length. The current month starts open when its year is shown.
class _MonthSection extends StatelessWidget {
  const _MonthSection({required this.almanac, required this.month});

  final AlmanacYear almanac;
  final int month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final days = [
      for (final day in almanac.days)
        if (day.date.month == month) day,
    ];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: almanac.year == now.year && month == now.month,
        title: Text(
          _monthNames[month - 1],
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          const _DayHeaderRow(),
          for (final day in days)
            _DayRow(
              day: day,
              isToday:
                  almanac.year == now.year &&
                  month == now.month &&
                  day.date.day == now.day,
            ),
        ],
      ),
    );
  }
}

/// The column labels above a month's day rows.
class _DayHeaderRow extends StatelessWidget {
  const _DayHeaderRow();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: AppTheme.muted,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 32, child: Text('Day', style: style)),
          Expanded(child: Text('Sunrise', style: style)),
          Expanded(child: Text('Sunset', style: style)),
          Expanded(child: Text('Length', style: style)),
        ],
      ),
    );
  }
}

/// One day: date number, sunrise, sunset, and day length. Polar gaps show a
/// dash. Today's row is tinted.
class _DayRow extends StatelessWidget {
  const _DayRow({required this.day, required this.isToday});

  final AlmanacDay day;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
    );

    return Container(
      decoration: isToday
          ? BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
            )
          : null,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: Row(
        children: [
          SizedBox(width: 32, child: Text('${day.date.day}', style: style)),
          Expanded(child: Text(_time(day.sunriseUtc), style: style)),
          Expanded(child: Text(_time(day.sunsetUtc), style: style)),
          Expanded(child: Text(_length(day.dayLength), style: style)),
        ],
      ),
    );
  }
}

// --- event wording ---

/// The display name of a yearly sun event.
String _eventName(AlmanacEventKind kind) => switch (kind) {
  AlmanacEventKind.marchEquinox => 'March equinox',
  AlmanacEventKind.juneSolstice => 'June solstice',
  AlmanacEventKind.septemberEquinox => 'September equinox',
  AlmanacEventKind.decemberSolstice => 'December solstice',
  AlmanacEventKind.uttarayanaStart => 'Uttarāyaṇa begins (Makara Saṅkrānti)',
  AlmanacEventKind.dakshinayanaStart => 'Dakṣiṇāyana begins (Karka Saṅkrānti)',
};

/// A one-line plain-word note for each event.
String _eventNote(AlmanacEventKind kind) => switch (kind) {
  AlmanacEventKind.marchEquinox =>
    'Day and night are nearly equal. The Sun crosses the equator '
        'heading north.',
  AlmanacEventKind.juneSolstice =>
    'The longest day of the year in the northern half of the world.',
  AlmanacEventKind.septemberEquinox =>
    'Day and night are nearly equal. The Sun crosses the equator '
        'heading south.',
  AlmanacEventKind.decemberSolstice =>
    'The shortest day of the year in the northern half of the world.',
  AlmanacEventKind.uttarayanaStart =>
    'The Sun enters sidereal Makara — the northward half-year begins.',
  AlmanacEventKind.dakshinayanaStart =>
    'The Sun enters sidereal Karka — the southward half-year begins.',
};

// --- small local formatting helpers (no `intl` dependency) ---

const List<String> _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// `HH:mm` of an already-local instant.
String _hm(DateTime local) => '${_two(local.hour)}:${_two(local.minute)}';

/// e.g. `Sat, 20 Mar 2027` for a **local** instant.
String _dayDate(DateTime local) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${days[local.weekday - 1]}, ${local.day} '
      '${months[local.month - 1]} ${local.year}';
}

/// A table time: local `HH:mm`, or a dash on a polar gap.
String _time(DateTime? utc) => utc == null ? '—' : _hm(utc.toLocal());

/// A day length like `12h 33m`, or a dash when there is none.
String _length(Duration? length) {
  if (length == null) return '—';
  final minutes = length.inMinutes;
  return '${minutes ~/ 60}h ${_two(minutes % 60)}m';
}
