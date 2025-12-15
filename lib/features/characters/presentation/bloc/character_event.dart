part of 'character_bloc.dart';

/// Eventos del CharacterBloc.
sealed class CharacterEvent extends Equatable {
  const CharacterEvent();

  @override
  List<Object?> get props => [];
}

/// Solicita cargar más personajes (paginación).
final class CharacterFetched extends CharacterEvent {
  const CharacterFetched();
}

/// Busca personajes por nombre.
final class CharacterSearched extends CharacterEvent {
  final String query;

  const CharacterSearched(this.query);

  @override
  List<Object?> get props => [query];
}

/// Refresca la lista de personajes.
final class CharacterRefreshed extends CharacterEvent {
  const CharacterRefreshed();
}

/// Solicita precargar la siguiente página.
final class CharacterPrefetchRequested extends CharacterEvent {
  const CharacterPrefetchRequested();
}
