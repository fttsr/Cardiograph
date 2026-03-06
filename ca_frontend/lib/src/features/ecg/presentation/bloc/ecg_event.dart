import 'package:ca_frontend/src/features/ecg/domain/entities/ecg_session_state.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

sealed class EcgEvent extends Equatable {
  const EcgEvent();
  @override
  List<Object?> get props => [];
}

class EcgStarted extends EcgEvent {
  final BluetoothDevice device;
  const EcgStarted(this.device);

  @override
  List<Object?> get props => [device.remoteId];
}

class EcgToggleRecordingPressed extends EcgEvent {
  const EcgToggleRecordingPressed();
}

class EcgSavePressed extends EcgEvent {
  const EcgSavePressed();
}

class EcgAbortPressed extends EcgEvent {
  const EcgAbortPressed();
}

class EcgSessionUpdated extends EcgEvent {
  final EcgSessionState sessionState;
  const EcgSessionUpdated(this.sessionState);

  @override
  List<Object?> get props => [sessionState];
}
