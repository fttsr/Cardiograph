import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BlueToothState extends Equatable {
  final bool loadingInit;
  final bool bluetoothEnabled;
  final bool permissionsGranted;

  final bool scanning;
  final List<BluetoothDevice> devices;

  final BluetoothDevice? selectedDevice;
  final bool connecting;
  final bool connected;

  final String statusMessage;
  final IconData statusIcon;
  final Color statusColor;

  final bool navigateToEcg;

  const BlueToothState({
    required this.loadingInit,
    required this.bluetoothEnabled,
    required this.permissionsGranted,
    required this.scanning,
    required this.devices,
    required this.selectedDevice,
    required this.connecting,
    required this.connected,
    required this.statusMessage,
    required this.statusIcon,
    required this.statusColor,
    required this.navigateToEcg,
  });

  factory BlueToothState.initial() => const BlueToothState(
    loadingInit: true,
    bluetoothEnabled: false,
    permissionsGranted: false,
    scanning: false,
    devices: [],
    selectedDevice: null,
    connecting: false,
    connected: false,
    statusMessage: "Подготовка Bluetooth...",
    statusIcon: Icons.bluetooth,
    statusColor: Colors.blue,
    navigateToEcg: false,
  );

  BlueToothState copyWith({
    bool? loadingInit,
    bool? bluetoothEnabled,
    bool? permissionsGranted,
    bool? scanning,
    List<BluetoothDevice>? devices,
    BluetoothDevice? selectedDevice,
    bool? connecting,
    bool? connected,
    String? statusMessage,
    IconData? statusIcon,
    Color? statusColor,
    bool? navigateToEcg,
  }) {
    return BlueToothState(
      loadingInit: loadingInit ?? this.loadingInit,
      bluetoothEnabled:
          bluetoothEnabled ?? this.bluetoothEnabled,
      permissionsGranted:
          permissionsGranted ?? this.permissionsGranted,
      scanning: scanning ?? this.scanning,
      devices: devices ?? this.devices,
      selectedDevice: selectedDevice ?? this.selectedDevice,
      connecting: connecting ?? this.connecting,
      connected: connected ?? this.connected,
      statusMessage: statusMessage ?? this.statusMessage,
      statusIcon: statusIcon ?? this.statusIcon,
      statusColor: statusColor ?? this.statusColor,
      navigateToEcg: navigateToEcg ?? this.navigateToEcg,
    );
  }

  @override
  List<Object?> get props => [
    loadingInit,
    bluetoothEnabled,
    permissionsGranted,
    scanning,
    devices.map((e) => e.remoteId).toList(),
    selectedDevice?.remoteId,
    connecting,
    connected,
    statusMessage,
    statusIcon,
    statusColor,
    navigateToEcg,
  ];
}
