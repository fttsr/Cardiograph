import 'package:ca_frontend/src/features/results/domain/entities/result_file.dart';
import 'package:equatable/equatable.dart';

class ResultsState extends Equatable {
  const ResultsState({
    required this.loading,
    required this.files,
    this.error,
  });

  final bool loading;
  final List<ResultFile> files;
  final String? error;

  factory ResultsState.initial() =>
      const ResultsState(loading: true, files: []);

  ResultsState copyWith({
    bool? loading,
    List<ResultFile>? files,
    String? error,
    bool clearError = false,
  }) {
    return ResultsState(
      loading: loading ?? this.loading,
      files: files ?? this.files,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [loading, files, error];
}
