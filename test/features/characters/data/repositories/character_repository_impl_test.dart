import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rick_and_morty/core/error/failures.dart';
import 'package:rick_and_morty/features/characters/data/datasources/character_local_datasource.dart';
import 'package:rick_and_morty/features/characters/data/datasources/character_remote_datasource.dart';
import 'package:rick_and_morty/features/characters/data/models/character_model.dart';
import 'package:rick_and_morty/features/characters/data/repositories/character_repository_impl.dart';

import '../../../../fixtures/character_fixture.dart';
import '../../../../helpers/test_logger.dart';

class MockRemoteDataSource extends Mock implements CharacterRemoteDataSource {}

class MockLocalDataSource extends Mock implements CharacterLocalDataSource {}

void main() {
  late CharacterRepositoryImpl repository;
  late MockRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;

  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockLocal = MockLocalDataSource();
    repository = CharacterRepositoryImpl(mockRemote, mockLocal);
  });

  final tCharacterModel = CharacterModel.fromJson(characterJson);
  final tResponse = CharacterResponseModel.fromJson(characterResponseJson);

  group('getCharacters', () {
    test('retorna Right con datos cuando la llamada remota es exitosa', () async {
      const page = 1;

      TestLogger.logTestData('Repository.getCharacters (éxito)', {
        'page': page,
        'mock_remote_response': 'CharacterResponseModel con ${tResponse.results.length} resultados',
      });

      when(() => mockRemote.getCharacters(any()))
          .thenAnswer((_) async => tResponse);

      final result = await repository.getCharacters(page);

      TestLogger.logOutput('result.isRight()', result.isRight());
      result.fold(
        (failure) => TestLogger.logOutput('failure', failure),
        (data) {
          TestLogger.logOutput('data.results.length', data.results.length);
          TestLogger.logOutput('data.info.pages', data.info.pages);
        },
      );

      expect(result, Right(tResponse));
      verify(() => mockRemote.getCharacters(page)).called(1);
    });

    test('retorna Left con Failure cuando la llamada falla', () async {
      const page = 1;

      TestLogger.logTestData('Repository.getCharacters (error)', {
        'page': page,
        'mock_error': 'DioException con ServerFailure',
        'expected': 'Left(ServerFailure)',
      });

      when(() => mockRemote.getCharacters(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          error: const ServerFailure(),
        ),
      );

      final result = await repository.getCharacters(page);

      TestLogger.logOutput('result.isLeft()', result.isLeft());
      result.fold(
        (failure) => TestLogger.logOutput('failure.message', failure.message),
        (_) {},
      );

      expect(result, const Left(ServerFailure()));
    });
  });

  group('getCharacterById', () {
    test('retorna Right con personaje cuando es exitoso', () async {
      const characterId = 1;

      TestLogger.logTestData('Repository.getCharacterById', {
        'character_id': characterId,
        'mock_response': 'CharacterModel(id: ${tCharacterModel.id}, name: ${tCharacterModel.name})',
      });

      when(() => mockRemote.getCharacterById(any()))
          .thenAnswer((_) async => tCharacterModel);

      final result = await repository.getCharacterById(characterId);

      TestLogger.logOutput('result.isRight()', result.isRight());
      result.fold(
        (_) {},
        (character) {
          TestLogger.logOutput('character.id', character.id);
          TestLogger.logOutput('character.name', character.name);
        },
      );

      expect(result, Right(tCharacterModel));
    });
  });

  group('searchCharacters', () {
    test('retorna Right con resultados de búsqueda', () async {
      const searchName = 'Rick';
      const page = 1;

      TestLogger.logTestData('Repository.searchCharacters', {
        'search_name': searchName,
        'page': page,
        'mock_response': 'CharacterResponseModel con ${tResponse.results.length} resultados',
      });

      when(() => mockRemote.searchCharacters(any(), any()))
          .thenAnswer((_) async => tResponse);

      final result = await repository.searchCharacters(searchName, page);

      TestLogger.logOutput('result.isRight()', result.isRight());
      result.fold(
        (_) {},
        (data) => TestLogger.logOutput('results.length', data.results.length),
      );

      expect(result, Right(tResponse));
      verify(() => mockRemote.searchCharacters(searchName, page)).called(1);
    });
  });

  group('getFavoriteIds', () {
    test('retorna Right con lista de IDs', () async {
      final mockFavorites = [1, 2, 3];

      TestLogger.logTestData('Repository.getFavoriteIds (éxito)', {
        'mock_local_response': mockFavorites,
        'expected': 'Right($mockFavorites)',
      });

      when(() => mockLocal.getFavoriteIds())
          .thenAnswer((_) async => mockFavorites);

      final result = await repository.getFavoriteIds();

      TestLogger.logOutput('result.isRight()', result.isRight());
      result.fold(
        (_) => fail('Expected Right'),
        (ids) => TestLogger.logOutput('ids', ids),
      );

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (ids) => expect(ids, mockFavorites),
      );
    });

    test('retorna Left con CacheFailure cuando falla', () async {
      TestLogger.logTestData('Repository.getFavoriteIds (error)', {
        'mock_error': 'Exception',
        'expected': 'Left(CacheFailure)',
      });

      when(() => mockLocal.getFavoriteIds()).thenThrow(Exception());

      final result = await repository.getFavoriteIds();

      TestLogger.logOutput('result.isLeft()', result.isLeft());
      result.fold(
        (failure) => TestLogger.logOutput('failure.message', failure.message),
        (_) {},
      );

      expect(result, const Left(CacheFailure()));
    });
  });

  group('toggleFavorite', () {
    test('retorna Right(true) al agregar a favoritos', () async {
      const characterId = 1;

      TestLogger.logTestData('Repository.toggleFavorite (agregar)', {
        'character_id': characterId,
        'is_currently_favorite': false,
        'action': 'addFavorite',
        'expected': 'Right(true)',
      });

      when(() => mockLocal.isFavorite(any())).thenAnswer((_) async => false);
      when(() => mockLocal.addFavorite(any())).thenAnswer((_) async {});

      final result = await repository.toggleFavorite(characterId);

      TestLogger.logOutput('result', result);
      result.fold(
        (_) {},
        (isFavorite) => TestLogger.logOutput('isFavorite (después)', isFavorite),
      );

      expect(result, const Right(true));
      verify(() => mockLocal.addFavorite(characterId)).called(1);
    });

    test('retorna Right(false) al eliminar de favoritos', () async {
      const characterId = 1;

      TestLogger.logTestData('Repository.toggleFavorite (eliminar)', {
        'character_id': characterId,
        'is_currently_favorite': true,
        'action': 'removeFavorite',
        'expected': 'Right(false)',
      });

      when(() => mockLocal.isFavorite(any())).thenAnswer((_) async => true);
      when(() => mockLocal.removeFavorite(any())).thenAnswer((_) async {});

      final result = await repository.toggleFavorite(characterId);

      TestLogger.logOutput('result', result);
      result.fold(
        (_) {},
        (isFavorite) => TestLogger.logOutput('isFavorite (después)', isFavorite),
      );

      expect(result, const Right(false));
      verify(() => mockLocal.removeFavorite(characterId)).called(1);
    });
  });

  group('isFavorite', () {
    test('retorna true si es favorito', () async {
      const characterId = 1;

      TestLogger.logTestData('Repository.isFavorite (existe)', {
        'character_id': characterId,
        'mock_response': true,
      });

      when(() => mockLocal.isFavorite(any())).thenAnswer((_) async => true);

      final result = await repository.isFavorite(characterId);

      TestLogger.logOutput('result', result);

      expect(result, true);
    });

    test('retorna false si no es favorito', () async {
      const characterId = 99;

      TestLogger.logTestData('Repository.isFavorite (no existe)', {
        'character_id': characterId,
        'mock_response': false,
      });

      when(() => mockLocal.isFavorite(any())).thenAnswer((_) async => false);

      final result = await repository.isFavorite(characterId);

      TestLogger.logOutput('result', result);

      expect(result, false);
    });
  });
}
