import 'package:rick_and_morty/core/network/dio_client.dart';
import 'package:rick_and_morty/core/utils/constants.dart';
import 'package:rick_and_morty/features/characters/data/models/character_model.dart';

/// Interfaz para el datasource remoto de personajes.
abstract class CharacterRemoteDataSource {
  /// Obtiene lista paginada de personajes.
  Future<CharacterResponseModel> getCharacters(int page);

  /// Obtiene un personaje por [id].
  Future<CharacterModel> getCharacterById(int id);

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
