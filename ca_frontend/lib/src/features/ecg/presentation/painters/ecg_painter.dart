import 'package:flutter/material.dart';

class EcgGridPainter extends CustomPainter {
  const EcgGridPainter({
    required this.step,
    required this.sampleSpacing,
    required this.sampleCount,
  });

  final double step;
  final double sampleSpacing;
  final int sampleCount;

  static final Paint _minorGridPaint = Paint()
    ..color = const Color(0xFFFFCDD2)
    ..strokeWidth = 0.5;

  static final Paint _majorGridPaint = Paint()
    ..color = const Color(0xFFE57373)
    ..strokeWidth = 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    final double centerY = size.height / 2;
    final double scrollOffset =
        (sampleCount * sampleSpacing) % step;

    for (
      double x = -scrollOffset;
      x <= size.width + step;
      x += step
    ) {
      final int lineIndex = ((x + scrollOffset) / step).round();
      final bool isMajor = lineIndex % 5 == 0;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        isMajor ? _majorGridPaint : _minorGridPaint,
      );
    }

    int upIndex = 0;
    for (double y = centerY; y >= 0; y -= step) {
      final bool isMajor = upIndex % 5 == 0;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        isMajor ? _majorGridPaint : _minorGridPaint,
      );
      upIndex++;
    }

    int downIndex = 1;
    for (
      double y = centerY + step;
      y <= size.height;
      y += step
    ) {
      final bool isMajor = downIndex % 5 == 0;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        isMajor ? _majorGridPaint : _minorGridPaint,
      );
      downIndex++;
    }
  }

  @override
  bool shouldRepaint(covariant EcgGridPainter oldDelegate) {
    return oldDelegate.step != step ||
        oldDelegate.sampleSpacing != sampleSpacing ||
        oldDelegate.sampleCount != sampleCount;
  }
}

class EcgSignalPainter extends CustomPainter {
  EcgSignalPainter({
    required this.dataPoints,
    required this.gridStep,
    required this.sampleSpacing,
    required this.isRecording,
  });

  final List<double> dataPoints;
  final double gridStep;
  final double sampleSpacing;
  final bool isRecording;

  static final Paint _signalPaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  static final Paint _pausedSignalPaint = Paint()
    ..color = Colors.blue.withOpacity(0.65)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.length < 2) return;

    final Paint paint = isRecording
        ? _signalPaint
        : _pausedSignalPaint;
    final Path path = Path();
    final double centerY = size.height / 2;

    final double amplitudeScale = gridStep * 1.9;

    final int visibleCount =
        (size.width / sampleSpacing).ceil() + 2;
    final int startIndex = dataPoints.length > visibleCount
        ? dataPoints.length - visibleCount
        : 0;

    double x =
        size.width -
        ((dataPoints.length - 1 - startIndex) * sampleSpacing);
    double y =
        centerY - (dataPoints[startIndex] * amplitudeScale);
    y = y.clamp(0.0, size.height);

    path.moveTo(x, y);

    for (int i = startIndex + 1; i < dataPoints.length; i++) {
      x += sampleSpacing;

      if (x < 0) continue;
      if (x > size.width) break;

      double nextY = centerY - (dataPoints[i] * amplitudeScale);
      nextY = nextY.clamp(0.0, size.height);
      path.lineTo(x, nextY);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant EcgSignalPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.gridStep != gridStep ||
        oldDelegate.sampleSpacing != sampleSpacing ||
        oldDelegate.isRecording != isRecording;
  }
}
