import 'package:rick_and_morty/core/network/dio_client.dart';
import 'package:rick_and_morty/core/utils/constants.dart';
import 'package:rick_and_morty/features/characters/data/models/character_model.dart';

/// Interfaz para el datasource remoto de personajes.
abstract class CharacterRemoteDataSource {
  /// Obtiene lista paginada de personajes.
  Future<CharacterResponseModel> getCharacters(int page);

  /// Obtiene un personaje por [id].
  Future<CharacterModel> getCharacterById(int id);

  /// Obtiene múltiples personajes por [ids].
  Future<List<CharacterModel>> getCharactersByIds(List<int> ids);

  /// Busca personajes por [name].
  Future<CharacterResponseModel> searchCharacters(String name, int page);
}

/// Implementación del datasource remoto usando Dio.
class CharacterRemoteDataSourceImpl implements CharacterRemoteDataSource {
  final DioClient _client;

  CharacterRemoteDataSourceImpl(this._client);

  @override
  Future<CharacterResponseModel> getCharacters(int page) async {
    final response = await _client.get(
      ApiConstants.characters,
      queryParameters: {ApiConstants.page: page},
    );
    return CharacterResponseModel.fromJson(response.data);
  }

  @override
  Future<CharacterModel> getCharacterById(int id) async {
    final response = await _client.get('${ApiConstants.characters}/$id');
    return CharacterModel.fromJson(response.data);
  }

  @override
  Future<List<CharacterModel>> getCharactersByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    if (ids.length == 1) {
      final character = await getCharacterById(ids.first);
      return [character];
    }
    final idsParam = ids.join(',');
    final response = await _client.get('${ApiConstants.characters}/$idsParam');
    final List<dynamic> data = response.data;
    return data.map((json) => CharacterModel.fromJson(json)).toList();
  }

  @override
  Future<CharacterResponseModel> searchCharacters(String name, int page) async {
    final response = await _client.get(
      ApiConstants.characters,
      queryParameters: {
        ApiConstants.name: name,
        ApiConstants.page: page,
      },
    );
    return CharacterResponseModel.fromJson(response.data);
  }
}
