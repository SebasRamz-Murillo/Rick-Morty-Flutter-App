import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rick_and_morty/core/utils/constants.dart';
import 'package:rick_and_morty/features/characters/data/datasources/character_local_datasource.dart';

import '../../../../helpers/test_logger.dart';

class MockBox extends Mock implements Box<List<dynamic>> {}

void main() {
  late CharacterLocalDataSourceImpl dataSource;
  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
    dataSource = CharacterLocalDataSourceImpl(mockBox);
  });

  group('getFavoriteIds', () {
    test('retorna lista vacía si no hay favoritos', () async {
      TestLogger.logTestData('LocalDataSource.getFavoriteIds (vacío)', {
        'hive_key': HiveConstants.favoritesKey,
        'stored_value': [],
      });

      when(() => mockBox.get(any(), defaultValue: any(named: 'defaultValue')))
          .thenReturn(<dynamic>[]);

      final result = await dataSource.getFavoriteIds();

      TestLogger.logOutput('result', result);
      TestLogger.logOutput('result.isEmpty', result.isEmpty);

      expect(result, isEmpty);
    });

    test('retorna lista de IDs favoritos', () async {
      final storedIds = <dynamic>[1, 2, 3];

      TestLogger.logTestData('LocalDataSource.getFavoriteIds', {
        'hive_key': HiveConstants.favoritesKey,
        'stored_value': storedIds,
      });

      when(() => mockBox.get(any(), defaultValue: any(named: 'defaultValue')))
          .thenReturn(storedIds);

      final result = await dataSource.getFavoriteIds();

      TestLogger.logOutput('result', result);
      TestLogger.logOutput('result.length', result.length);

      expect(result, [1, 2, 3]);
    });
  });

  group('addFavorite', () {
    test('agrega ID a favoritos si no existe', () async {
      const newFavoriteId = 1;

      TestLogger.logTestData('LocalDataSource.addFavorite (nuevo)', {
        'new_favorite_id': newFavoriteId,
        'current_favorites': [],
        'expected_after': [newFavoriteId],
      });

      when(() => mockBox.get(any(), defaultValue: any(named: 'defaultValue')))
          .thenReturn(<dynamic>[]);
      when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

      await dataSource.addFavorite(newFavoriteId);

      TestLogger.logOutput('put_called_with', [newFavoriteId]);

      verify(() => mockBox.put(HiveConstants.favoritesKey, [1])).called(1);
    });

    test('no duplica ID si ya existe', () async {
      const existingId = 1;

      TestLogger.logTestData('LocalDataSource.addFavorite (duplicado)', {
        'favorite_id': existingId,
        'current_favorites': [existingId],
        'action': 'NO se debe agregar (ya existe)',
      });

      when(() => mockBox.get(any(), defaultValue: any(named: 'defaultValue')))
          .thenReturn(<dynamic>[existingId]);

      await dataSource.addFavorite(existingId);

      TestLogger.logOutput('put_called', false);

      verifyNever(() => mockBox.put(any(), any()));
    });
  });

  group('removeFavorite', () {
    test('elimina ID de favoritos', () async {
      const idToRemove = 2;
      final currentFavorites = <dynamic>[1, 2, 3];
      final expectedAfter = [1, 3];

      TestLogger.logTestData('LocalDataSource.removeFavorite', {
        'id_to_remove': idToRemove,
        'current_favorites': currentFavorites,
        'expected_after': expectedAfter,
      });

      when(() => mockBox.get(any(), defaultValue: any(named: 'defaultValue')))
          .thenReturn(currentFavorites);
      when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

      await dataSource.removeFavorite(idToRemove);

      TestLogger.logOutput('put_called_with', expectedAfter);

      verify(() => mockBox.put(HiveConstants.favoritesKey, [1, 3])).called(1);
    });
  });

  group('isFavorite', () {
    test('retorna true si ID está en favoritos', () async {
      const checkId = 2;
      final favorites = <dynamic>[1, 2, 3];

      TestLogger.logTestData('LocalDataSource.isFavorite (existe)', {
        'check_id': checkId,
        'favorites': favorites,
        'expected': true,
      });

      when(() => mockBox.get(any(), defaultValue: any(named: 'defaultValue')))
          .thenReturn(favorites);

      final result = await dataSource.isFavorite(checkId);

      TestLogger.logOutput('result', result);

      expect(result, true);
    });

    test('retorna false si ID no está en favoritos', () async {
      const checkId = 99;
      final favorites = <dynamic>[1, 2, 3];

      TestLogger.logTestData('LocalDataSource.isFavorite (no existe)', {
        'check_id': checkId,
        'favorites': favorites,
        'expected': false,
      });

      when(() => mockBox.get(any(), defaultValue: any(named: 'defaultValue')))
          .thenReturn(favorites);

      final result = await dataSource.isFavorite(checkId);

      TestLogger.logOutput('result', result);

      expect(result, false);
    });
  });
}
