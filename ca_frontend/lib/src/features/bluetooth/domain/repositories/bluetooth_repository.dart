import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class BluetoothRepository {
  Future<bool> isSupported();
  Future<bool> requestPermissions();

  Stream<BluetoothAdapterState> adapterStateStream();
  Future<BluetoothAdapterState> currentAdapterState();

  Stream<List<ScanResult>> scanResultsStream();
  Future<void> startScan({required Duration timeout});
  Future<void> stopScan();

  Future<void> connect(
    BluetoothDevice device, {
    required Duration timeout,
  });
}
