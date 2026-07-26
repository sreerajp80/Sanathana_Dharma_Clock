import 'package:flutter_test/flutter_test.dart';

import 'package:sanathana_dharma_clock/models/saved_location.dart';

void main() {
  group('SavedLocation — JSON round-trip', () {
    test('toJson then fromJson returns an equal value (with a label)', () {
      const original = SavedLocation(
        latitude: 9.9312,
        longitude: 76.2673,
        label: 'Kochi',
      );

      final restored = SavedLocation.fromJson(original.toJson());

      expect(restored, original);
    });

    test('round-trip works with an empty label', () {
      const original = SavedLocation(latitude: -33.8688, longitude: 151.2093);

      final restored = SavedLocation.fromJson(original.toJson());

      expect(restored, original);
      expect(restored.label, isEmpty);
    });
  });

  group('SavedLocation — defensive fromJson', () {
    test('missing fields fall back to 0.0 and an empty label', () {
      final restored = SavedLocation.fromJson(const {});

      expect(restored.latitude, 0.0);
      expect(restored.longitude, 0.0);
      expect(restored.label, '');
    });

    test('wrong-typed coordinates fall back to 0.0', () {
      final restored = SavedLocation.fromJson(const {
        'latitude': 'not a number',
        'longitude': true,
        'label': 42,
      });

      expect(restored.latitude, 0.0);
      expect(restored.longitude, 0.0);
      // A non-String label also falls back to empty.
      expect(restored.label, '');
    });

    test('integer coordinates are accepted and become double', () {
      final restored = SavedLocation.fromJson(const {
        'latitude': 10,
        'longitude': 76,
        'label': 'Somewhere',
      });

      expect(restored.latitude, 10.0);
      expect(restored.longitude, 76.0);
      expect(restored.latitude, isA<double>());
      expect(restored.longitude, isA<double>());
    });
  });

  group('SavedLocation — equality', () {
    test('equal values are equal and share a hashCode', () {
      const a = SavedLocation(latitude: 1.0, longitude: 2.0, label: 'X');
      const b = SavedLocation(latitude: 1.0, longitude: 2.0, label: 'X');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('a differing field breaks equality', () {
      const base = SavedLocation(latitude: 1.0, longitude: 2.0, label: 'X');

      expect(
        base,
        isNot(const SavedLocation(latitude: 1.5, longitude: 2.0, label: 'X')),
      );
      expect(
        base,
        isNot(const SavedLocation(latitude: 1.0, longitude: 2.5, label: 'X')),
      );
      expect(
        base,
        isNot(const SavedLocation(latitude: 1.0, longitude: 2.0, label: 'Y')),
      );
    });
  });

  group('SavedLocation — security', () {
    test('toString omits the coordinates', () {
      const location = SavedLocation(
        latitude: 12.3456,
        longitude: 78.9012,
        label: 'Home',
      );

      final text = location.toString();

      expect(text, contains('Home'));
      expect(text, isNot(contains('12.3456')));
      expect(text, isNot(contains('78.9012')));
    });
  });
}
