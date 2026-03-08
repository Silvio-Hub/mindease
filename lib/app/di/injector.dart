import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mindease/data/datasources/auth_remote_datasource.dart';
import 'package:mindease/data/datasources/preferences_local_datasource.dart';
import 'package:mindease/data/datasources/task_remote_datasource.dart';
import 'package:mindease/data/repositories/auth_repository_impl.dart';
import 'package:mindease/data/repositories/preferences_repository_impl.dart';
import 'package:mindease/data/repositories/task_repository_impl.dart';
import 'package:mindease/domain/repositories/auth_repository.dart';
import 'package:mindease/domain/repositories/preferences_repository.dart';
import 'package:mindease/domain/repositories/task_repository.dart';
import 'package:mindease/domain/usecases/add_task_usecase.dart';
import 'package:mindease/domain/usecases/delete_task_usecase.dart';
import 'package:mindease/domain/usecases/get_current_user.dart';
import 'package:mindease/domain/usecases/get_tasks.dart';
import 'package:mindease/domain/usecases/load_preferences.dart';
import 'package:mindease/domain/usecases/login_usecase.dart';
import 'package:mindease/domain/usecases/register_usecase.dart';
import 'package:mindease/domain/usecases/save_preferences.dart';
import 'package:mindease/domain/usecases/update_contrast.dart';
import 'package:mindease/domain/usecases/update_task_usecase.dart';
import 'package:mindease/presentation/controllers/accessibility_cubit.dart';
import 'package:mindease/presentation/controllers/login_cubit.dart';
import 'package:mindease/presentation/controllers/register_cubit.dart';
import 'package:mindease/presentation/controllers/tasks_bloc.dart';

import 'package:mindease/firebase_options.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  debugPrint('Iniciando setupDependencies...');
  // External
  try {
    debugPrint('Inicializando Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase inicializado com sucesso.');
  } catch (e) {
    debugPrint('Erro ao inicializar Firebase: $e');
    rethrow;
  }

  try {
    debugPrint('Inicializando Hive...');
    await Hive.initFlutter();
    final prefsBox = await Hive.openBox<Map>('preferencesBox');
    debugPrint('Hive inicializado com sucesso.');

    sl.registerLazySingleton(() => FirebaseAuth.instance);
    sl.registerLazySingleton(() => FirebaseFirestore.instance);

    // Data Sources
    sl.registerLazySingleton<PreferencesLocalDataSource>(
      () => PreferencesLocalDataSource(prefsBox),
    );
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
    );
    sl.registerLazySingleton<TaskRemoteDataSource>(
      () => TaskRemoteDataSourceImpl(firestore: sl()),
    );

    // Repositories
    sl.registerLazySingleton<PreferencesRepository>(
      () => PreferencesRepositoryImpl(sl()),
    );
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerLazySingleton<TaskRepository>(
      () => TaskRepositoryImpl(remoteDataSource: sl()),
    );

    // UseCases
    sl.registerFactory(() => LoadPreferences(sl()));
    sl.registerFactory(() => SavePreferences(sl()));
    sl.registerFactory(() => UpdateContrast(sl()));
    sl.registerFactory(() => LoginUseCase(sl()));
    sl.registerFactory(() => RegisterUseCase(sl()));
    sl.registerFactory(() => GetTasks(sl()));
    sl.registerFactory(() => AddTaskUseCase(sl()));
    sl.registerFactory(() => UpdateTaskUseCase(sl()));
    sl.registerFactory(() => DeleteTaskUseCase(sl()));
    sl.registerFactory(() => GetCurrentUser(sl()));

    // Cubits / Blocs
    sl.registerFactory(
      () => AccessibilityCubit(
        updateContrast: sl(),
        savePreferences: sl(),
        loadPreferences: sl(),
      ),
    );

    sl.registerFactory(() => LoginCubit(sl()));
    sl.registerFactory(() => RegisterCubit(sl()));
    sl.registerFactory(
      () => TasksBloc(
        getTasks: sl(),
        addTask: sl(),
        updateTask: sl(),
        deleteTask: sl(),
        getCurrentUser: sl(),
      ),
    );
    debugPrint('Dependências registradas com sucesso.');
  } catch (e) {
    debugPrint('Erro ao configurar dependências: $e');
    rethrow;
  }
}
