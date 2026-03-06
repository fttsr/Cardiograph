import 'package:ca_frontend/src/features/ecg/domain/entities/ecg_session_state.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class EcgRepository {
  Future<void> start(BluetoothDevice device);

  Stream<EcgSessionState> watch();

  void toggleRecording();

  Future<void> saveAndFinish();
  Future<void> abort();

  Future<void> dispose();
}
