import 'package:ca_frontend/src/features/results/domain/entities/result_file.dart';
import 'package:equatable/equatable.dart';

sealed class ResultsEvent extends Equatable {
  const ResultsEvent();

  @override
  List<Object?> get props => [];
}

class ResultsStarted extends ResultsEvent {
  const ResultsStarted();
}

class ResultsFilesChanged extends ResultsEvent {
  const ResultsFilesChanged(this.files);

  final List<ResultFile> files;

  @override
  List<Object?> get props => [files];
}

class ResultsOpenTracked extends ResultsEvent {
  const ResultsOpenTracked();
}
