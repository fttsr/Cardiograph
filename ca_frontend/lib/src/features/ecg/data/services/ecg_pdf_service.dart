import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class EcgPdfService {
  static const double _gridStep = 20.0;
  static const double _sampleSpacing = 2.2;
  static const int _monitorSampleRate = 120;

  Future<Uint8List> buildPdf({
    required List<double> samples,
    required int sampleRate,
    required int? heartRate,
    List<int>? heartRateHistory,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = _formatDate(now);
    final timeStr = _formatTime(now);

    final history = heartRateHistory ?? const <int>[];

    final List<List<double>> graphChunks = history.isNotEmpty
        ? _buildMonitorChunksFromHeartRateHistory(history)
        : <List<double>>[_buildFallbackMonitorChunk(heartRate)];

    final imageWidgets = <pw.Widget>[];

    for (int i = 0; i < graphChunks.length; i++) {
      final bytes = await _renderMonitorImagePart(
        graphChunks[i],
        title: 'ECG Segment ${i + 1}',
      );

      if (bytes.isEmpty) continue;

      imageWidgets.add(
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'ECG Segment ${i + 1}',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Image(
              pw.MemoryImage(bytes),
              width: 500,
              height: 170,
              fit: pw.BoxFit.fitWidth,
            ),
            pw.SizedBox(height: 16),
          ],
        ),
      );
    }

    final rows = <pw.TableRow>[
      pw.TableRow(
        children: [
          _tableCell('Second', isHeader: true),
          _tableCell('Heart Rate', isHeader: true),
        ],
      ),
    ];

    for (int i = 0; i < history.length; i++) {
      rows.add(
        pw.TableRow(
          children: [
            _tableCell('${i + 1}'),
            _tableCell('${history[i]}'),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (_) => [
          pw.Text(
            'ECG Results — $dateStr at $timeStr',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Sample rate: $sampleRate Hz'),
          pw.Text(
            'Final heart rate: ${heartRate?.toString() ?? '--'} bpm',
          ),
          pw.SizedBox(height: 24),
          if (history.isNotEmpty) ...[
            pw.Text(
              'Heart Rate Table:',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(1),
              },
              children: rows,
            ),
            pw.SizedBox(height: 20),
          ],
          pw.Text(
            'ECG Graph:',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          if (imageWidgets.isEmpty)
            pw.Text('No ECG samples recorded')
          else
            ...imageWidgets,
        ],
      ),
    );

    return pdf.save();
  }

  Future<String> savePdfToFile({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final Directory? directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    if (directory == null) {
      throw Exception(
        'Не удалось получить директорию для сохранения PDF',
      );
    }

    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<void> sharePdf({
    required Uint8List bytes,
    required String fileName,
  }) {
    return Printing.sharePdf(bytes: bytes, filename: fileName);
  }

  String makeFileName([DateTime? now]) {
    final dt = now ?? DateTime.now();
    return 'ECG_Report_${_formatDate(dt)}-${_formatTime(dt).replaceAll(':', '-')}.pdf';
  }

  List<List<double>> _buildMonitorChunksFromHeartRateHistory(
    List<int> history,
  ) {
    final List<double> full = <double>[];

    for (final bpm in history) {
      full.addAll(_buildOneSecondWave(bpm));
    }

    final int chunkSize = 6 * _monitorSampleRate;
    final chunks = <List<double>>[];

    for (int i = 0; i < full.length; i += chunkSize) {
      chunks.add(
        full.sublist(i, math.min(i + chunkSize, full.length)),
      );
    }

    return chunks;
  }

  List<double> _buildFallbackMonitorChunk(int? heartRate) {
    final int seconds = 6;
    final List<double> result = <double>[];

    for (int i = 0; i < seconds; i++) {
      result.addAll(_buildOneSecondWave(heartRate));
    }

    return result;
  }

  List<double> _buildOneSecondWave(int? bpm) {
    final List<double> result = <double>[];

    final bool hasValidSignal = _hasValidHeartRate(bpm);
    final int sampleCount = _monitorSampleRate;

    if (!hasValidSignal) {
      for (int i = 0; i < sampleCount; i++) {
        result.add(0.0);
      }
      return result;
    }

    final double clampedBpm = bpm!.clamp(45, 160).toDouble();
    final double beatPeriodSec = 60.0 / clampedBpm;

    for (int i = 0; i < sampleCount; i++) {
      final double t = i / _monitorSampleRate;
      final double phase = (t % beatPeriodSec) / beatPeriodSec;
      result.add(_monitorWave(phase));
    }

    return result;
  }

  bool _hasValidHeartRate(int? bpm) {
    if (bpm == null) return false;
    if (bpm <= 0) return false;
    if (bpm > 220) return false;
    return true;
  }

  double _monitorWave(double phase) {
    if (phase < 0.08) {
      return 0.0;
    }
    if (phase < 0.12) {
      return _lerp(0.0, 0.10, (phase - 0.08) / 0.04);
    }
    if (phase < 0.16) {
      return _lerp(0.10, 0.0, (phase - 0.12) / 0.04);
    }
    if (phase < 0.22) {
      return 0.0;
    }
    if (phase < 0.245) {
      return _lerp(0.0, -0.18, (phase - 0.22) / 0.025);
    }
    if (phase < 0.275) {
      return _lerp(-0.18, 1.15, (phase - 0.245) / 0.03);
    }
    if (phase < 0.315) {
      return _lerp(1.15, -0.32, (phase - 0.275) / 0.04);
    }
    if (phase < 0.35) {
      return _lerp(-0.32, 0.0, (phase - 0.315) / 0.035);
    }
    if (phase < 0.48) {
      return _lerp(0.0, 0.28, (phase - 0.35) / 0.13);
    }
    if (phase < 0.62) {
      return _lerp(0.28, 0.0, (phase - 0.48) / 0.14);
    }

    return 0.0;
  }

  double _lerp(double a, double b, double t) {
    final clamped = t.clamp(0.0, 1.0);
    return a + (b - a) * clamped;
  }

  Future<Uint8List> _renderMonitorImagePart(
    List<double> dataPart, {
    required String title,
  }) async {
    try {
      if (dataPart.isEmpty) return Uint8List(0);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final double width = math.max(
        dataPart.length * _sampleSpacing,
        640.0,
      );
      const double height = 220.0;

      _EcgPdfPainter(
        data: dataPart,
        gridStep: _gridStep,
        sampleSpacing: _sampleSpacing,
        color: Colors.blue,
      ).paint(canvas, Size(width, height));

      final picture = recorder.endRecording();
      final image = await picture.toImage(
        width.toInt(),
        height.toInt(),
      );
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return byteData?.buffer.asUint8List() ?? Uint8List(0);
    } catch (_) {
      return Uint8List(0);
    }
  }

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day.$month.${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: isHeader
            ? pw.TextStyle(fontWeight: pw.FontWeight.bold)
            : null,
      ),
    );
  }
}

class _EcgPdfPainter extends CustomPainter {
  _EcgPdfPainter({
    required this.data,
    required this.gridStep,
    required this.sampleSpacing,
    required this.color,
  });

  final List<double> data;
  final double gridStep;
  final double sampleSpacing;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final backgroundPaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    final minorGridPaint = Paint()
      ..color = const Color(0xFFFFCDD2)
      ..strokeWidth = 0.5;

    final majorGridPaint = Paint()
      ..color = const Color(0xFFE57373)
      ..strokeWidth = 1.0;

    final double centerY = size.height / 2;

    for (double x = 0; x <= size.width; x += gridStep) {
      final bool isMajor = ((x / gridStep).round() % 5) == 0;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        isMajor ? majorGridPaint : minorGridPaint,
      );
    }

    int upIndex = 0;
    for (double y = centerY; y >= 0; y -= gridStep) {
      final bool isMajor = upIndex % 5 == 0;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        isMajor ? majorGridPaint : minorGridPaint,
      );
      upIndex++;
    }

    int downIndex = 1;
    for (
      double y = centerY + gridStep;
      y <= size.height;
      y += gridStep
    ) {
      final bool isMajor = downIndex % 5 == 0;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        isMajor ? majorGridPaint : minorGridPaint,
      );
      downIndex++;
    }

    final ecgPaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final path = Path();
    final double amplitudeScale = gridStep * 1.9;

    double x = 0.0;
    double y = centerY - (data.first * amplitudeScale);
    y = y.clamp(0.0, size.height);
    path.moveTo(x, y);

    for (int i = 1; i < data.length; i++) {
      x += sampleSpacing;
      if (x > size.width) break;

      double nextY = centerY - (data[i] * amplitudeScale);
      nextY = nextY.clamp(0.0, size.height);
      path.lineTo(x, nextY);
    }

    canvas.drawPath(path, ecgPaint);
  }

  @override
  bool shouldRepaint(covariant _EcgPdfPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.gridStep != gridStep ||
        oldDelegate.sampleSpacing != sampleSpacing ||
        oldDelegate.color != color;
  }
}
