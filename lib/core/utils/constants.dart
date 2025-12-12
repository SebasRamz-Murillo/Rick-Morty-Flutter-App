/// Constantes de la API de Rick and Morty.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://rickandmortyapi.com/api';

  // Endpoints
  static const String characters = '/character';

  // Query params para filtrado
  static const String page = 'page';
  static const String name = 'name';
  static const String status = 'status';
  static const String species = 'species';
  static const String gender = 'gender';
}

/// Constantes para persistencia local con Hive.
class HiveConstants {
  HiveConstants._();

  static const String favoritesBox = 'favorites_box';
  static const String favoritesKey = 'favorite_ids';
}
