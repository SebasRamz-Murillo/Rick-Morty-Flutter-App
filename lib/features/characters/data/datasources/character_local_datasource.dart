import 'package:hive/hive.dart';
import 'package:rick_and_morty/core/utils/constants.dart';

/// Interfaz para el datasource local de favoritos.
abstract class CharacterLocalDataSource {
  /// Obtiene lista de IDs favoritos.
  Future<List<int>> getFavoriteIds();

  /// Agrega un [id] a favoritos.
  Future<void> addFavorite(int id);

  /// Elimina un [id] de favoritos.
  Future<void> removeFavorite(int id);

  /// Verifica si un [id] está en favoritos.
  Future<bool> isFavorite(int id);
}

/// Implementación del datasource local usando Hive.
class CharacterLocalDataSourceImpl implements CharacterLocalDataSource {
  final Box<List<dynamic>> _box;

  CharacterLocalDataSourceImpl(this._box);

  @override
  Future<List<int>> getFavoriteIds() async {
    final ids = _box.get(
      HiveConstants.favoritesKey,
      defaultValue: <dynamic>[],
    );
    return ids?.cast<int>() ?? [];
  }

  @override
  Future<void> addFavorite(int id) async {
    final ids = await getFavoriteIds();
    if (!ids.contains(id)) {
      ids.add(id);
      await _box.put(HiveConstants.favoritesKey, ids);
    }
  }

  @override
  Future<void> removeFavorite(int id) async {
    final ids = await getFavoriteIds();
    ids.remove(id);
    await _box.put(HiveConstants.favoritesKey, ids);
  }

  @override
  Future<bool> isFavorite(int id) async {
    final ids = await getFavoriteIds();
    return ids.contains(id);
  }
}
