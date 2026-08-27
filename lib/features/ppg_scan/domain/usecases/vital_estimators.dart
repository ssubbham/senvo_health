import 'dart:math' as math;

import '../entities/ppg_entities.dart';
import '../../../../services/signal_processing/signal_processing.dart';

abstract class VitalEstimator {
  VitalsResult estimate(List<PPGSample> samples, SignalAnalysis analysis);
}

abstract class SpO2Estimator {
  double estimate({required List<PPGSample> samples, required double samplingRate});
}

abstract class BloodPressureEstimator {
  BloodPressure estimate({required List<PPGSample> samples, required double heartRate});
}

class ExperimentalSpO2Estimator implements SpO2Estimator {
  @override
  double estimate({required List<PPGSample> samples, required double samplingRate}) {
    if (samples.isEmpty) throw StateError('No samples available for SpO2 estimation.');
    final red = samples.map((sample) => sample.red).toList();
    final blue = samples.map((sample) => sample.blue).toList();
    final redDc = red.reduce((a, b) => a + b) / red.length;
    final blueDc = blue.reduce((a, b) => a + b) / blue.length;
    final redAc = red.reduce(math.max) - red.reduce(math.min);
    final blueAc = blue.reduce(math.max) - blue.reduce(math.min);
    if (redDc <= 0 || blueDc <= 0 || blueAc <= 0) throw StateError('SpO2 ratio is undefined.');
    final ratio = (redAc / redDc) / (blueAc / blueDc);
    return (110 - 25 * ratio).clamp(70, 100).toDouble();
  }
}

class ExperimentalBloodPressureEstimator implements BloodPressureEstimator {
  @override
  BloodPressure estimate({required List<PPGSample> samples, required double heartRate}) => BloodPressure(
        systolic: 110 + heartRate / 10,
        diastolic: 70 + heartRate / 15,
      );
}

class CameraPpgVitalEstimator implements VitalEstimator {
  CameraPpgVitalEstimator({SpO2Estimator? spo2, BloodPressureEstimator? bloodPressure})
      : _spo2 = spo2 ?? ExperimentalSpO2Estimator(),
        _bloodPressure = bloodPressure ?? ExperimentalBloodPressureEstimator();

  final SpO2Estimator _spo2;
  final BloodPressureEstimator _bloodPressure;

  @override
  VitalsResult estimate(List<PPGSample> samples, SignalAnalysis analysis) {
    final heartRate = HeartRateEstimator().estimate(analysis.filtered, analysis.samplingRate);
    if (heartRate == null) throw StateError('No physiological heart-rate peak found.');
    return VitalsResult(
      heartRateBpm: heartRate,
      spo2Percent: _spo2.estimate(samples: samples, samplingRate: analysis.samplingRate),
      bloodPressure: _bloodPressure.estimate(samples: samples, heartRate: heartRate),
      signalQuality: analysis.sqi,
      timestamp: DateTime.now(),
    );
  }
}

class HeartRateEstimator {
  double? estimate(List<double> signal, double samplingRate) {
    if (signal.isEmpty || samplingRate <= 0) return null;
    final estimate = PPGWaveAnalyzer(sampleRate: samplingRate).analyze(signal);
    if (!estimate.isValid) return null;
    return estimate.heartRateBpm;
  }
}