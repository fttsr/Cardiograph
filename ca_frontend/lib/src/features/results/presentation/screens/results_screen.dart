import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';

import '../../../../core/di/di.dart';
import '../../domain/entities/result_file.dart';
import '../bloc/results_bloc.dart';
import '../bloc/results_event.dart';
import '../bloc/results_state.dart';
import 'result_pdf_preview_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<ResultsBloc>()..add(const ResultsStarted()),
      child: BlocBuilder<ResultsBloc, ResultsState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Результаты ЭКГ'),
              centerTitle: true,
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ResultsState state) {
    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.files.isEmpty) {
      return Center(child: Text(state.error!));
    }

    if (state.files.isEmpty) {
      return const Center(
        child: Text('Нет сохранённых результатов'),
      );
    }

    return ListView.separated(
      itemCount: state.files.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final file = state.files[index];
        return ListTile(
          title: Text(file.name),
          subtitle: Text(
            file.path,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => _openPdf(context, file),
          trailing: IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _openPdf(context, file),
          ),
        );
      },
    );
  }

  Future<void> _openPdf(
    BuildContext context,
    ResultFile file,
  ) async {
    final ioFile = File(file.path);

    if (!await ioFile.exists()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Файл не найден. Список результатов обновлён.',
            ),
          ),
        );
        context.read<ResultsBloc>().add(const ResultsStarted());
      }
      return;
    }

    context.read<ResultsBloc>().add(const ResultsOpenTracked());

    if (Platform.isIOS) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultPdfPreviewScreen(
            path: file.path,
            name: file.name,
          ),
        ),
      );
      return;
    }

    final res = await OpenFile.open(file.path);
    if (res.type != ResultType.done && context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultPdfPreviewScreen(
            path: file.path,
            name: file.name,
          ),
        ),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Не удалось открыть внешним приложением: ${res.message}',
            ),
          ),
        );
      }
    }
  }
}
