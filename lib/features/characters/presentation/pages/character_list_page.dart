import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/core/platform/adaptive_widgets.dart';
import 'package:rick_and_morty/core/services/image_precache_service.dart';
import 'package:rick_and_morty/features/characters/presentation/bloc/character_bloc.dart';
import 'package:rick_and_morty/features/characters/presentation/bloc/favorites_cubit.dart';
import 'package:rick_and_morty/features/characters/presentation/pages/character_detail_page.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/character_card.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/responsive_layout.dart';

/// Página principal con listado de personajes.
class CharacterListPage extends StatefulWidget {
  const CharacterListPage({super.key});

  @override
  State<CharacterListPage> createState() => _CharacterListPageState();
}

class _CharacterListPageState extends State<CharacterListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _isPrefetching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<CharacterBloc>().add(const CharacterFetched());
    context.read<FavoritesCubit>().loadFavorites();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    if (maxScroll <= 0) return;

    final scrollPercentage = currentScroll / maxScroll;

    // Prefetch al 70% del scroll (anticipar carga)
    if (scrollPercentage >= 0.7 && !_isPrefetching) {
      _isPrefetching = true;
      context.read<CharacterBloc>().add(const CharacterPrefetchRequested());
      // Reset flag después de un delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _isPrefetching = false;
      });
    }

    // Cargar más al 90% (comportamiento normal)
    if (scrollPercentage >= 0.9) {
      context.read<CharacterBloc>().add(const CharacterFetched());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(child: _buildCharacterList()),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AdaptiveSearchField(
        controller: _searchController,
        placeholder: 'Buscar personaje...',
        onChanged: (query) {
          context.read<CharacterBloc>().add(CharacterSearched(query));
        },
        onClear: () {
          _searchController.clear();
          context.read<CharacterBloc>().add(const CharacterSearched(''));
        },
      ),
    );
  }

  Widget _buildCharacterList() {
    return BlocConsumer<CharacterBloc, CharacterState>(
      listenWhen: (previous, current) =>
          previous.characters.length != current.characters.length ||
          previous.searchQuery != current.searchQuery,
      listener: (context, state) {
        // Precarga imágenes cuando se cargan personajes
        if (state.characters.isNotEmpty) {
          ImagePrecacheService().precacheCharacterImages(context, state.characters);
        }
        // Scroll al inicio cuando cambia la búsqueda
        if (state.searchQuery != '' && _scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      },
      builder: (context, state) {
        final isSearching = state.status == CharacterStatus.loading &&
            state.searchQuery.isNotEmpty;
        final isLoadingMore = state.status == CharacterStatus.loading &&
            state.characters.isNotEmpty &&
            state.searchQuery.isEmpty;

        // Sin personajes y cargando inicialmente
        if (state.characters.isEmpty && state.status == CharacterStatus.loading) {
          return const AdaptiveLoadingIndicator();
        }

        // Error sin personajes
        if (state.characters.isEmpty && state.status == CharacterStatus.failure) {
          return _buildErrorView(state.errorMessage ?? 'Error desconocido');
        }

        // Sin resultados en búsqueda
        if (state.characters.isEmpty && state.status == CharacterStatus.success) {
          return _buildEmptyView();
        }

        // Lista con contenido
        return Column(
          children: [
            // Indicador de búsqueda en progreso
            if (isSearching)
              const LinearProgressIndicator(),
            Expanded(
              child: _buildList(state, isLoading: isLoadingMore),
            ),
          ],
        );
      },
    );
  }

  Widget _buildList(CharacterState state, {bool isLoading = false}) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<CharacterBloc>().add(const CharacterRefreshed());
      },
      child: isMobile
          ? _buildListView(state, isLoading)
          : _buildGridView(state, isLoading),
    );
  }

  Widget _buildListView(CharacterState state, bool isLoading) {
    final itemCount = state.characters.length + (isLoading || !state.hasReachedMax ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      cacheExtent: 500, // Pre-renderiza items fuera de pantalla
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= state.characters.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: AdaptiveLoadingIndicator(),
          );
        }
        return _buildCharacterItem(state.characters[index]);
      },
    );
  }

  Widget _buildGridView(CharacterState state, bool isLoading) {
    final columns = ResponsiveLayout.getGridColumns(context);
    final itemCount = state.characters.length + (isLoading || !state.hasReachedMax ? 1 : 0);

    return GridView.builder(
      controller: _scrollController,
      cacheExtent: 500, // Pre-renderiza items fuera de pantalla
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 2.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= state.characters.length) {
          return const AdaptiveLoadingIndicator();
        }
        return _buildCharacterItem(state.characters[index]);
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
          heroTagPrefix: 'list_',
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
          heroTagPrefix: 'list_',
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<CharacterBloc>().add(const CharacterRefreshed());
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron personajes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
