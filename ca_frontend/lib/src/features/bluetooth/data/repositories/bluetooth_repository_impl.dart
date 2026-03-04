import 'package:ca_frontend/src/features/bluetooth/domain/repositories/bluetooth_repository.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/bluetooth_service.dart';

class BluetoothRepositoryImpl implements BluetoothRepository {
  final BlueToothService service;
  BluetoothRepositoryImpl(this.service);

  @override
  Stream<BluetoothAdapterState> adapterStateStream() {
    return service.adapterStateStream();
  }

  @override
  Future<void> connect(
    BluetoothDevice device, {
    required Duration timeout,
  }) {
    return service.connect(device, timeout: timeout);
  }

  @override
  Future<BluetoothAdapterState> currentAdapterState() {
    return service.currentAdapterState();
  }

  @override
  Future<bool> isSupported() {
    return service.isSupported();
  }

  @override
  Future<bool> requestPermissions() {
    return service.requestPermissions();
  }

  @override
  Stream<List<ScanResult>> scanResultsStream() {
    return service.scanResultsStream();
  }

  @override
  Future<void> startScan({required Duration timeout}) {
    return service.startScan(timeout: timeout);
  }

  @override
  Future<void> stopScan() {
    return service.stopScan();
  }
}
