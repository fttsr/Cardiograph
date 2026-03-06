import 'dart:async';
import 'dart:io';

import 'package:ca_frontend/src/core/storage/app_box.dart';
import 'package:ca_frontend/src/features/results/domain/entities/result_file.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ResultsLocalDataSource {
  ResultsLocalDataSource({
    required this.box,
    required this.appBox,
  }) : _pdfFilesListenable = box.listenable(
         keys: const ['pdfFiles'],
       );

  final Box box;
  final AppBox appBox;
  final ValueListenable<Box> _pdfFilesListenable;

  Future<List<ResultFile>> getResults() async {
    final raw = List<String>.from(
      box.get('pdfFiles', defaultValue: <String>[]),
    );

    final existing = raw
        .where((path) => File(path).existsSync())
        .toList();

    if (!_samePaths(raw, existing)) {
      await appBox.setPdfFiles(existing);
    }

    return existing
        .map(
          (path) => ResultFile(
            path: path,
            name: path.split(Platform.pathSeparator).last,
          ),
        )
        .toList();
  }

  Stream<List<ResultFile>> watchResults() {
    late final StreamController<List<ResultFile>> controller;
    VoidCallback? listener;

    controller = StreamController<List<ResultFile>>.broadcast(
      onListen: () async {
        Future<void> emit() async {
          if (!controller.isClosed) {
            controller.add(await getResults());
          }
        }

        listener = () {
          emit();
        };

        _pdfFilesListenable.addListener(listener!);
        await emit();
      },
      onCancel: () {
        if (listener != null) {
          _pdfFilesListenable.removeListener(listener!);
        }
      },
    );

    return controller.stream;
  }

  Future<void> markPdfOpened() => appBox.setLastPdfOpenTime();

  bool _samePaths(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
