import 'dart:collection';
import 'dart:math' as math;

import 'package:ca_frontend/src/features/ecg/presentation/painters/ecg_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class EcgGraph extends StatefulWidget {
  const EcgGraph({
    super.key,
    required this.heartRate,
    required this.isRecording,
  });

  final int? heartRate;
  final bool isRecording;

  @override
  State<EcgGraph> createState() => _EcgGraphState();
}

class _EcgGraphState extends State<EcgGraph>
    with SingleTickerProviderStateMixin {
  static const double _gridStep = 20.0;
  static const double _sampleSpacing = 2.2;
  static const int _maxSamples = 900;
  static const double _defaultBpm = 75.0;

  final ListQueue<double> _buffer = ListQueue<double>(
    _maxSamples,
  );

  late final Ticker _ticker;

  Duration? _lastElapsed;
  double _phase = 0.0;
  double _smoothedBpm = _defaultBpm;
  int _sampleCounter = 0;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < _maxSamples; i++) {
      _buffer.add(0.0);
    }

    _ticker = createTicker(_onTick);

    if (widget.isRecording) {
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(covariant EcgGraph oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isRecording != widget.isRecording) {
      if (widget.isRecording) {
        _lastElapsed = null;
        if (!_ticker.isActive) {
          _ticker.start();
        }
      } else {
        _ticker.stop();
      }
    }
  }

  void _onTick(Duration elapsed) {
    if (!mounted || !widget.isRecording) return;

    final Duration? last = _lastElapsed;
    _lastElapsed = elapsed;

    if (last == null) {
      return;
    }

    final double dt =
        (elapsed - last).inMicroseconds /
        Duration.microsecondsPerSecond;

    if (dt <= 0) return;

    final bool hasValidSignal = _hasValidHeartRate(
      widget.heartRate,
    );

    final int samplesToAdd = math.max(1, (dt * 120.0).round());
    bool changed = false;

    if (!hasValidSignal) {
      // Нет сигнала -> только ровная линия по центру.
      for (int i = 0; i < samplesToAdd; i++) {
        if (_buffer.length >= _maxSamples) {
          _buffer.removeFirst();
        }
        _buffer.add(0.0);
        _sampleCounter++;
        changed = true;
      }

      _phase = 0.0;
    } else {
      final int rawBpm = widget.heartRate!;
      final int clampedBpm = rawBpm.clamp(45, 160);

      _smoothedBpm += (clampedBpm - _smoothedBpm) * 0.08;

      final double beatPeriodSec = 60.0 / _smoothedBpm;

      for (int i = 0; i < samplesToAdd; i++) {
        final double localDt = dt / samplesToAdd;
        _phase += localDt / beatPeriodSec;

        while (_phase >= 1.0) {
          _phase -= 1.0;
        }

        final double y = _monitorWave(_phase);

        if (_buffer.length >= _maxSamples) {
          _buffer.removeFirst();
        }
        _buffer.add(y);
        _sampleCounter++;
        changed = true;
      }
    }

    if (changed) {
      setState(() {});
    }
  }

  bool _hasValidHeartRate(int? bpm) {
    if (bpm == null) return false;
    if (bpm <= 0) return false;
    if (bpm > 220) return false;
    return true;
  }

  // Вряд-ли уместно так это использовать, но только так эта залупа выводится по-человечески
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
    return a + (b - a) * t.clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: EcgGridPainter(
              step: _gridStep,
              sampleSpacing: _sampleSpacing,
              sampleCount: _sampleCounter,
            ),
          ),
          CustomPaint(
            painter: EcgSignalPainter(
              dataPoints: _buffer.toList(growable: false),
              gridStep: _gridStep,
              sampleSpacing: _sampleSpacing,
              isRecording: widget.isRecording,
            ),
          ),
        ],
      ),
    );
  }
}
