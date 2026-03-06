import 'dart:math';

class HrEstimator {
  HrEstimator({required this.fs});

  final int fs;

  double _prev = 0.0;
  double _prev2 = 0.0;

  late final int _mwiWindow = max(1, (0.150 * fs).round());
  late final List<double> _mwiBuf = List.filled(_mwiWindow, 0.0);
  int _mwiIdx = 0;
  double _mwiSum = 0.0;

  double _signalLevel = 0.0;
  double _noiseLevel = 0.0;

  late final int _refractory = max(1, (0.250 * fs).round());

  int _sampleIndex = 0;
  int _lastR = -1;

  final List<int> _rrIntervals = [];
  static const int _rrMax = 8;

  int? update(double x) {
    _sampleIndex++;

    final d = x - _prev2;
    _prev2 = _prev;
    _prev = x;

    final sq = d * d;

    _mwiSum -= _mwiBuf[_mwiIdx];
    _mwiBuf[_mwiIdx] = sq;
    _mwiSum += sq;
    _mwiIdx = (_mwiIdx + 1) % _mwiWindow;
    final mwi = _mwiSum / _mwiWindow;

    final threshold =
        _noiseLevel + 0.25 * (_signalLevel - _noiseLevel);

    if (mwi > threshold) {
      if (_lastR < 0 || (_sampleIndex - _lastR) >= _refractory) {
        final prevR = _lastR;
        _lastR = _sampleIndex;

        _signalLevel = 0.125 * mwi + 0.875 * _signalLevel;

        if (prevR > 0) {
          final rr = _lastR - prevR;
          final bpm = (60.0 * fs / rr).round();

          if (bpm >= 35 && bpm <= 220) {
            _rrIntervals.add(rr);
            if (_rrIntervals.length > _rrMax) {
              _rrIntervals.removeAt(0);
            }
            final sorted = List<int>.from(_rrIntervals)..sort();
            final rrMed = sorted[sorted.length ~/ 2];
            return (60.0 * fs / rrMed).round();
          }
        }
        return null;
      } else {
        _noiseLevel = 0.125 * mwi + 0.875 * _noiseLevel;
      }
    } else {
      _noiseLevel = 0.125 * mwi + 0.875 * _noiseLevel;
    }

    return null;
  }

  void reset() {
    _prev = 0;
    _prev2 = 0;
    _mwiIdx = 0;
    _mwiSum = 0;
    for (var i = 0; i < _mwiBuf.length; i++) _mwiBuf[i] = 0;
    _signalLevel = 0;
    _noiseLevel = 0;
    _sampleIndex = 0;
    _lastR = -1;
    _rrIntervals.clear();
  }
}
