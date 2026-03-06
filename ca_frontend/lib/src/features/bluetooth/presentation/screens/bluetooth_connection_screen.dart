import 'package:ca_frontend/src/features/ecg/presentation/screens/ecg_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/di/di.dart';
import '../bloc/bluetooth_bloc.dart';
import '../bloc/bluetooth_event.dart';
import '../bloc/bluetooth_state.dart';

class BluetoothConnectionScreen extends StatelessWidget {
  const BluetoothConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<BluetoothBloc>()
            ..add(const BluetoothInitRequested()),
      child: BlocConsumer<BluetoothBloc, BlueToothState>(
        listenWhen: (p, c) => p.navigateToEcg != c.navigateToEcg,
        listener: (context, state) {
          if (state.navigateToEcg &&
              state.selectedDevice != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    EcgScreen(device: state.selectedDevice!),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Подключение к кардиографу",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: state.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          state.statusIcon,
                          size: 50,
                          color: state.statusColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.statusMessage,
                          style: TextStyle(
                            fontSize: 18,
                            color: state.statusColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (state.connected)
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 3.0, end: 0.0),
                            duration: const Duration(seconds: 3),
                            builder: (context, value, _) {
                              return Text(
                                "Запуск через ${value.toInt()} сек...",
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(child: _deviceList(context, state)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _deviceList(
    BuildContext context,
    BlueToothState state,
  ) {
    final bloc = context.read<BluetoothBloc>();

    if (state.devices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Text(
                state.scanning
                    ? "Поиск кардиографа..."
                    : "Устройства не найдены",
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              if (!state.bluetoothEnabled)
                ElevatedButton.icon(
                  icon: const Icon(Icons.bluetooth),
                  label: const Text("Включить Bluetooth"),
                  onPressed: () => openAppSettings(),
                ),
              if (!state.permissionsGranted)
                ElevatedButton.icon(
                  icon: const Icon(Icons.settings),
                  label: const Text("Запросить разрешения"),
                  onPressed: () => bloc.add(
                    const BluetoothRequestPermissionsPressed(),
                  ),
                ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Повторить сканирование"),
                onPressed: () =>
                    bloc.add(const BluetoothStartScanPressed()),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: state.devices.length,
      itemBuilder: (context, index) {
        final device = state.devices[index];

        final isConnecting =
            state.selectedDevice?.remoteId == device.remoteId &&
            state.connecting;
        final isConnected =
            state.selectedDevice?.remoteId == device.remoteId &&
            state.connected;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.heart_broken),
            title: Text(
              device.platformName.isNotEmpty
                  ? device.platformName
                  : "Неизвестное устройство",
            ),
            subtitle: Text(
              isConnected
                  ? "Подключено"
                  : isConnecting
                  ? "Подключение..."
                  : "Нажмите для подключения",
              style: TextStyle(
                color: isConnected
                    ? Colors.green
                    : isConnecting
                    ? Colors.orange
                    : Colors.grey,
              ),
            ),
            trailing: isConnected
                ? const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  )
                : isConnecting
                ? const CircularProgressIndicator()
                : null,
            onTap: (isConnected || isConnecting)
                ? null
                : () => context.read<BluetoothBloc>().add(
                    BluetoothConnectRequested(device),
                  ),
          ),
        );
      },
    );
  }
}
