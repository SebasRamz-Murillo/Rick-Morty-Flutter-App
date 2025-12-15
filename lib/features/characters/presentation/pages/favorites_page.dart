import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/core/platform/adaptive_widgets.dart';
import 'package:rick_and_morty/features/characters/presentation/bloc/favorites_cubit.dart';
import 'package:rick_and_morty/features/characters/presentation/pages/character_detail_page.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/character_card.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/responsive_layout.dart';

/// Página de personajes favoritos.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    context.read<FavoritesCubit>().loadFavoriteCharacters();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        if (state.isLoadingCharacters) {
          return const Center(child: AdaptiveLoadingIndicator());
        }

        if (state.favoriteCharacters.isEmpty) {
          return _buildEmptyView();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await context.read<FavoritesCubit>().loadFavoriteCharacters();
          },
          child: _buildList(state),
        );
      },
    );
  }

  Widget _buildList(FavoritesState state) {
    final isMobile = ResponsiveLayout.isMobile(context);

    if (isMobile) {
      return ListView.builder(
        itemCount: state.favoriteCharacters.length,
        itemBuilder: (context, index) {
          return _buildCharacterItem(state.favoriteCharacters[index]);
        },
      );
    }

    final columns = ResponsiveLayout.getGridColumns(context);
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 2.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: state.favoriteCharacters.length,
      itemBuilder: (context, index) {
        return _buildCharacterItem(state.favoriteCharacters[index]);
      },
    );
  }

  Widget _buildCharacterItem(character) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favState) {
        final isFavorite = favState.favoriteIds.contains(character.id);

        return CharacterCard(
          character: character,
          isFavorite: isFavorite,
          heroTagPrefix: 'favorites_',
          onTap: () => _navigateToDetail(character),
          onFavoriteTap: () {
            context.read<FavoritesCubit>().toggleFavorite(character.id);
          },
        );
      },
    );
  }

  void _navigateToDetail(character) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CharacterDetailPage(
          character: character,
          heroTagPrefix: 'favorites_',
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes favoritos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega personajes a tus favoritos\npara verlos aquí',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
