import 'package:equatable/equatable.dart';

class EcgSessionState extends Equatable {
  final bool connected;
  final bool isRecording;
  final bool isSaving;

  final int remainingSeconds;
  final int? heartRate;

  final String deviceName;

  final List<double> ecgDraw;

  const EcgSessionState({
    required this.connected,
    required this.isRecording,
    required this.isSaving,
    required this.remainingSeconds,
    required this.heartRate,
    required this.deviceName,
    required this.ecgDraw,
  });

  factory EcgSessionState.initial({
    required String deviceName,
  }) => EcgSessionState(
    connected: true,
    isRecording: true,
    isSaving: false,
    remainingSeconds: 60,
    heartRate: null,
    deviceName: deviceName,
    ecgDraw: const [],
  );

  EcgSessionState copyWith({
    bool? connected,
    bool? isRecording,
    bool? isSaving,
    int? remainingSeconds,
    int? heartRate,
    String? deviceName,
    List<double>? ecgDraw,
  }) {
    return EcgSessionState(
      connected: connected ?? this.connected,
      isRecording: isRecording ?? this.isRecording,
      isSaving: isSaving ?? this.isSaving,
      remainingSeconds:
          remainingSeconds ?? this.remainingSeconds,
      heartRate: heartRate ?? this.heartRate,
      deviceName: deviceName ?? this.deviceName,
      ecgDraw: ecgDraw ?? this.ecgDraw,
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
  ];
}
