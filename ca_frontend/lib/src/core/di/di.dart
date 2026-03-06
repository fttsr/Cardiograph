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
import 'package:ca_frontend/src/features/ecg/data/datasources/ecg_ble_data_source.dart';
import 'package:ca_frontend/src/features/ecg/data/datasources/ecg_remote_data_source.dart';
import 'package:ca_frontend/src/features/ecg/data/repositories/ecg_repository_impl.dart';
import 'package:ca_frontend/src/features/ecg/data/services/ecg_pdf_service.dart';
import 'package:ca_frontend/src/features/ecg/domain/repositories/ecg_repository.dart';
import 'package:ca_frontend/src/features/ecg/presentation/bloc/ecg_bloc.dart';
import 'package:ca_frontend/src/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ca_frontend/src/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ca_frontend/src/features/profile/domain/repositories/profile_repository.dart';
import 'package:ca_frontend/src/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:ca_frontend/src/features/profile/domain/usecases/save_profile_usecase.dart';
import 'package:ca_frontend/src/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:ca_frontend/src/features/results/data/datasources/results_local_data_source.dart';
import 'package:ca_frontend/src/features/results/data/repositories/results_repository_impl.dart';
import 'package:ca_frontend/src/features/results/domain/repositories/results_repository.dart';
import 'package:ca_frontend/src/features/results/presentation/bloc/results_bloc.dart';
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

  sl.registerLazySingleton<EcgRemoteDataSource>(
    () => EcgRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton(() => EcgBleDataSource());
  sl.registerLazySingleton(() => EcgPdfService());
  sl.registerFactory<EcgRepository>(
    () => EcgRepositoryImpl(
      appBox: sl(),
      remote: sl(),
      ble: sl(),
      pdf: sl(),
    ),
  );

  sl.registerFactory(() => EcgBloc(repo: sl()));

  sl.registerLazySingleton<ResultsLocalDataSource>(
    () => ResultsLocalDataSource(box: sl<Box>(), appBox: sl()),
  );
  sl.registerLazySingleton<ResultsRepository>(
    () => ResultsRepositoryImpl(sl()),
  );
  sl.registerFactory(() => ResultsBloc(repository: sl()));
}
