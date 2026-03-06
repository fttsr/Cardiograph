import 'dart:async';

import 'package:ca_frontend/src/core/storage/app_box.dart';
import 'package:ca_frontend/src/features/ecg/data/datasources/ecg_ble_data_source.dart';
import 'package:ca_frontend/src/features/ecg/data/datasources/ecg_remote_data_source.dart';
import 'package:ca_frontend/src/features/ecg/data/services/ecg_pdf_service.dart';
import 'package:ca_frontend/src/features/ecg/data/services/ecg_session_service.dart';
import 'package:ca_frontend/src/features/ecg/domain/entities/ecg_session_state.dart';
import 'package:ca_frontend/src/features/ecg/domain/repositories/ecg_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class EcgRepositoryImpl implements EcgRepository {
  EcgRepositoryImpl({
    required this.appBox,
    required this.remote,
    required this.ble,
    required this.pdf,
  });

  final AppBox appBox;
  final EcgRemoteDataSource remote;
  final EcgBleDataSource ble;
  final EcgPdfService pdf;

  EcgSessionService? _session;
  VoidCallback? _sessionListener;
  StreamController<EcgSessionState>? _controller;

  StreamController<EcgSessionState> get _streamController {
    final current = _controller;
    if (current != null && !current.isClosed) {
      return current;
    }
    final fresh = StreamController<EcgSessionState>.broadcast();
    _controller = fresh;
    return fresh;
  }

  void _emit(EcgSessionState value) {
    final controller = _streamController;
    if (!controller.isClosed) {
      controller.add(value);
    }
  }

  @override
  Future<void> start(BluetoothDevice device) async {
    if (_session != null && _sessionListener != null) {
      _session!.state.removeListener(_sessionListener!);
      _sessionListener = null;
    }
    await _session?.dispose();

    _session = EcgSessionService(
      device: device,
      appBox: appBox,
      remote: remote,
      ble: ble,
      pdf: pdf,
    );

    _sessionListener = () {
      final session = _session;
      if (session != null) {
        _emit(session.state.value);
      }
    };

    _session!.state.addListener(_sessionListener!);
    _emit(_session!.state.value);

    await _session!.start();
    _emit(_session!.state.value);
  }

  @override
  Stream<EcgSessionState> watch() async* {
    final session = _session;
    if (session != null) {
      yield session.state.value;
    }
    yield* _streamController.stream;
  }

  @override
  void toggleRecording() => _session?.toggleRecording();

  @override
  Future<void> saveAndFinish() async {
    final session = _session;
    if (session == null) return;
    await session.saveAndFinish();
    _emit(session.state.value);
  }

  @override
  Future<void> abort() async {
    final session = _session;
    if (session == null) return;
    await session.abort();
    _emit(session.state.value);
  }

  @override
  Future<void> dispose() async {
    if (_session != null && _sessionListener != null) {
      _session!.state.removeListener(_sessionListener!);
    }
    _sessionListener = null;
    await _session?.dispose();
    _session = null;

    final controller = _controller;
    _controller = null;
    await controller?.close();
  }
}
