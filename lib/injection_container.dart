import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:rick_and_morty/core/network/dio_client.dart';
import 'package:rick_and_morty/core/utils/constants.dart';
import 'package:rick_and_morty/features/characters/data/datasources/character_local_datasource.dart';
import 'package:rick_and_morty/features/characters/data/datasources/character_remote_datasource.dart';
import 'package:rick_and_morty/features/characters/data/repositories/character_repository_impl.dart';
import 'package:rick_and_morty/features/characters/domain/repositories/character_repository.dart';
import 'package:rick_and_morty/features/characters/presentation/bloc/character_bloc.dart';
import 'package:rick_and_morty/features/characters/presentation/bloc/favorites_cubit.dart';

/// Instancia global de GetIt para inyección de dependencias.
final sl = GetIt.instance;

/// Inicializa todas las dependencias de la aplicación.
Future<void> init() async {
  // Bloc & Cubit
  sl.registerFactory(() => CharacterBloc(sl()));
  sl.registerFactory(() => FavoritesCubit(sl()));

  // Repositorios
  sl.registerLazySingleton<CharacterRepository>(
    () => CharacterRepositoryImpl(sl(), sl()),
  );

  // Datasources
  sl.registerLazySingleton<CharacterRemoteDataSource>(
    () => CharacterRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CharacterLocalDataSource>(
    () => CharacterLocalDataSourceImpl(sl()),
  );

  // Core
  sl.registerLazySingleton(() => DioClient());

  // External - Hive Box
  final favoritesBox = await Hive.openBox<List<dynamic>>(HiveConstants.favoritesBox);
  sl.registerLazySingleton<Box<List<dynamic>>>(() => favoritesBox);
}
