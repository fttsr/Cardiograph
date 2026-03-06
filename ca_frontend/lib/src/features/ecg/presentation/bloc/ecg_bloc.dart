import 'dart:async';

import 'package:ca_frontend/src/features/ecg/domain/entities/ecg_session_state.dart';
import 'package:ca_frontend/src/features/ecg/domain/repositories/ecg_repository.dart';
import 'package:ca_frontend/src/features/ecg/presentation/bloc/ecg_event.dart';
import 'package:ca_frontend/src/features/ecg/presentation/bloc/ecg_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EcgBloc extends Bloc<EcgEvent, EcgBlocState> {
  EcgBloc({required this.repo}) : super(EcgBlocState.initial()) {
    on<EcgStarted>(_onStarted);
    on<EcgToggleRecordingPressed>(_onToggleRecordingPressed);
    on<EcgSavePressed>(_onSave);
    on<EcgAbortPressed>(_onAbort);
    on<EcgSessionUpdated>(_onUpdated);
  }

  final EcgRepository repo;

  StreamSubscription<EcgSessionState>? _sub;
  Timer? _throttle;
  EcgSessionState? _latest;

  Future<void> _onStarted(
    EcgStarted e,
    Emitter<EcgBlocState> emit,
  ) async {
    try {
      await repo.start(e.device);

      await _sub?.cancel();
      _sub = repo.watch().listen((s) {
        _latest = s;
        _throttle ??= Timer(
          const Duration(milliseconds: 50),
          () {
            _throttle = null;
            final v = _latest;
            if (v != null) add(EcgSessionUpdated(v));
          },
        );
      });

      emit(
        state.copyWith(
          flowStatus: EcgFlowStatus.active,
          clearMessage: true,
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(
          flowStatus: EcgFlowStatus.failure,
          message: err.toString(),
        ),
      );
    }
  }

  void _onToggleRecordingPressed(
    EcgToggleRecordingPressed e,
    Emitter<EcgBlocState> emit,
  ) {
    repo.toggleRecording();
  }

  void _onUpdated(
    EcgSessionUpdated e,
    Emitter<EcgBlocState> emit,
  ) {
    final s = e.sessionState;
    emit(
      state.copyWith(
        connected: s.connected,
        isRecording: s.isRecording,
        isSaving: s.isSaving,
        remainingSeconds: s.remainingSeconds,
        heartRate: s.heartRate,
        deviceName: s.deviceName,
        ecgDraw: s.ecgDraw,
        flowStatus: state.flowStatus == EcgFlowStatus.idle
            ? EcgFlowStatus.active
            : state.flowStatus,
      ),
    );
  }

  Future<void> _onSave(
    EcgSavePressed e,
    Emitter<EcgBlocState> emit,
  ) async {
    try {
      emit(state.copyWith(isSaving: true, clearMessage: true));
      await repo.saveAndFinish();
      emit(
        state.copyWith(
          isSaving: false,
          isRecording: false,
          flowStatus: EcgFlowStatus.saved,
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(
          isSaving: false,
          flowStatus: EcgFlowStatus.failure,
          message: err.toString(),
        ),
      );
    }
  }

  Future<void> _onAbort(
    EcgAbortPressed e,
    Emitter<EcgBlocState> emit,
  ) async {
    try {
      await repo.abort();
      emit(
        state.copyWith(
          isRecording: false,
          isSaving: false,
          flowStatus: EcgFlowStatus.aborted,
          clearMessage: true,
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(
          flowStatus: EcgFlowStatus.failure,
          message: err.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    _throttle?.cancel();
    await _sub?.cancel();
    await repo.dispose();
    return super.close();
  }
}
