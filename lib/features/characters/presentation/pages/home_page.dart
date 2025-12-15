import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/core/platform/adaptive_widgets.dart';
import 'package:rick_and_morty/features/characters/presentation/bloc/favorites_cubit.dart';
import 'package:rick_and_morty/features/characters/presentation/pages/character_list_page.dart';
import 'package:rick_and_morty/features/characters/presentation/pages/favorites_page.dart';

/// Página principal con navegación entre personajes y favoritos.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    CharacterListPage(),
    FavoritesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: _currentIndex == 0 ? 'Rick & Morty' : 'Mis Favoritos',
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final favoriteCount = state.favoriteIds.length;

        return NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
            if (index == 1) {
              context.read<FavoritesCubit>().loadFavoriteCharacters();
            }
          },
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'Personajes',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: favoriteCount > 0,
                label: Text('$favoriteCount'),
                child: const Icon(Icons.favorite_outline),
              ),
              selectedIcon: Badge(
                isLabelVisible: favoriteCount > 0,
                label: Text('$favoriteCount'),
                child: const Icon(Icons.favorite),
              ),
              label: 'Favoritos',
            ),
          ],
        );
      },
    );
  }
}
