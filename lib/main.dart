import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rick_and_morty/features/characters/presentation/bloc/character_bloc.dart';
import 'package:rick_and_morty/features/characters/presentation/bloc/favorites_cubit.dart';
import 'package:rick_and_morty/features/characters/presentation/pages/home_page.dart';
import 'package:rick_and_morty/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive para almacenamiento local.
  await Hive.initFlutter();

  // Inicializa inyección de dependencias.
  await di.init();

  runApp(const RickAndMortyApp());
}

/// Aplicación principal de Rick & Morty.
class RickAndMortyApp extends StatelessWidget {
  const RickAndMortyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<CharacterBloc>()),
        BlocProvider(create: (_) => di.sl<FavoritesCubit>()),
      ],
      child: MaterialApp(
        title: 'Rick & Morty App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const HomePage(),
      ),
    );
  }
}
