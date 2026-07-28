import 'package:flutter_test/flutter_test.dart';

import 'package:sanathana_dharma_clock/core/constants/dharma_units.dart';
import 'package:sanathana_dharma_clock/core/constants/hora_names.dart';
import 'package:sanathana_dharma_clock/core/constants/muhurta_names.dart';
import 'package:sanathana_dharma_clock/core/constants/panchang_names.dart';

/// True when [text] holds no Latin letter — a cheap way to catch a name that
/// was left untranslated in a Malayalam table.
bool hasNoLatinLetter(String text) => !RegExp(r'[A-Za-z]').hasMatch(text);

void main() {
  group('DharmaUnits — two languages', () {
    test('every unit has all its Malayalam text filled in', () {
      for (final unit in DharmaUnits.all) {
        expect(unit.nameMl, isNotEmpty, reason: unit.name);
        expect(unit.approxMl, isNotEmpty, reason: unit.name);
        expect(unit.civilMl, isNotEmpty, reason: unit.name);
        expect(unit.countMl, isNotEmpty, reason: unit.name);
        expect(unit.descriptionMl, isNotEmpty, reason: unit.name);
      }
    });

    test('the flag picks the language', () {
      const unit = DharmaUnits.ghatika;
      expect(unit.nameFor(false), unit.name);
      expect(unit.nameFor(true), unit.nameMl);
      expect(unit.approxFor(false), unit.approx);
      expect(unit.approxFor(true), unit.approxMl);
      expect(unit.countFor(false), unit.count);
      expect(unit.countFor(true), unit.countMl);
      expect(unit.descriptionFor(false), unit.description);
      expect(unit.descriptionFor(true), unit.descriptionMl);
      expect(unit.civilFor(true), unit.civilMl);
    });

    test('the English and Malayalam text differ for every unit', () {
      for (final unit in DharmaUnits.all) {
        expect(unit.descriptionMl, isNot(unit.description), reason: unit.name);
        expect(unit.countMl, isNot(unit.count), reason: unit.name);
      }
    });
  });

  group('MuhurtaNames — two languages', () {
    test('both lists hold the same 30 slots', () {
      expect(MuhurtaNames.names, hasLength(30));
      expect(MuhurtaNames.namesMl, hasLength(30));
    });

    test('the flag picks the language, and the default stays English', () {
      expect(MuhurtaNames.at(0), 'Rudra');
      expect(MuhurtaNames.at(0, isMalayalam: true), 'രുദ്രൻ');
      expect(MuhurtaNames.at(28, isMalayalam: true), 'ബ്രഹ്മം');
    });

    test('a bad index is clamped, not thrown (hard rule 4)', () {
      expect(
        MuhurtaNames.at(-5, isMalayalam: true),
        MuhurtaNames.namesMl.first,
      );
      expect(MuhurtaNames.at(99, isMalayalam: true), MuhurtaNames.namesMl.last);
    });
  });

  group('HoraNames — two languages', () {
    test('both lists hold the same 7 rulers', () {
      expect(HoraNames.order, hasLength(7));
      expect(HoraNames.orderMl, hasLength(7));
    });

    test('the flag picks the language, and the default stays English', () {
      expect(HoraNames.nameAt(0), 'Sūrya (Sun)');
      expect(HoraNames.nameAt(0, isMalayalam: true), 'സൂര്യൻ');
      expect(HoraNames.nameAt(3, isMalayalam: true), 'ചന്ദ്രൻ');
    });

    test('indexAt and lordAt agree, in both languages', () {
      for (var k = 0; k < 24; k++) {
        final index = HoraNames.indexAt(DateTime.sunday, k);
        expect(HoraNames.lordAt(DateTime.sunday, k), HoraNames.nameAt(index));
        expect(
          HoraNames.lordAt(DateTime.sunday, k, isMalayalam: true),
          HoraNames.nameAt(index, isMalayalam: true),
        );
      }
    });

    test('an out-of-range index wraps instead of throwing (hard rule 4)', () {
      expect(HoraNames.nameAt(7), HoraNames.order.first);
      expect(HoraNames.nameAt(-1), HoraNames.order.last);
    });
  });

  group('PanchangNames — the North Indian names in two scripts', () {
    test('every Malayalam list has the same length as its English one', () {
      expect(PanchangNames.nakshatrasMl, hasLength(27));
      expect(PanchangNames.yogasMl, hasLength(27));
      expect(PanchangNames.movableKaranasMl, hasLength(7));
      expect(PanchangNames.endFixedKaranasMl, hasLength(3));
      expect(PanchangNames.masasMl, hasLength(12));
      expect(PanchangNames.rtusMl, hasLength(6));
      expect(PanchangNames.varasMl, hasLength(7));
    });

    test('no Malayalam name is empty or left in Latin script', () {
      final lists = <String, List<String>>{
        'nakshatrasMl': PanchangNames.nakshatrasMl,
        'yogasMl': PanchangNames.yogasMl,
        'movableKaranasMl': PanchangNames.movableKaranasMl,
        'endFixedKaranasMl': PanchangNames.endFixedKaranasMl,
        'masasMl': PanchangNames.masasMl,
        'rtusMl': PanchangNames.rtusMl,
        'varasMl': PanchangNames.varasMl.values.toList(),
      };

      lists.forEach((listName, names) {
        for (final name in names) {
          expect(name, isNotEmpty, reason: listName);
          expect(
            hasNoLatinLetter(name),
            isTrue,
            reason: '$listName still holds Latin text: $name',
          );
        }
      });

      for (final name in <String>[
        PanchangNames.purnimaMl,
        PanchangNames.amavasyaMl,
        PanchangNames.shuklaPakshaMl,
        PanchangNames.krishnaPakshaMl,
        PanchangNames.kimstughnaMl,
        PanchangNames.adhikaMl,
        PanchangNames.uttarayanaMl,
        PanchangNames.dakshinayanaMl,
      ]) {
        expect(name, isNotEmpty);
        expect(hasNoLatinLetter(name), isTrue, reason: name);
      }
    });

    test('the flag picks the script, and the default stays English', () {
      expect(PanchangNames.tithi(0), 'Pratipadā');
      expect(PanchangNames.tithi(0, isMalayalam: true), 'പ്രതിപദ');
      expect(
        PanchangNames.tithi(14, isMalayalam: true),
        PanchangNames.purnimaMl,
      );
      expect(
        PanchangNames.tithi(29, isMalayalam: true),
        PanchangNames.amavasyaMl,
      );

      expect(PanchangNames.yogaName(0), 'Viṣkambha');
      expect(PanchangNames.yogaName(0, isMalayalam: true), 'വിഷ്കംഭം');

      expect(PanchangNames.karana(0), PanchangNames.kimstughna);
      expect(
        PanchangNames.karana(0, isMalayalam: true),
        PanchangNames.kimstughnaMl,
      );
      expect(PanchangNames.karana(1, isMalayalam: true), 'ബവം');
      expect(PanchangNames.karana(57, isMalayalam: true), 'ശകുനി');

      expect(PanchangNames.masa(0), 'Chaitra');
      expect(PanchangNames.masa(0, isMalayalam: true), 'ചൈത്രം');

      expect(
        PanchangNames.paksha(0, isMalayalam: true),
        PanchangNames.shuklaPakshaMl,
      );
      expect(
        PanchangNames.paksha(20, isMalayalam: true),
        PanchangNames.krishnaPakshaMl,
      );

      expect(PanchangNames.vara(DateTime.sunday, isMalayalam: true), 'രവിവാരം');

      expect(
        PanchangNames.rtuOfMasa(0, isMalayalam: true),
        PanchangNames.rtusMl.first,
      );

      expect(
        PanchangNames.ayanaName(isUttarayana: true),
        PanchangNames.uttarayana,
      );
      expect(
        PanchangNames.ayanaName(isUttarayana: true, isMalayalam: true),
        PanchangNames.uttarayanaMl,
      );
      expect(
        PanchangNames.ayanaName(isUttarayana: false, isMalayalam: true),
        PanchangNames.dakshinayanaMl,
      );
    });

    test('in Malayalam both halves of a formatted name are Malayalam', () {
      for (var i = 0; i < 27; i++) {
        expect(
          hasNoLatinLetter(
            PanchangNames.nakshatraFormatted(
              i,
              keralaStyle: true,
              isMalayalam: true,
            ),
          ),
          isTrue,
          reason: 'nakshatra $i',
        );
      }

      for (var i = 0; i < 30; i++) {
        expect(
          hasNoLatinLetter(
            PanchangNames.tithiFormatted(
              i,
              keralaStyle: false,
              isMalayalam: true,
            ),
          ),
          isTrue,
          reason: 'tithi $i',
        );
      }

      for (var weekday = 1; weekday <= 7; weekday++) {
        expect(
          hasNoLatinLetter(
            PanchangNames.varaFormatted(
              weekday,
              keralaStyle: true,
              isMalayalam: true,
            ),
          ),
          isTrue,
          reason: 'vara $weekday',
        );
      }

      expect(
        hasNoLatinLetter(
          PanchangNames.masaFormatted(
            masaIndex: 4,
            solarMasaIndex: 4,
            keralaStyle: false,
            isMalayalam: true,
            isAdhika: true,
          ),
        ),
        isTrue,
      );
    });

    test('a bad index wraps instead of throwing (hard rule 4)', () {
      expect(
        PanchangNames.yogaName(27, isMalayalam: true),
        PanchangNames.yogasMl.first,
      );
      expect(
        PanchangNames.masa(12, isMalayalam: true),
        PanchangNames.masasMl.first,
      );
      expect(
        PanchangNames.karana(60, isMalayalam: true),
        PanchangNames.kimstughnaMl,
      );
    });
  });
}
