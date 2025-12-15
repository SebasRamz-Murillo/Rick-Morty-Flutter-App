import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:rick_and_morty/core/error/failures.dart';
import 'package:rick_and_morty/features/characters/data/datasources/character_local_datasource.dart';
import 'package:rick_and_morty/features/characters/data/datasources/character_remote_datasource.dart';
import 'package:rick_and_morty/features/characters/data/models/character_model.dart';
import 'package:rick_and_morty/features/characters/domain/repositories/character_repository.dart';

/// Implementación del repositorio de personajes.
class CharacterRepositoryImpl implements CharacterRepository {
  final CharacterRemoteDataSource _remoteDataSource;
  final CharacterLocalDataSource _localDataSource;

  CharacterRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, CharacterResponseModel>> getCharacters(int page) async {
    return _handleRequest(() => _remoteDataSource.getCharacters(page));
  }

  @override
  Future<Either<Failure, CharacterModel>> getCharacterById(int id) async {
    return _handleRequest(() => _remoteDataSource.getCharacterById(id));
  }

  @override
  Future<Either<Failure, List<CharacterModel>>> getCharactersByIds(List<int> ids) async {
    return _handleRequest(() => _remoteDataSource.getCharactersByIds(ids));
  }

  @override
  Future<Either<Failure, CharacterResponseModel>> searchCharacters(
    String name,
    int page,
  ) async {
    return _handleRequest(() => _remoteDataSource.searchCharacters(name, page));
  }

  @override
  Future<Either<Failure, List<int>>> getFavoriteIds() async {
    try {
      final ids = await _localDataSource.getFavoriteIds();
      return Right(ids);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFavorite(int id) async {
    try {
      final isFav = await _localDataSource.isFavorite(id);
      if (isFav) {
        await _localDataSource.removeFavorite(id);
        return const Right(false);
      } else {
        await _localDataSource.addFavorite(id);
        return const Right(true);
      }
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<bool> isFavorite(int id) async {
    return await _localDataSource.isFavorite(id);
  }

  /// Maneja peticiones remotas y convierte errores a [Failure].
  Future<Either<Failure, T>> _handleRequest<T>(
    Future<T> Function() request,
  ) async {
    try {
      final result = await request();
      return Right(result);
    } on DioException catch (e) {
      return Left(e.error as Failure);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}
