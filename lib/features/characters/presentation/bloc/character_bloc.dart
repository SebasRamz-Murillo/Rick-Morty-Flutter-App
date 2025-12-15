import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/features/characters/data/models/character_model.dart';
import 'package:rick_and_morty/features/characters/domain/repositories/character_repository.dart';

part 'character_event.dart';
part 'character_state.dart';

/// Bloc para manejar el listado de personajes con paginación y búsqueda.
class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  final CharacterRepository _repository;
  Timer? _debounceTimer;

  CharacterBloc(this._repository) : super(const CharacterState()) {
    on<CharacterFetched>(_onCharacterFetched);
    on<CharacterSearched>(_onCharacterSearched);
    on<CharacterRefreshed>(_onCharacterRefreshed);
    on<CharacterPrefetchRequested>(_onPrefetchRequested);
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  /// Carga más personajes (paginación).
  Future<void> _onCharacterFetched(
    CharacterFetched event,
    Emitter<CharacterState> emit,
  ) async {
    if (state.hasReachedMax || state.status == CharacterStatus.loading) return;

    emit(state.copyWith(status: CharacterStatus.loading));

    final result = state.searchQuery.isEmpty
        ? await _repository.getCharacters(state.currentPage)
        : await _repository.searchCharacters(state.searchQuery, state.currentPage);

    result.fold(
      (failure) => emit(state.copyWith(
        status: CharacterStatus.failure,
        errorMessage: failure.message,
      )),
      (response) {
        final hasReachedMax = response.info.next == null;
        emit(state.copyWith(
          status: CharacterStatus.success,
          characters: [...state.characters, ...response.results],
          hasReachedMax: hasReachedMax,
          currentPage: state.currentPage + 1,
          totalPages: response.info.pages,
        ));
      },
    );
  }

  /// Busca personajes por nombre con debounce.
  Future<void> _onCharacterSearched(
    CharacterSearched event,
    Emitter<CharacterState> emit,
  ) async {
    // Cancelar timer anterior
    _debounceTimer?.cancel();

    // Si la query es igual a la actual y no está vacía, ignorar
    if (event.query == state.searchQuery && event.query.isNotEmpty) return;

    // Mostrar loading pero mantener personajes actuales
    emit(state.copyWith(
      status: CharacterStatus.loading,
      searchQuery: event.query,
    ));

    // Debounce de 400ms
    final completer = Completer<void>();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      try {
        final result = event.query.isEmpty
            ? await _repository.getCharacters(1)
            : await _repository.searchCharacters(event.query, 1);

        if (!emit.isDone) {
          result.fold(
            (failure) => emit(state.copyWith(
              status: CharacterStatus.failure,
              errorMessage: failure.message,
              characters: [],
              currentPage: 1,
              hasReachedMax: true,
            )),
            (response) {
              emit(state.copyWith(
                status: CharacterStatus.success,
                characters: response.results,
                hasReachedMax: response.info.next == null,
                currentPage: 2,
                totalPages: response.info.pages,
              ));
            },
          );
        }
      } finally {
        completer.complete();
      }
    });

    await completer.future;
  }

  /// Precarga la siguiente página en segundo plano.
  Future<void> _onPrefetchRequested(
    CharacterPrefetchRequested event,
    Emitter<CharacterState> emit,
  ) async {
    if (state.hasReachedMax || state.status == CharacterStatus.loading) return;

    final result = state.searchQuery.isEmpty
        ? await _repository.getCharacters(state.currentPage)
        : await _repository.searchCharacters(state.searchQuery, state.currentPage);

    result.fold(
      (failure) {
        // Silently fail on prefetch
      },
      (response) {
        final hasReachedMax = response.info.next == null;
        emit(state.copyWith(
          characters: [...state.characters, ...response.results],
          hasReachedMax: hasReachedMax,
          currentPage: state.currentPage + 1,
          totalPages: response.info.pages,
        ));
      },
    );
  }

  /// Refresca la lista de personajes.
  Future<void> _onCharacterRefreshed(
    CharacterRefreshed event,
    Emitter<CharacterState> emit,
  ) async {
    _debounceTimer?.cancel();
    emit(const CharacterState());
    add(const CharacterFetched());
  }
}
