import 'package:ca_frontend/src/core/storage/app_box.dart';
import 'package:ca_frontend/src/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ca_frontend/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ca_frontend/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:ca_frontend/src/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:ca_frontend/src/features/auth/domain/usecases/login_usecase.dart';
import 'package:ca_frontend/src/features/auth/domain/usecases/register_usecase.dart';
import 'package:ca_frontend/src/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:ca_frontend/src/features/auth/domain/usecases/save_session_usecase.dart';
import 'package:ca_frontend/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ca_frontend/src/features/bluetooth/data/repositories/bluetooth_repository_impl.dart';
import 'package:ca_frontend/src/features/bluetooth/data/services/bluetooth_service.dart';
import 'package:ca_frontend/src/features/bluetooth/domain/repositories/bluetooth_repository.dart';
import 'package:ca_frontend/src/features/bluetooth/presentation/bloc/bluetooth_bloc.dart';
import 'package:ca_frontend/src/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ca_frontend/src/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ca_frontend/src/features/profile/domain/repositories/profile_repository.dart';
import 'package:ca_frontend/src/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:ca_frontend/src/features/profile/domain/usecases/save_profile_usecase.dart';
import 'package:ca_frontend/src/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

final sl = GetIt.instance;

Future<void> initDi() async {
  final box = Hive.box('db');
  sl.registerLazySingleton<Box>(() => box);
  sl.registerLazySingleton<AppBox>(() => AppBox(sl<Box>()));

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl(), box: sl()),
  );
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => SaveSessionUsecase(sl()));
  sl.registerLazySingleton(() => RegisterUsecase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUsecase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUsecase(sl()));
  sl.registerFactory(
    () => AuthBloc(
      login: sl(),
      saveSession: sl(),
      register: sl(),
      forgotPassword: sl(),
      resetPassword: sl(),
    ),
  );

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GetProfileUsecase(sl()));
  sl.registerLazySingleton(() => SaveProfileUsecase(sl()));
  sl.registerFactory(
    () => ProfileBloc(
      appBox: sl(),
      getProfile: sl(),
      saveProfile: sl(),
    ),
  );

  sl.registerLazySingleton(() => BlueToothService());
  sl.registerLazySingleton<BluetoothRepository>(
    () => BluetoothRepositoryImpl(sl()),
  );
  sl.registerFactory(() => BluetoothBloc(repo: sl()));
}
