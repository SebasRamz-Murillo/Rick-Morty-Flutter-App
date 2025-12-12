import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rick_and_morty/core/network/dio_client.dart';
import 'package:rick_and_morty/features/characters/data/datasources/character_remote_datasource.dart';

import '../../../../fixtures/character_fixture.dart';
import '../../../../helpers/test_logger.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late CharacterRemoteDataSourceImpl dataSource;
  late MockDioClient mockClient;

  setUp(() {
    mockClient = MockDioClient();
    dataSource = CharacterRemoteDataSourceImpl(mockClient);
  });

  group('getCharacters', () {
    test('retorna CharacterResponseModel cuando la llamada es exitosa', () async {
      const page = 1;

      TestLogger.logTestData('RemoteDataSource.getCharacters', {
        'endpoint': '/character',
        'page': page,
        'mock_response_status': 200,
      });

      when(() => mockClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: characterResponseJson,
                statusCode: 200,
                requestOptions: RequestOptions(),
              ));

      final result = await dataSource.getCharacters(page);

      TestLogger.logOutput('results.length', result.results.length);
      TestLogger.logOutput('results[0].name', result.results.first.name);
      TestLogger.logOutput('info.pages', result.info.pages);

      expect(result.results.length, 1);
      expect(result.results.first.name, 'Rick Sanchez');
      verify(() => mockClient.get('/character', queryParameters: {'page': 1})).called(1);
    });
  });

  group('getCharacterById', () {
    test('retorna CharacterModel cuando la llamada es exitosa', () async {
      const characterId = 1;

      TestLogger.logTestData('RemoteDataSource.getCharacterById', {
        'endpoint': '/character/$characterId',
        'character_id': characterId,
        'mock_response_status': 200,
      });

      when(() => mockClient.get(any()))
          .thenAnswer((_) async => Response(
                data: characterJson,
                statusCode: 200,
                requestOptions: RequestOptions(),
              ));

      final result = await dataSource.getCharacterById(characterId);

      TestLogger.logOutput('result.id', result.id);
      TestLogger.logOutput('result.name', result.name);
      TestLogger.logOutput('result.status', result.status);

      expect(result.id, 1);
      expect(result.name, 'Rick Sanchez');
      verify(() => mockClient.get('/character/1')).called(1);
    });
  });

  group('searchCharacters', () {
    test('retorna resultados filtrados por nombre', () async {
      const searchName = 'Rick';
      const page = 1;

      TestLogger.logTestData('RemoteDataSource.searchCharacters', {
        'endpoint': '/character',
        'search_name': searchName,
        'page': page,
        'query_params': {'name': searchName, 'page': page},
      });

      when(() => mockClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: characterResponseJson,
                statusCode: 200,
                requestOptions: RequestOptions(),
              ));

      final result = await dataSource.searchCharacters(searchName, page);

      TestLogger.logOutput('results.isNotEmpty', result.results.isNotEmpty);
      TestLogger.logOutput('results.length', result.results.length);

      expect(result.results.isNotEmpty, true);
      verify(() => mockClient.get(
            '/character',
            queryParameters: {'name': 'Rick', 'page': 1},
          )).called(1);
    });
  });
}
