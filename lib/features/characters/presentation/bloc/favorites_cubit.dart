import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/features/characters/data/models/character_model.dart';
import 'package:rick_and_morty/features/characters/domain/repositories/character_repository.dart';

part 'favorites_state.dart';

/// Cubit para manejar favoritos.
class FavoritesCubit extends Cubit<FavoritesState> {
  final CharacterRepository _repository;

  FavoritesCubit(this._repository) : super(const FavoritesState());

  /// Carga los IDs de favoritos.
  Future<void> loadFavorites() async {
    final result = await _repository.getFavoriteIds();

    result.fold(
      (failure) => emit(state.copyWith(
        status: FavoritesStatus.failure,
        errorMessage: failure.message,
      )),
      (ids) => emit(state.copyWith(
        status: FavoritesStatus.loaded,
        favoriteIds: ids.toSet(),
      )),
    );
  }

  /// Carga los personajes favoritos desde la API.
  Future<void> loadFavoriteCharacters() async {
    if (state.favoriteIds.isEmpty) {
      emit(state.copyWith(favoriteCharacters: [], isLoadingCharacters: false));
      return;
    }

    emit(state.copyWith(isLoadingCharacters: true));

    final result = await _repository.getCharactersByIds(state.favoriteIds.toList());

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingCharacters: false,
        errorMessage: failure.message,
      )),
      (characters) => emit(state.copyWith(
        isLoadingCharacters: false,
        favoriteCharacters: characters,
      )),
    );
  }

  /// Alterna el estado de favorito de un personaje.
  Future<void> toggleFavorite(int characterId) async {
    final result = await _repository.toggleFavorite(characterId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: FavoritesStatus.failure,
        errorMessage: failure.message,
      )),
      (isFavorite) {
        final updatedIds = Set<int>.from(state.favoriteIds);
        List<CharacterModel> updatedCharacters = List.from(state.favoriteCharacters);

        if (isFavorite) {
          updatedIds.add(characterId);
        } else {
          updatedIds.remove(characterId);
          updatedCharacters.removeWhere((c) => c.id == characterId);
        }

        emit(state.copyWith(
          status: FavoritesStatus.loaded,
          favoriteIds: updatedIds,
          favoriteCharacters: updatedCharacters,
        ));
      },
    );
  }

  /// Verifica si un personaje es favorito.
  bool isFavorite(int characterId) {
    return state.favoriteIds.contains(characterId);
  }
}
