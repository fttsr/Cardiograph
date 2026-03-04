import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BlueToothService {
  Future<bool> isSupported() => FlutterBluePlus.isSupported;
  Stream<BluetoothAdapterState> adapterStateStream() =>
      FlutterBluePlus.adapterState;
  Future<BluetoothAdapterState> currentAdapterState() =>
      FlutterBluePlus.adapterState.first;

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      final granted =
          statuses[Permission.bluetoothScan]?.isGranted ==
              true &&
          statuses[Permission.bluetoothConnect]?.isGranted ==
              true;

      return granted;
    }

    return true;
  }

  Future<void> startScan({required Duration timeout}) {
    return FlutterBluePlus.startScan(timeout: timeout);
  }

  Future<void> stopScan() => FlutterBluePlus.stopScan();

  Stream<List<ScanResult>> scanResultsStream() =>
      FlutterBluePlus.scanResults;

  Future<void> connect(
    BluetoothDevice device, {
    required Duration timeout,
  }) {
    return device.connect(timeout: timeout);
  }
}
