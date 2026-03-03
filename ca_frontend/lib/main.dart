import 'package:ca_frontend/app.dart';
import 'package:ca_frontend/src/core/di/di.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('db');

  await initDi();

  runApp(const App());
}