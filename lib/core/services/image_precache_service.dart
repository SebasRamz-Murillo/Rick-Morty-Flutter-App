import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rick_and_morty/features/characters/data/models/character_model.dart';

/// Servicio para precargar imágenes en segundo plano.
class ImagePrecacheService {
  static final ImagePrecacheService _instance = ImagePrecacheService._();
  factory ImagePrecacheService() => _instance;
  ImagePrecacheService._();

  final Set<String> _precachedUrls = {};

  /// Precarga las imágenes de una lista de personajes en segundo plano.
  Future<void> precacheCharacterImages(
    BuildContext context,
    List<CharacterModel> characters,
  ) async {
    for (final character in characters) {
      if (!_precachedUrls.contains(character.image)) {
        _precachedUrls.add(character.image);
        // Precarga en segundo plano sin bloquear la UI
        _precacheImage(context, character.image);
      }
    }
  }

  /// Precarga una imagen individual.
  Future<void> _precacheImage(BuildContext context, String url) async {
    try {
      await precacheImage(
        CachedNetworkImageProvider(url),
        context,
      );
    } catch (_) {
      // Ignora errores de precarga silenciosamente
      _precachedUrls.remove(url);
    }
  }

  /// Limpia el registro de URLs precargadas.
  void clearCache() {
    _precachedUrls.clear();
  }
}
