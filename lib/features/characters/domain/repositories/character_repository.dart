import 'package:dartz/dartz.dart';
import 'package:rick_and_morty/core/error/failures.dart';
import 'package:rick_and_morty/features/characters/data/models/character_model.dart';

/// Contrato del repositorio de personajes.
abstract class CharacterRepository {
  /// Obtiene lista paginada de personajes.
  Future<Either<Failure, CharacterResponseModel>> getCharacters(int page);

  /// Obtiene un personaje por [id].
  Future<Either<Failure, CharacterModel>> getCharacterById(int id);

  /// Busca personajes por [name].
  Future<Either<Failure, CharacterResponseModel>> searchCharacters(
    String name,
    int page,
  );

  /// Obtiene IDs de favoritos.
  Future<Either<Failure, List<int>>> getFavoriteIds();

  /// Agrega/elimina un personaje de favoritos.
  Future<Either<Failure, bool>> toggleFavorite(int id);

  /// Verifica si un personaje es favorito.
  Future<bool> isFavorite(int id);
}
