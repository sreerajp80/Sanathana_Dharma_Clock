import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sanathana_dharma_clock/core/constants/app_constants.dart';
import 'package:sanathana_dharma_clock/models/saved_location.dart';
import 'package:sanathana_dharma_clock/repositories/location_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<LocationRepository> repoWith(Map<String, Object> initial) async {
    SharedPreferences.setMockInitialValues(initial);
    final prefs = await SharedPreferences.getInstance();
    return LocationRepository(prefs);
  }

  group('LocationRepository — saved location', () {
    test('write then read returns an equal record (round-trip)', () async {
      final repo = await repoWith({});
      const location = SavedLocation(
        latitude: 9.93,
        longitude: 76.26,
        label: 'Kochi',
      );

      final ok = await repo.writeSavedLocation(location);

      expect(ok, isTrue);
      expect(repo.readSavedLocation(), location);
    });

    test('read returns null when nothing is stored', () async {
      final repo = await repoWith({});
      expect(repo.readSavedLocation(), isNull);
    });

    test('read returns null on a corrupt (non-JSON) value', () async {
      final repo = await repoWith({
        AppConstants.prefSavedLocation: 'not json at all',
      });
      expect(repo.readSavedLocation(), isNull);
    });

    test('read returns null on a JSON value of the wrong shape', () async {
      final repo = await repoWith({
        AppConstants.prefSavedLocation: '[1, 2, 3]',
      });
      expect(repo.readSavedLocation(), isNull);
    });

    test('clear removes the saved record', () async {
      final repo = await repoWith({});
      await repo.writeSavedLocation(
        const SavedLocation(latitude: 1, longitude: 2),
      );

      final ok = await repo.clearSavedLocation();

      expect(ok, isTrue);
      expect(repo.readSavedLocation(), isNull);
    });
  });

  group('LocationRepository — use-live flag', () {
    test('defaults to false when never set', () async {
      final repo = await repoWith({});
      expect(repo.readUseLiveLocation(), isFalse);
    });

    test('write then read returns the stored value', () async {
      final repo = await repoWith({});

      await repo.writeUseLiveLocation(true);
      expect(repo.readUseLiveLocation(), isTrue);

      await repo.writeUseLiveLocation(false);
      expect(repo.readUseLiveLocation(), isFalse);
    });
  });
}
