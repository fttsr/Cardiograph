import 'dart:async';
import 'dart:math';

import 'package:ca_frontend/src/core/storage/app_box.dart';
import 'package:ca_frontend/src/features/ecg/data/datasources/ecg_ble_data_source.dart';
import 'package:ca_frontend/src/features/ecg/data/datasources/ecg_remote_data_source.dart';
import 'package:ca_frontend/src/features/ecg/data/services/ecg_pdf_service.dart';
import 'package:ca_frontend/src/features/ecg/data/services/hr_estimator.dart';
import 'package:ca_frontend/src/features/ecg/domain/entities/ecg_session_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class EcgSessionService {
  EcgSessionService({
    required this.device,
    required this.appBox,
    required this.remote,
    required this.ble,
    required this.pdf,
    this.sessionSeconds = 60,
    this.sampleRate = 250,
    this.maxDrawPoints = 2000,
  });

  final BluetoothDevice device;
  final AppBox appBox;
  final EcgRemoteDataSource remote;
  final EcgBleDataSource ble;
  final EcgPdfService pdf;

  final int sessionSeconds;
  final int sampleRate;
  final int maxDrawPoints;

  late final HrEstimator _hr = HrEstimator(fs: sampleRate);

  final ValueNotifier<EcgSessionState> state =
      ValueNotifier<EcgSessionState>(
        EcgSessionState.initial(deviceName: ''),
      );

  StreamSubscription<List<double>>? _bleSub;
  Timer? _timer;

  bool _started = false;
  bool _disconnecting = false;

  String? _patientId;
  String? _measurementId;

  final List<double> _allSamples = [];
  final List<double> _draw = [];
  final List<int> _heartRateHistory = [];

  int _remaining = 60;
  int _elapsedSeconds = 0;
  int _lastHrSentSecond = -1;
  int? _lastBpm;

  double _baseline = 512.0;
  double _displayLp = 0.0;
  double _hrLp = 0.0;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    _remaining = sessionSeconds;
    _elapsedSeconds = 0;
    _lastHrSentSecond = -1;
    _lastBpm = null;

    _allSamples.clear();
    _draw.clear();
    _heartRateHistory.clear();

    _baseline = 512.0;
    _displayLp = 0.0;
    _hrLp = 0.0;

    _hr.reset();

    state.value = state.value.copyWith(
      deviceName: device.platformName.isNotEmpty
          ? device.platformName
          : 'Устройство',
      remainingSeconds: _remaining,
      isRecording: true,
      isSaving: false,
      connected: true,
      heartRate: null,
      ecgDraw: const [],
    );

    try {
      await _startMeasurementIfNeeded();
    } catch (e) {
      debugPrint('[ECG] create measurement skipped: $e');
      _measurementId = null;
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (
      _,
    ) async {
      if (!_started || !state.value.isRecording) return;

      _elapsedSeconds++;
      _remaining = max(0, sessionSeconds - _elapsedSeconds);

      final bpm = _lastBpm;
      if (bpm != null) {
        _heartRateHistory.add(bpm);
      } else if (_heartRateHistory.isNotEmpty) {
        _heartRateHistory.add(_heartRateHistory.last);
      }

      state.value = state.value.copyWith(
        remainingSeconds: _remaining,
      );

      if (_measurementId != null &&
          bpm != null &&
          _elapsedSeconds != _lastHrSentSecond) {
        _lastHrSentSecond = _elapsedSeconds;
        unawaited(
          remote.saveHeartRate(
            measurementId: _measurementId!,
            second: _elapsedSeconds,
            bpm: bpm,
          ),
        );
      }

      if (_remaining <= 0) {
        await saveAndFinish();
      }
    });

    _bleSub?.cancel();
    _bleSub = ble
        .samplesStream(device)
        .listen(
          (chunk) {
            if (!_started || !state.value.isRecording) return;

            for (final raw in chunk) {
              final processed = _processRawSample(raw);

              _allSamples.add(processed.hrSignal);

              _draw.add(processed.displaySignal);
              if (_draw.length > maxDrawPoints) {
                _draw.removeRange(
                  0,
                  _draw.length - maxDrawPoints,
                );
              }

              final bpm = _hr.update(processed.hrSignal);
              if (bpm != null) {
                _lastBpm = bpm;
                state.value = state.value.copyWith(
                  heartRate: bpm,
                );
              }
            }

            state.value = state.value.copyWith(
              ecgDraw: List<double>.from(_draw),
            );
          },
          onError: (e) {
            debugPrint('[ECG] BLE stream error: $e');
            state.value = state.value.copyWith(connected: false);
          },
          cancelOnError: false,
        );
  }

  void toggleRecording() {
    if (!_started || state.value.isSaving) return;

    final next = !state.value.isRecording;
    if (!next) {
      _insertPauseGap();
    }

    state.value = state.value.copyWith(
      isRecording: next,
      ecgDraw: List<double>.from(_draw),
    );
  }

  Future<void> abort() async {
    state.value = state.value.copyWith(
      isRecording: false,
      isSaving: false,
    );
    await _stopInternal(disconnectDevice: true);
  }

  Future<void> saveAndFinish() async {
    if (state.value.isSaving) return;
    state.value = state.value.copyWith(isSaving: true);

    try {
      final fileName = pdf.makeFileName();
      final pdfBytes = await pdf.buildPdf(
        samples: _allSamples,
        sampleRate: sampleRate,
        heartRate: state.value.heartRate,
        heartRateHistory: List<int>.from(_heartRateHistory),
      );

      if (pdfBytes.isEmpty) {
        throw Exception('PDF не был сформирован');
      }

      final filePath = await pdf.savePdfToFile(
        bytes: pdfBytes,
        fileName: fileName,
      );

      await appBox.addPdfFile(filePath);
      await appBox.setLastEcgTime();

      if (_measurementId != null) {
        try {
          await remote.createReport(
            measurementId: _measurementId!,
            filePath: filePath,
          );
        } catch (e) {
          debugPrint('[ECG] create report skipped: $e');
        }
      }

      await pdf.sharePdf(bytes: pdfBytes, fileName: fileName);
    } finally {
      state.value = state.value.copyWith(
        isRecording: false,
        isSaving: false,
      );
      await _stopInternal(disconnectDevice: true);
    }
  }

  Future<void> _startMeasurementIfNeeded() async {
    final userId = appBox.userId;
    if (userId == null || userId.isEmpty) {
      throw Exception('user_id not found');
    }

    _patientId ??= await remote.getPatientIdByUser(userId);
    _measurementId = await remote.createMeasurement(_patientId!);
  }

  Future<void> _stopInternal({
    required bool disconnectDevice,
  }) async {
    _timer?.cancel();
    _timer = null;

    await _bleSub?.cancel();
    _bleSub = null;

    _started = false;

    if (disconnectDevice) {
      await _disconnectFromDevice();
    }
  }

  Future<void> _disconnectFromDevice() async {
    if (_disconnecting) return;
    _disconnecting = true;

    try {
      try {
        await device.disconnect();
      } catch (e) {
        debugPrint('[ECG] disconnect error ignored: $e');
      }
    } finally {
      _disconnecting = false;
      state.value = state.value.copyWith(connected: false);
    }
  }

  void _insertPauseGap({int gapLength = 120}) {
    for (int i = 0; i < gapLength; i++) {
      _draw.add(0.0);
    }

    if (_draw.length > maxDrawPoints) {
      _draw.removeRange(0, _draw.length - maxDrawPoints);
    }
  }

  Future<void> dispose() async {
    await _stopInternal(disconnectDevice: true);
    state.dispose();
  }

  _ProcessedSample _processRawSample(double raw) {
    final double baselineAlpha = _lowPassAlpha(0.7);
    _baseline += baselineAlpha * (raw - _baseline);
    final double centered = raw - _baseline;

    final double displayAlpha = _lowPassAlpha(18.0);
    _displayLp += displayAlpha * (centered - _displayLp);

    final double hrAlpha = _lowPassAlpha(15.0);
    _hrLp += hrAlpha * (centered - _hrLp);

    const double displayDivisor = 42.0;

    final double displaySignal = (_displayLp / displayDivisor)
        .clamp(-3.0, 3.0);

    return _ProcessedSample(
      displaySignal: displaySignal,
      hrSignal: _hrLp,
    );
  }

  double _lowPassAlpha(double cutoffHz) {
    final double dt = 1.0 / sampleRate;
    final double rc = 1.0 / (2 * pi * cutoffHz);
    return dt / (rc + dt);
  }
}

class _ProcessedSample {
  const _ProcessedSample({
    required this.displaySignal,
    required this.hrSignal,
  });

  final double displaySignal;
  final double hrSignal;
}
