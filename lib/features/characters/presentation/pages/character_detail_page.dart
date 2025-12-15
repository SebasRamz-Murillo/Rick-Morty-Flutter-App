import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/core/platform/adaptive_widgets.dart';
import 'package:rick_and_morty/features/characters/data/models/character_model.dart';
import 'package:rick_and_morty/features/characters/presentation/bloc/favorites_cubit.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/responsive_layout.dart';

/// Página de detalle de un personaje.
class CharacterDetailPage extends StatelessWidget {
  final CharacterModel character;
  final String heroTagPrefix;

  const CharacterDetailPage({
    super.key,
    required this.character,
    this.heroTagPrefix = '',
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: character.name,
      showBackButton: true,
      actions: [_buildFavoriteButton(context)],
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context),
        tablet: _buildTabletLayout(context),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final isFavorite = state.favoriteIds.contains(character.id);
        return AdaptiveFavoriteButton(
          isFavorite: isFavorite,
          onPressed: () {
            context.read<FavoritesCubit>().toggleFavorite(character.id);
          },
        );
      },
    );
  }

  /// Layout para móviles (vertical).
  Widget _buildMobileLayout(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeroImage(),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildName(context),
                const SizedBox(height: 16),
                _buildStatusBadge(context),
                const SizedBox(height: 24),
                _buildInfoSection(context),
                const SizedBox(height: 24),
                _buildEpisodesSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Layout para tablets (horizontal).
  Widget _buildTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen y estado
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildHeroImage(isRounded: true),
                const SizedBox(height: 16),
                _buildStatusBadge(context),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Información
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildName(context),
                const SizedBox(height: 24),
                _buildInfoSection(context),
                const SizedBox(height: 24),
                _buildEpisodesSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage({bool isRounded = false}) {
    return Hero(
      tag: '${heroTagPrefix}character_image_${character.id}',
      child: ClipRRect(
        borderRadius: isRounded ? BorderRadius.circular(16) : BorderRadius.zero,
        child: CachedNetworkImage(
          imageUrl: character.image,
          height: 300,
          width: isRounded ? null : double.infinity,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            height: 300,
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            height: 300,
            color: Colors.grey[300],
            child: const Icon(Icons.person, size: 80, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildName(BuildContext context) {
    return Text(
      character.name,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final color = switch (character.status.toLowerCase()) {
      'alive' => Colors.green,
      'dead' => Colors.red,
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${character.status} - ${character.species}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _InfoTile(
          icon: Icons.person,
          label: 'Género',
          value: character.gender,
        ),
        _InfoTile(
          icon: Icons.category,
          label: 'Especie',
          value: character.species,
        ),
        if (character.type.isNotEmpty)
          _InfoTile(
            icon: Icons.label,
            label: 'Tipo',
            value: character.type,
          ),
        _InfoTile(
          icon: Icons.public,
          label: 'Origen',
          value: character.origin.name,
        ),
        _InfoTile(
          icon: Icons.location_on,
          label: 'Última ubicación',
          value: character.location.name,
        ),
      ],
    );
  }

  Widget _buildEpisodesSection(BuildContext context) {
    final totalEpisodes = character.episode.length;
    final previewCount = totalEpisodes > 10 ? 10 : totalEpisodes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Episodios ($totalEpisodes)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (totalEpisodes > previewCount)
              TextButton(
                onPressed: () => _showAllEpisodes(context),
                child: const Text('Ver todos'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: character.episode.take(previewCount).map((episodeUrl) {
            final episodeNumber = episodeUrl.split('/').last;
            return Chip(
              label: Text('Ep. $episodeNumber'),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            );
          }).toList(),
        ),
        if (totalEpisodes > previewCount)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showAllEpisodes(context),
                icon: const Icon(Icons.list),
                label: Text('Ver los $totalEpisodes episodios'),
              ),
            ),
          ),
      ],
    );
  }

  void _showAllEpisodes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Todos los episodios (${character.episode.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Lista de episodios
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: character.episode.length,
                itemBuilder: (context, index) {
                  final episodeUrl = character.episode[index];
                  final episodeNumber = episodeUrl.split('/').last;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        episodeNumber,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text('Episodio $episodeNumber'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tile de información con icono.
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
