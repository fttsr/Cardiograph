import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

sealed class BluetoothEvent extends Equatable {
  const BluetoothEvent();
  @override
  List<Object?> get props => [];
}

class BluetoothInitRequested extends BluetoothEvent {
  const BluetoothInitRequested();
}

class BluetoothAdapterStateChanged extends BluetoothEvent {
  final BluetoothAdapterState adapterState;
  const BluetoothAdapterStateChanged(this.adapterState);

  @override
  List<Object?> get props => [adapterState];
}

class BluetoothRequestPermissionsPressed extends BluetoothEvent {
  const BluetoothRequestPermissionsPressed();
}

class BluetoothStartScanPressed extends BluetoothEvent {
  const BluetoothStartScanPressed();
}

class BluetoothStopScanPressed extends BluetoothEvent {
  const BluetoothStopScanPressed();
}

class BluetoothConnectRequested extends BluetoothEvent {
  final BluetoothDevice device;
  const BluetoothConnectRequested(this.device);

  @override
  List<Object?> get props => [device.remoteId];
}
