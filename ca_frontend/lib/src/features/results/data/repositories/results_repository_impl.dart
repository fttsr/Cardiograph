import '../../domain/entities/result_file.dart';
import '../../domain/repositories/results_repository.dart';
import '../datasources/results_local_data_source.dart';

class ResultsRepositoryImpl implements ResultsRepository {
  ResultsRepositoryImpl(this.local);

  final ResultsLocalDataSource local;

  @override
  Future<List<ResultFile>> getResults() => local.getResults();

  @override
  Stream<List<ResultFile>> watchResults() =>
      local.watchResults();

  @override
  Future<void> markPdfOpened() => local.markPdfOpened();
}
