import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mindease/data/datasources/auth_local_datasource.dart';
import 'package:mindease/data/repositories/auth_repository_impl.dart';
import 'package:mindease/domain/repositories/auth_repository.dart';
import 'package:mindease/domain/usecases/login_usecase.dart';
import 'package:mindease/domain/usecases/register_usecase.dart';
import 'package:mindease/presentation/controllers/login_cubit.dart';
import 'package:mindease/presentation/controllers/register_cubit.dart';
import 'package:mindease/data/datasources/preferences_local_datasource.dart';
import 'package:mindease/data/repositories/preferences_repository_impl.dart';
import 'package:mindease/domain/repositories/preferences_repository.dart';
import 'package:mindease/domain/usecases/load_preferences.dart';
import 'package:mindease/domain/usecases/save_preferences.dart';
import 'package:mindease/domain/usecases/update_contrast.dart';
import 'package:mindease/presentation/controllers/accessibility_cubit.dart';
import 'package:mindease/data/datasources/tasks_local_datasource.dart';
import 'package:mindease/data/repositories/task_repository_impl.dart';
import 'package:mindease/domain/repositories/task_repository.dart';
import 'package:mindease/presentation/controllers/tasks_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  await Hive.initFlutter();
  final prefsBox = await Hive.openBox<Map>('preferencesBox');
  final tasksBox = await Hive.openBox<Map>('tasksBox');
  final authBox = await Hive.openBox<Map>('authBox');

  sl.registerLazySingleton(() => PreferencesLocalDataSource(prefsBox));
  sl.registerLazySingleton<PreferencesRepository>(
    () => PreferencesRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => TasksLocalDataSource(tasksBox));
  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(sl()));

  sl.registerLazySingleton(() => AuthLocalDataSource(authBox));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerFactory(() => LoginUseCase(sl()));
  sl.registerFactory(() => LoginCubit(sl()));
  sl.registerFactory(() => RegisterUseCase(sl()));
  sl.registerFactory(() => RegisterCubit(sl()));

  sl.registerFactory(() => LoadPreferences(sl()));
  sl.registerFactory(() => SavePreferences(sl()));
  sl.registerFactory(() => UpdateContrast(sl()));

  sl.registerFactory(
    () => AccessibilityCubit(
      updateContrast: sl(),
      savePreferences: sl(),
      loadPreferences: sl(),
    ),
  );
  sl.registerFactory(() => TasksBloc(sl()));
}
