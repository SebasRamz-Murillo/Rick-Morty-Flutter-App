import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rick_and_morty/features/characters/data/models/character_model.dart';

/// Card de personaje para la lista.
/// Diseño responsivo que se adapta al tamaño de pantalla.
class CharacterCard extends StatelessWidget {
  final CharacterModel character;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final String heroTagPrefix;

  const CharacterCard({
    super.key,
    required this.character,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
    this.heroTagPrefix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // Avatar con Hero animation y caché
            Hero(
              tag: '${heroTagPrefix}character_image_${character.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: character.image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _ImagePlaceholder(),
                  errorWidget: (_, __, ___) => _ImagePlaceholder(isError: true),
                ),
              ),
            ),
            // Información del personaje
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _StatusIndicator(status: character.status),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${character.status} - ${character.species}',
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Botón de favorito
            IconButton(
              onPressed: onFavoriteTap,
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Indicador de estado del personaje (alive, dead, unknown).
class _StatusIndicator extends StatelessWidget {
  final String status;

  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status.toLowerCase()) {
      'alive' => Colors.green,
      'dead' => Colors.red,
      _ => Colors.grey,
    };

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Placeholder animado para imágenes en carga.
class _ImagePlaceholder extends StatelessWidget {
  final bool isError;

  const _ImagePlaceholder({this.isError = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.grey[300],
      child: isError
          ? const Icon(Icons.person, size: 40, color: Colors.grey)
          : const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
    );
  }
}
