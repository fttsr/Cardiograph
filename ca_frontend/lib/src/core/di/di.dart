import 'package:ca_frontend/src/core/storage/app_box.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

final sl = GetIt.instance;

Future<void> initDi() async {
  final box = Hive.box('db');
  sl.registerLazySingleton<Box>(() => box);
  sl.registerLazySingleton<AppBox>(() => AppBox(sl<Box>()));

}
