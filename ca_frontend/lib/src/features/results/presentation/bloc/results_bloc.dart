import 'dart:async';

import 'package:ca_frontend/src/features/results/domain/repositories/results_repository.dart';
import 'package:ca_frontend/src/features/results/presentation/bloc/results_event.dart';
import 'package:ca_frontend/src/features/results/presentation/bloc/results_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResultsBloc extends Bloc<ResultsEvent, ResultsState> {
  ResultsBloc({required this.repository})
    : super(ResultsState.initial()) {
    on<ResultsStarted>(_onStarted);
    on<ResultsFilesChanged>(_onFilesChanged);
    on<ResultsOpenTracked>(_onOpenTracked);
  }

  final ResultsRepository repository;
  StreamSubscription? _subscription;

  Future<void> _onStarted(
    ResultsStarted event,
    Emitter<ResultsState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));

    try {
      final files = await repository.getResults();
      emit(
        state.copyWith(
          loading: false,
          files: files,
          clearError: true,
        ),
      );

      await _subscription?.cancel();
      _subscription = repository.watchResults().listen(
        (files) => add(ResultsFilesChanged(files)),
        onError: (error) => emit(
          state.copyWith(
            loading: false,
            error: error.toString(),
          ),
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(loading: false, error: err.toString()),
      );
    }
  }

  void _onFilesChanged(
    ResultsFilesChanged event,
    Emitter<ResultsState> emit,
  ) {
    emit(
      state.copyWith(
        loading: false,
        files: event.files,
        clearError: true,
      ),
    );
  }

  Future<void> _onOpenTracked(
    ResultsOpenTracked event,
    Emitter<ResultsState> emit,
  ) async {
    try {
      await repository.markPdfOpened();
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
