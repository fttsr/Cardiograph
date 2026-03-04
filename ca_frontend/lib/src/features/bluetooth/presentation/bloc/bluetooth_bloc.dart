import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../domain/repositories/bluetooth_repository.dart';
import 'bluetooth_event.dart';
import 'bluetooth_state.dart';

class BluetoothBloc
    extends Bloc<BluetoothEvent, BlueToothState> {
  final BluetoothRepository repo;

  StreamSubscription<BluetoothAdapterState>? _adapterSub;
  StreamSubscription<List<ScanResult>>? _scanSub;
  Timer? _scanStopTimer;
  Timer? _navigateTimer;

  BluetoothBloc({required this.repo})
    : super(BlueToothState.initial()) {
    on<BluetoothInitRequested>(_onInit);
    on<BluetoothRequestPermissionsPressed>(
      _onRequestPermissions,
    );
    on<BluetoothAdapterStateChanged>(_onAdapterChanged);
    on<BluetoothStartScanPressed>(_onStartScan);
    on<BluetoothStopScanPressed>(_onStopScan);
    on<BluetoothConnectRequested>(_onConnect);

    _adapterSub = repo.adapterStateStream().distinct().listen((
      s,
    ) {
      add(BluetoothAdapterStateChanged(s));
    });
  }

  @override
  Future<void> close() {
    _adapterSub?.cancel();
    _scanSub?.cancel();
    _scanStopTimer?.cancel();
    _navigateTimer?.cancel();
    return super.close();
  }

  void _setStatus(
    Emitter<BlueToothState> emit,
    String msg,
    IconData icon,
    Color color,
  ) {
    emit(
      state.copyWith(
        statusMessage: msg,
        statusIcon: icon,
        statusColor: color,
      ),
    );
  }

  Future<void> _onInit(
    BluetoothInitRequested e,
    Emitter<BlueToothState> emit,
  ) async {
    emit(BlueToothState.initial());

    final supported = await repo.isSupported();
    if (!supported) {
      _setStatus(
        emit,
        "Bluetooth LE не поддерживается",
        Icons.bluetooth_disabled,
        Colors.red,
      );
      emit(state.copyWith(loadingInit: false));
      return;
    }

    final adapter = await repo.currentAdapterState();
    final enabled = adapter == BluetoothAdapterState.on;

    if (!enabled) {
      _setStatus(
        emit,
        "Включите Bluetooth",
        Icons.bluetooth_disabled,
        Colors.orange,
      );
      emit(
        state.copyWith(
          loadingInit: false,
          bluetoothEnabled: false,
        ),
      );
      return;
    }

    final perms = await repo.requestPermissions();

    if (!perms) {
      _setStatus(
        emit,
        "Разрешения не получены. Нажмите ещё раз или предоставьте разрешения в настройках",
        Icons.warning,
        Colors.orange,
      );
      emit(
        state.copyWith(
          loadingInit: false,
          bluetoothEnabled: true,
          permissionsGranted: false,
        ),
      );
      return;
    }

    _setStatus(
      emit,
      "Разрешения получены!",
      Icons.check_circle,
      Colors.green,
    );
    emit(
      state.copyWith(
        loadingInit: false,
        bluetoothEnabled: true,
        permissionsGranted: true,
      ),
    );

    add(const BluetoothStartScanPressed());
  }

  Future<void> _onRequestPermissions(
    BluetoothRequestPermissionsPressed e,
    Emitter<BlueToothState> emit,
  ) async {
    final perms = await repo.requestPermissions();
    emit(state.copyWith(permissionsGranted: perms));
    if (perms && state.bluetoothEnabled) {
      _setStatus(
        emit,
        "Разрешения получены!",
        Icons.check_circle,
        Colors.green,
      );
      add(const BluetoothStartScanPressed());
    } else if (!perms) {
      _setStatus(
        emit,
        "Разрешения не получены. Нажмите ещё раз или предоставьте разрешения в настройках",
        Icons.warning,
        Colors.orange,
      );
    }
  }

  Future<void> _onStartScan(
    BluetoothStartScanPressed e,
    Emitter<BlueToothState> emit,
  ) async {
    if (state.scanning) return;
    if (!state.bluetoothEnabled) {
      _setStatus(
        emit,
        "Включите Bluetooth",
        Icons.bluetooth_disabled,
        Colors.orange,
      );
      return;
    }
    if (!state.permissionsGranted) {
      _setStatus(
        emit,
        "Требуются разрешения",
        Icons.warning,
        Colors.orange,
      );
      return;
    }

    _setStatus(
      emit,
      "Поиск кардиографа...",
      Icons.search,
      Colors.blue,
    );
    emit(
      state.copyWith(
        scanning: true,
        devices: [],
        connecting: false,
        connected: false,
      ),
    );

    _scanSub?.cancel();
    _scanSub = repo.scanResultsStream().listen((results) {
      final set = <BluetoothDevice>{};
      for (final r in results) {
        final device = r.device;
        final adv = r.advertisementData;

        if (device.platformName == "BT05" ||
            adv.advName == "BT05") {
          set.add(device);
        }
      }
      emit(state.copyWith(devices: set.toList()));
    });

    try {
      await repo.startScan(timeout: const Duration(seconds: 15));

      _scanStopTimer?.cancel();
      _scanStopTimer = Timer(
        const Duration(seconds: 15),
        () async {
          if (state.scanning) await repo.stopScan();
          if (state.devices.isEmpty) {
            emit(state.copyWith(scanning: false));
            _setStatus(
              emit,
              "Устройства не найдены",
              Icons.search_off,
              Colors.blue,
            );
          } else {
            emit(state.copyWith(scanning: false));
          }
        },
      );
    } catch (err) {
      _setStatus(
        emit,
        "Ошибка запуска сканирования: $err",
        Icons.error,
        Colors.red,
      );
      emit(state.copyWith(scanning: false));
    }
  }

  Future<void> _onStopScan(
    BluetoothStopScanPressed e,
    Emitter<BlueToothState> emit,
  ) async {
    _scanStopTimer?.cancel();
    _scanStopTimer = null;

    _scanSub?.cancel();
    _scanSub = null;

    await repo.stopScan();
    emit(state.copyWith(scanning: false));
  }

  Future<void> _onAdapterChanged(
    BluetoothAdapterStateChanged e,
    Emitter<BlueToothState> emit,
  ) async {
    final enabled = e.adapterState == BluetoothAdapterState.on;

    emit(state.copyWith(bluetoothEnabled: enabled));

    if (enabled && !state.bluetoothEnabled) {
      add(const BluetoothInitRequested());
    }
  }

  Future<void> _onConnect(
    BluetoothConnectRequested e,
    Emitter<BlueToothState> emit,
  ) async {
    final device = e.device;

    _setStatus(
      emit,
      "Подключение к ${device.platformName}...",
      Icons.bluetooth_searching,
      Colors.orange,
    );
    emit(
      state.copyWith(
        selectedDevice: device,
        connecting: true,
        connected: false,
      ),
    );

    try {
      await repo.stopScan();
      await repo.connect(
        device,
        timeout: const Duration(seconds: 10),
      );

      _setStatus(
        emit,
        "Подключено к ${device.platformName}",
        Icons.bluetooth_connected,
        Colors.green,
      );
      emit(state.copyWith(connecting: false, connected: true));

      _navigateTimer?.cancel();
      _navigateTimer = Timer(const Duration(seconds: 3), () {
        emit(state.copyWith(navigateToEcg: true));
      });
    } catch (err) {
      _setStatus(
        emit,
        "Ошибка подключения: $err",
        Icons.error,
        Colors.red,
      );
      emit(state.copyWith(connecting: false, connected: false));
      add(const BluetoothStartScanPressed());
    }
  }
}
