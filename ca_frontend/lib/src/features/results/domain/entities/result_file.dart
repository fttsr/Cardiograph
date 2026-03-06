import 'package:equatable/equatable.dart';

class ResultFile extends Equatable {
  final String path;
  final String name;

  const ResultFile({required this.path, required this.name});

  @override
  List<Object?> get props => [path, name];
}
