import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class EcgBleDataSource {
  EcgBleDataSource({this.serviceUuid, this.characteristicUuid});

  final Guid? serviceUuid;
  final Guid? characteristicUuid;

  Stream<List<double>> samplesStream(
    BluetoothDevice device,
  ) async* {
    final services = await device.discoverServices();
    final ch = _findCharacteristic(services);

    if (ch == null) {
      throw Exception(
        'Не найдена UART notify характеристика для ЭКГ',
      );
    }

    try {
      await ch.read();
    } catch (_) {}

    await ch.setNotifyValue(true);

    var buffer = '';
    final batch = <double>[];
    const maxBatch = 50;

    await for (final raw in ch.onValueReceived) {
      if (raw.isEmpty) continue;

      final bytes = Uint8List.fromList(raw);
      buffer += String.fromCharCodes(bytes);

      int nl;
      while ((nl = buffer.indexOf('\n')) != -1) {
        final line = buffer.substring(0, nl).trim();
        buffer = buffer.substring(nl + 1);

        if (line.isEmpty || line == '!') continue;

        final v = int.tryParse(line);
        if (v == null) continue;
        if (v < 0 || v > 4096) continue;

        batch.add(v.toDouble());
        if (batch.length >= maxBatch) {
          yield List<double>.from(batch);
          batch.clear();
        }
      }

      if (batch.isNotEmpty) {
        yield List<double>.from(batch);
        batch.clear();
      }
    }
  }

  BluetoothCharacteristic? _findCharacteristic(
    List<BluetoothService> services,
  ) {
    if (serviceUuid != null && characteristicUuid != null) {
      for (final s in services) {
        if (s.uuid == serviceUuid) {
          for (final c in s.characteristics) {
            if (c.uuid == characteristicUuid) return c;
          }
        }
      }
    }

    BluetoothCharacteristic? uart;
    for (final s in services) {
      final su = s.uuid.toString().toLowerCase();
      if (su.contains('ffe0')) {
        for (final c in s.characteristics) {
          final cu = c.uuid.toString().toLowerCase();
          if (cu.endsWith('ffe1') &&
              (c.properties.notify || c.properties.indicate)) {
            uart = c;
            break;
          }
        }
      }
      if (uart != null) break;
    }
    if (uart != null) return uart;

    for (final s in services) {
      for (final c in s.characteristics) {
        if (c.properties.notify || c.properties.indicate) {
          return c;
        }
      }
    }

    return null;
  }
}
