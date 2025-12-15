part of 'favorites_cubit.dart';

/// Estados posibles de favoritos.
enum FavoritesStatus { initial, loading, loaded, failure }

/// Estado del FavoritesCubit.
final class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final Set<int> favoriteIds;
  final List<CharacterModel> favoriteCharacters;
  final bool isLoadingCharacters;
  final String? errorMessage;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favoriteIds = const {},
    this.favoriteCharacters = const [],
    this.isLoadingCharacters = false,
    this.errorMessage,
  });

  FavoritesState copyWith({
    FavoritesStatus? status,
    Set<int>? favoriteIds,
    List<CharacterModel>? favoriteCharacters,
    bool? isLoadingCharacters,
    String? errorMessage,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      favoriteCharacters: favoriteCharacters ?? this.favoriteCharacters,
      isLoadingCharacters: isLoadingCharacters ?? this.isLoadingCharacters,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, favoriteIds, favoriteCharacters, isLoadingCharacters, errorMessage];
}
