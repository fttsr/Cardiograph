import 'package:ca_frontend/src/features/results/domain/entities/result_file.dart';

abstract class ResultsRepository {
  Future<List<ResultFile>> getResults();
  Stream<List<ResultFile>> watchResults();
  Future<void> markPdfOpened();
}
