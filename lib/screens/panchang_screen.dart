import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_localizations.dart';
import '../core/constants/panchang_names.dart';
import '../models/panchang_day.dart';
import '../providers/language_provider.dart';
import '../providers/panchang_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/location_permission_banner.dart';

/// The Panchang tab with dual views: Kerala Style and North Indian Style tabs
/// (plan 20260723_075550 & 20260726_192500).
class PanchangScreen extends ConsumerWidget {
  const PanchangScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panchang = ref.watch(panchangDayProvider);
    final l10n = AppLocalizations.of(context);
    final isMl = ref.watch(appLanguageProvider).isMalayalam;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.panchangTab),
          actions: [
            IconButton(
              tooltip: l10n.settingsTitle,
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push('/settings'),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.keralaStyleTab),
              Tab(text: l10n.northIndianStyleTab),
            ],
          ),
        ),
        body: SafeArea(
          child: panchang == null
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: LocationPermissionBanner(),
                  ),
                )
              : TabBarView(
                  children: [
                    _PanchangView(
                      panchang: panchang,
                      keralaStyle: true,
                      isMalayalam: isMl,
                    ),
                    _PanchangView(
                      panchang: panchang,
                      keralaStyle: false,
                      isMalayalam: isMl,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _PanchangView extends StatelessWidget {
  const _PanchangView({
    required this.panchang,
    required this.keralaStyle,
    required this.isMalayalam,
  });

  final PanchangDay panchang;
  final bool keralaStyle;
  final bool isMalayalam;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cal = panchang.calendar;

    final varaFormatted = PanchangNames.varaFormatted(
      panchang.weekday,
      keralaStyle: keralaStyle,
      isMalayalam: isMalayalam,
    );

    final tithiFormatted = PanchangNames.tithiFormatted(
      panchang.tithi.index,
      keralaStyle: keralaStyle,
      isMalayalam: isMalayalam,
    );

    final nakshatraFormatted = PanchangNames.nakshatraFormatted(
      panchang.nakshatra.index,
      keralaStyle: keralaStyle,
      isMalayalam: isMalayalam,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DayHeaderCard(
            panchang: panchang,
            keralaStyle: keralaStyle,
            isMalayalam: isMalayalam,
          ),
          const SizedBox(height: 4),
          if (cal != null)
            _CalendarCard(
              calendar: cal,
              keralaStyle: keralaStyle,
              isMalayalam: isMalayalam,
            ),
          _MoonCard(panchang: panchang),
          _LimbCard(
            label: l10n.varaLabel,
            name: varaFormatted,
            meaning: isMalayalam
                ? 'ആഴ്ചയിലെ ദിവസം. ഹിന്ദു കലണ്ടറിൽ ദിവസം സൂര്യോദയത്തോടെ ആരംഭിക്കുന്നു.'
                : 'The day of the week. In the Hindu calendar the day starts at sunrise, not midnight.',
          ),
          _LimbCard(
            label: l10n.tithiLabel,
            name: tithiFormatted,
            detail: cal != null
                ? PanchangNames.pakshaFormatted(
                    panchang.tithi.index,
                    keralaStyle: keralaStyle,
                    isMalayalam: isMalayalam,
                  )
                : panchang.tithi.detail,
            meaning: isMalayalam
                ? 'ചന്ദ്രന്റെ ഘട്ടത്തെ പിന്തുടരുന്ന ചന്ദ്ര ദിനം. 30 തിഥികൾ ഒരു ചാന്ദ്ര മാസത്തെ ഉണ്ടാക്കുന്നു.'
                : 'The lunar day, which follows the Moon’s phase. 30 tithis make one full lunar month.',
            endText: _endText(panchang.tithi, panchang.sunriseUtc, isMalayalam),
          ),
          _LimbCard(
            label: l10n.nakshatraLabel,
            name: nakshatraFormatted,
            meaning: isMalayalam
                ? 'ചന്ദ്രൻ കടന്നുപോകുന്ന നക്ഷത്ര സമൂഹം. ആകാശ പാതയെ 27 നക്ഷത്ര ഗണങ്ങളായി തിരിച്ചിരിക്കുന്നു.'
                : 'The star group the Moon is passing through. The sky path is divided into 27 such star groups.',
            endText: _endText(
              panchang.nakshatra,
              panchang.sunriseUtc,
              isMalayalam,
            ),
          ),
          _LimbCard(
            label: l10n.yogaLabel,
            name: panchang.yoga.name,
            meaning: isMalayalam
                ? 'സൂര്യന്റെയും ചന്ദ്രന്റെയും സംയോജിത ചലനത്തിൽ നിന്നുള്ള സമയം. ഒരു ചക്രത്തിൽ 27 യോഗങ്ങളുണ്ട്.'
                : 'A period from the combined movement of the Sun and Moon. There are 27 yogas in a cycle.',
            endText: _endText(panchang.yoga, panchang.sunriseUtc, isMalayalam),
          ),
          _LimbCard(
            label: l10n.karanaLabel,
            name: panchang.karana.name,
            meaning: isMalayalam
                ? 'ഒരു തിഥിയുടെ പകുതി.'
                : 'Half of a tithi. The karaṇa names repeat through the month.',
            endText: _endText(
              panchang.karana,
              panchang.sunriseUtc,
              isMalayalam,
            ),
          ),
        ],
      ),
    );
  }
}

/// The header card: which dharma day this Panchang belongs to.
class _DayHeaderCard extends StatelessWidget {
  const _DayHeaderCard({
    required this.panchang,
    required this.keralaStyle,
    required this.isMalayalam,
  });

  final PanchangDay panchang;
  final bool keralaStyle;
  final bool isMalayalam;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final sunriseLocal = panchang.sunriseUtc.toLocal();
    final cal = panchang.calendar;

    String headlineStyle = '';
    if (cal != null) {
      if (keralaStyle) {
        final masa = PanchangNames.keralaSolarMasa(
          cal.solarMasaIndex,
          isMalayalam: isMalayalam,
        );
        final njattuvela = PanchangNames.nakshatraFormatted(
          cal.njattuvelaIndex,
          keralaStyle: true,
          isMalayalam: isMalayalam,
        );
        final yearTitle = isMalayalam ? 'കൊല്ലവർഷം' : 'Kollavarsham';
        headlineStyle =
            '$yearTitle ${cal.kollavarshamYear} $masa · $njattuvela ${l10n.njattuvelaLabel}';
      } else {
        final masa = PanchangNames.masa(cal.amantaMasaIndex);
        final yearTitle = isMalayalam ? 'വിക്രം സംവത്' : 'Vikram Samvat';
        headlineStyle = '$yearTitle ${cal.vikramSamvatYear} $masa';
      }
    }

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
              l10n.panchangHeader,
              style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.muted),
            ),
            const SizedBox(height: 4),
            Text(
              _dayDate(sunriseLocal),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (headlineStyle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                headlineStyle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.vermillion,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              '${isMalayalam ? "സൂര്യോദയം മുതൽ" : "From sunrise"} ${_hm(panchang.sunriseUtc)} — ${l10n.panchangSubheader}',
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

/// The calendar card: the day's place in the wider Hindu calendar.
class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.calendar,
    required this.keralaStyle,
    required this.isMalayalam,
  });

  final CalendarInfo calendar;
  final bool keralaStyle;
  final bool isMalayalam;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final masaValue = PanchangNames.masaFormatted(
      masaIndex: calendar.amantaMasaIndex,
      solarMasaIndex: calendar.solarMasaIndex,
      keralaStyle: keralaStyle,
      isMalayalam: isMalayalam,
      isAdhika: calendar.isAdhika,
    );

    final pakshaValue = PanchangNames.pakshaFormatted(
      calendar.weekday, // placeholder, paksha formatted handles tithi index
      keralaStyle: keralaStyle,
      isMalayalam: isMalayalam,
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.calendarCardTitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            _CalendarRow(
              label: keralaStyle
                  ? (isMalayalam
                        ? 'സൗരമാസം (Kollavarsham)'
                        : 'Solar Month (Kollavarsham)')
                  : (isMalayalam
                        ? 'ചാന്ദ്രമാസം (Amānta)'
                        : 'Lunar Month (Amānta)'),
              value: masaValue,
              note: keralaStyle
                  ? (isMalayalam
                        ? 'കേരളത്തിൽ പ്രധാനമായും പിന്തുടരുന്ന കൊല്ലവർഷ സൗര മാസം.'
                        : 'Solar month of the Kollavarsham calendar, widely used in Kerala.')
                  : (isMalayalam
                        ? 'ഉത്തരേന്ത്യയിലും ദക്ഷിണേന്ത്യയിലും പിന്തുടരുന്ന ചാന്ദ്ര മാസം.'
                        : 'Lunar month of the traditional Panchang system.'),
            ),
            _CalendarRow(
              label: l10n.pakshaLabel,
              value: pakshaValue,
              note: calendar.paksha == PanchangNames.shuklaPaksha
                  ? (isMalayalam
                        ? 'വെളുത്ത പക്ഷം — ചന്ദ്രൻ വളരുന്ന ഘട്ടം.'
                        : 'Bright half — the Moon grows from new to full.')
                  : (isMalayalam
                        ? 'കറുത്ത പക്ഷം — ചന്ദ്രൻ കുറയുന്ന ഘട്ടം.'
                        : 'Dark half — the Moon shrinks from full to new.'),
            ),
            _CalendarRow(
              label: l10n.rtuLabel,
              value: calendar.rtu,
              note: isMalayalam
                  ? 'ഋതു (കാലാവസ്ഥാ കാലം). ഓരോ ഋതുവും രണ്ട് ചാന്ദ്ര മാസങ്ങൾ ഉൾക്കൊള്ളുന്നു.'
                  : 'The season. Each season spans two lunar months.',
            ),
            _CalendarRow(
              label: l10n.ayanaLabel,
              value: calendar.ayana,
              note: calendar.ayana == PanchangNames.uttarayana
                  ? (isMalayalam
                        ? 'സൂര്യന്റെ ഉത്തരായണ ഗതി (മകര സംക്രാന്തി മുതൽ).'
                        : 'The Sun’s northward half-year, from Makara Saṅkrānti.')
                  : (isMalayalam
                        ? 'സൂര്യന്റെ ദക്ഷിണായന ഗതി (കർക്കടക സംക്രാന്തി മുതൽ).'
                        : 'The Sun’s southward half-year, from Karka Saṅkrānti.'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarRow extends StatelessWidget {
  const _CalendarRow({
    required this.label,
    required this.value,
    required this.note,
  });

  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.muted),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            note,
            style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}

class _MoonCard extends StatelessWidget {
  const _MoonCard({required this.panchang});

  final PanchangDay panchang;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.moonCardTitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: _MoonTime(
                    label: l10n.moonrise,
                    time: _moonTime(panchang.moonriseUtc, panchang.sunriseUtc),
                  ),
                ),
                Expanded(
                  child: _MoonTime(
                    label: l10n.moonset,
                    time: _moonTime(panchang.moonsetUtc, panchang.sunriseUtc),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoonTime extends StatelessWidget {
  const _MoonTime({required this.label, required this.time});

  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.muted),
        ),
        Text(
          time,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _LimbCard extends StatelessWidget {
  const _LimbCard({
    required this.label,
    required this.name,
    required this.meaning,
    this.detail = '',
    this.endText = '',
  });

  final String label;
  final String name;
  final String meaning;
  final String detail;
  final String endText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = [
      if (detail.isNotEmpty) detail,
      if (endText.isNotEmpty) endText,
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(subtitle, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 4),
            Text(
              meaning,
              style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.muted),
            ),
          ],
        ),
      ),
    );
  }
}

String _two(int n) => n.toString().padLeft(2, '0');

String _hm(DateTime t) {
  final l = t.toLocal();
  return '${_two(l.hour)}:${_two(l.minute)}';
}

const List<String> _months = [
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

String _dayDate(DateTime local) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return '${days[local.weekday - 1]}, ${local.day} '
      '${_months[local.month - 1]} ${local.year}';
}

String _moonTime(DateTime? eventUtc, DateTime sunriseUtc) {
  if (eventUtc == null) return '—';
  final eventLocal = eventUtc.toLocal();
  final sunriseLocal = sunriseUtc.toLocal();
  final sameDate =
      eventLocal.year == sunriseLocal.year &&
      eventLocal.month == sunriseLocal.month &&
      eventLocal.day == sunriseLocal.day;
  return sameDate
      ? _hm(eventUtc)
      : '${_hm(eventUtc)} (${eventLocal.day} '
            '${_months[eventLocal.month - 1]})';
}

String _endText(PanchangLimb limb, DateTime sunriseUtc, bool isMalayalam) {
  final end = limb.endUtc;
  if (end == null) {
    return isMalayalam
        ? 'അടുത്ത സൂര്യോദയം വരെ തുടരുന്നു'
        : 'runs past the next sunrise';
  }
  final endLocal = end.toLocal();
  final sunriseLocal = sunriseUtc.toLocal();
  final sameDate =
      endLocal.year == sunriseLocal.year &&
      endLocal.month == sunriseLocal.month &&
      endLocal.day == sunriseLocal.day;
  final untilText = isMalayalam ? 'വരെ' : 'until';
  return sameDate
      ? '$untilText ${_hm(end)}'
      : '$untilText ${_hm(end)} (${endLocal.day} ${_months[endLocal.month - 1]})';
}
