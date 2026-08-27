import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:senvo_flutter/features/ppg_scan/domain/entities/ppg_entities.dart';
import 'package:senvo_flutter/features/ppg_scan/domain/usecases/vital_estimators.dart';
import 'package:senvo_flutter/features/ppg_scan/presentation/widgets/scan_widgets.dart';
import 'package:senvo_flutter/services/signal_processing/signal_processing.dart';

void main() {
  test('estimates sampling rate from timestamps', () {
    final samples = List.generate(301, (index) => index / 30.0);
    expect(SignalProcessor().estimateSamplingRate(samples), closeTo(30, 0.001));
  });

  test('estimates a synthetic 1.2 Hz heart rate', () {
    const rate = 30.0;
    final signal = List.generate(300, (index) => math.sin(2 * math.pi * 1.2 * index / rate));
    expect(HeartRateEstimator().estimate(signal, rate), closeTo(72, 4));
  });

  test('flat signal has zero SQI', () {
    final sqi = SignalProcessor().calculateSqi(List<double>.filled(300, 0), 30);
    expect(sqi, 0);
  });

  test('sample channel values remain available independently', () {
    const sample = PPGSample(timestamp: 1, red: 10, green: 20, blue: 30);
    expect(sample.channel(PPGChannel.red), 10);
    expect(sample.channel(PPGChannel.green), 20);
    expect(sample.channel(PPGChannel.blue), 30);
  });

  test('frequency-domain analyzer resolves noisy PPG waveform to realistic heart rate', () {
    const sampleRate = 30.0;
    final signal = List<double>.generate(360, (index) {
      final time = index / sampleRate;
      final drift = 0.18 * math.sin(2 * math.pi * 0.18 * time);
      final pulse = 0.75 * math.sin(2 * math.pi * 1.25 * time);
      final noise = 0.12 * math.sin(2 * math.pi * 7.4 * time);
      return drift + pulse + noise;
    });

    final estimate = PPGWaveAnalyzer(sampleRate: sampleRate).analyze(signal);

    expect(estimate.isValid, isTrue);
    expect(estimate.heartRateBpm, closeTo(75, 10));
    expect(estimate.signalQuality, greaterThan(0.2));
  });

  test('camera preview is not rendered for a null or disposed controller', () {
    expect(CameraPreviewWidget.canRenderPreview(null), isFalse);
  });
}