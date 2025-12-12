import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/features/characters/data/models/character_model.dart';

import '../../../../fixtures/character_fixture.dart';
import '../../../../helpers/test_logger.dart';

void main() {
  group('CharacterModel', () {
    test('fromJson crea un modelo válido', () {
      TestLogger.logTestData('CharacterModel.fromJson', {
        'input': characterJson,
      });

      final model = CharacterModel.fromJson(characterJson);

      TestLogger.logOutput('model.id', model.id);
      TestLogger.logOutput('model.name', model.name);
      TestLogger.logOutput('model.status', model.status);
      TestLogger.logOutput('model.species', model.species);
      TestLogger.logOutput('model.origin.name', model.origin.name);
      TestLogger.logOutput('model.location.name', model.location.name);

      expect(model.id, 1);
      expect(model.name, 'Rick Sanchez');
      expect(model.status, 'Alive');
      expect(model.species, 'Human');
      expect(model.gender, 'Male');
      expect(model.origin.name, 'Earth (C-137)');
      expect(model.location.name, 'Citadel of Ricks');
      expect(model.episode.length, 2);
    });

    test('toJson genera JSON válido', () {
      final model = CharacterModel.fromJson(characterJson);
      final json = model.toJson();

      TestLogger.logTestData('CharacterModel.toJson', {
        'input_model': 'CharacterModel(id: ${model.id}, name: ${model.name})',
        'output_json_keys': json.keys.toList(),
      });

      TestLogger.logOutput('json[id]', json['id']);
      TestLogger.logOutput('json[name]', json['name']);

      expect(json['id'], 1);
      expect(json['name'], 'Rick Sanchez');
      expect(json['status'], 'Alive');
    });

    test('copyWith crea copia con valores modificados', () {
      final model = CharacterModel.fromJson(characterJson);

      TestLogger.logTestData('CharacterModel.copyWith', {
        'original_name': model.name,
        'new_name': 'Morty Smith',
      });

      final copy = model.copyWith(name: 'Morty Smith');

      TestLogger.logOutput('copy.name', copy.name);
      TestLogger.logOutput('copy.id (sin cambios)', copy.id);

      expect(copy.name, 'Morty Smith');
      expect(copy.id, model.id);
    });

    test('dos modelos con mismos datos son iguales', () {
      final model1 = CharacterModel.fromJson(characterJson);
      final model2 = CharacterModel.fromJson(characterJson);

      TestLogger.logTestData('CharacterModel equality', {
        'model1.hashCode': model1.hashCode,
        'model2.hashCode': model2.hashCode,
        'son_iguales': model1 == model2,
      });

      expect(model1, model2);
    });
  });

  group('CharacterResponseModel', () {
    test('fromJson parsea respuesta paginada', () {
      TestLogger.logTestData('CharacterResponseModel.fromJson', {
        'info': characterResponseJson['info'],
        'results_count': (characterResponseJson['results'] as List).length,
      });

      final response = CharacterResponseModel.fromJson(characterResponseJson);

      TestLogger.logOutput('info.count', response.info.count);
      TestLogger.logOutput('info.pages', response.info.pages);
      TestLogger.logOutput('info.next', response.info.next);
      TestLogger.logOutput('info.prev', response.info.prev);
      TestLogger.logOutput('results.length', response.results.length);
      TestLogger.logOutput('results[0].name', response.results.first.name);

      expect(response.info.count, 826);
      expect(response.info.pages, 42);
      expect(response.info.next, isNotNull);
      expect(response.info.prev, isNull);
      expect(response.results.length, 1);
      expect(response.results.first.name, 'Rick Sanchez');
    });
  });

  group('OriginModel', () {
    test('fromJson crea modelo de origen', () {
      final originJson = characterJson['origin'] as Map<String, dynamic>;

      TestLogger.logTestData('OriginModel.fromJson', {'input': originJson});

      final origin = OriginModel.fromJson(originJson);

      TestLogger.logOutput('origin.name', origin.name);
      TestLogger.logOutput('origin.url', origin.url);

      expect(origin.name, 'Earth (C-137)');
      expect(origin.url, contains('location/1'));
    });
  });

  group('LocationModel', () {
    test('fromJson crea modelo de ubicación', () {
      final locationJson = characterJson['location'] as Map<String, dynamic>;

      TestLogger.logTestData('LocationModel.fromJson', {'input': locationJson});

      final location = LocationModel.fromJson(locationJson);

      TestLogger.logOutput('location.name', location.name);
      TestLogger.logOutput('location.url', location.url);

      expect(location.name, 'Citadel of Ricks');
      expect(location.url, contains('location/3'));
    });
  });
}
