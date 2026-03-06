import 'package:equatable/equatable.dart';

enum EcgFlowStatus { idle, active, saved, aborted, failure }

class EcgBlocState extends Equatable {
  final bool connected;
  final bool isRecording;
  final bool isSaving;
  final int remainingSeconds;
  final int? heartRate;
  final String deviceName;
  final List<double> ecgDraw;
  final EcgFlowStatus flowStatus;
  final String? message;

  const EcgBlocState({
    required this.connected,
    required this.isRecording,
    required this.isSaving,
    required this.remainingSeconds,
    required this.heartRate,
    required this.deviceName,
    required this.ecgDraw,
    required this.flowStatus,
    required this.message,
  });

  factory EcgBlocState.initial() => const EcgBlocState(
    connected: true,
    isRecording: true,
    isSaving: false,
    remainingSeconds: 60,
    heartRate: null,
    deviceName: '',
    ecgDraw: [],
    flowStatus: EcgFlowStatus.idle,
    message: null,
  );

  EcgBlocState copyWith({
    bool? connected,
    bool? isRecording,
    bool? isSaving,
    int? remainingSeconds,
    int? heartRate,
    String? deviceName,
    List<double>? ecgDraw,
    EcgFlowStatus? flowStatus,
    String? message,
    bool clearMessage = false,
  }) {
    return EcgBlocState(
      connected: connected ?? this.connected,
      isRecording: isRecording ?? this.isRecording,
      isSaving: isSaving ?? this.isSaving,
      remainingSeconds:
          remainingSeconds ?? this.remainingSeconds,
      heartRate: heartRate ?? this.heartRate,
      deviceName: deviceName ?? this.deviceName,
      ecgDraw: ecgDraw ?? this.ecgDraw,
      flowStatus: flowStatus ?? this.flowStatus,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [
    connected,
    isRecording,
    isSaving,
    remainingSeconds,
    heartRate,
    deviceName,
    ecgDraw,
    flowStatus,
    message,
  ];
}
