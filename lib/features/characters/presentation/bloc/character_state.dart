part of 'character_bloc.dart';

/// Estados posibles del listado de personajes.
enum CharacterStatus { initial, loading, success, failure }

/// Estado del CharacterBloc.
final class CharacterState extends Equatable {
  final CharacterStatus status;
  final List<CharacterModel> characters;
  final bool hasReachedMax;
  final int currentPage;
  final int totalPages;
  final String searchQuery;
  final String? errorMessage;

  const CharacterState({
    this.status = CharacterStatus.initial,
    this.characters = const [],
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.totalPages = 0,
    this.searchQuery = '',
    this.errorMessage,
  });

  CharacterState copyWith({
    CharacterStatus? status,
    List<CharacterModel>? characters,
    bool? hasReachedMax,
    int? currentPage,
    int? totalPages,
    String? searchQuery,
    String? errorMessage,
  }) {
    return CharacterState(
      status: status ?? this.status,
      characters: characters ?? this.characters,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        characters,
        hasReachedMax,
        currentPage,
        totalPages,
        searchQuery,
        errorMessage,
      ];
}
