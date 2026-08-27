import 'dart:math' as math;

import '../../features/ppg_scan/domain/entities/ppg_entities.dart';

class SignalProcessingConfig {
  const SignalProcessingConfig({
    this.lowCutoffHz = 0.7,
    this.highCutoffHz = 4.0,
    this.targetSamplingRate = 30.0,
    this.filterOrder = 2,
    this.minimumSamples = 90,
    this.sqiThreshold = 0.5,
  });

  final double lowCutoffHz;
  final double highCutoffHz;
  final double targetSamplingRate;
  final int filterOrder;
  final int minimumSamples;
  final double sqiThreshold;
}

class SignalAnalysis {
  const SignalAnalysis({required this.filtered, required this.samplingRate, required this.sqi, required this.quality});

  final List<double> filtered;
  final double samplingRate;
  final double sqi;
  final String quality;

  bool get passesGate => sqi >= 0.5;
}

class ButterworthBandpass {
  ButterworthBandpass(this.config, double samplingRate)
      : _highPass = List.generate(math.max(1, config.filterOrder ~/ 2), (_) => _Biquad.highPass(samplingRate, config.lowCutoffHz)),
        _lowPass = List.generate(math.max(1, config.filterOrder ~/ 2), (_) => _Biquad.lowPass(samplingRate, config.highCutoffHz));

  final SignalProcessingConfig config;
  final List<_Biquad> _highPass;
  final List<_Biquad> _lowPass;

  List<double> filter(List<double> input) {
    var forward = input.toList(growable: false);
    for (final section in _highPass) {
      forward = forward.map(section.process).toList(growable: false);
    }
    for (final section in _lowPass) {
      forward = forward.map(section.process).toList(growable: false);
    }
    final reverse = forward.reversed.toList();
    final reverseFilter = ButterworthBandpass(config, _effectiveRate);
    var backward = reverse;
    for (final section in reverseFilter._highPass) {
      backward = backward.map(section.process).toList(growable: false);
    }
    for (final section in reverseFilter._lowPass) {
      backward = backward.map(section.process).toList(growable: false);
    }
    return backward.reversed.toList(growable: false);
  }

  double get _effectiveRate => _highPass.first.sampleRate;
}

class SignalProcessor {
  SignalProcessor({this.config = const SignalProcessingConfig()});

  final SignalProcessingConfig config;

  SignalAnalysis analyze(List<PPGSample> samples, {PPGChannel channel = PPGChannel.green}) {
    if (samples.length < config.minimumSamples) throw StateError('Insufficient samples for signal analysis.');
    final timestamps = samples.map((sample) => sample.timestamp).toList(growable: false);
    final rate = estimateSamplingRate(timestamps);
    final raw = samples.map((sample) => sample.channel(channel)).toList(growable: false);
    final mean = raw.reduce((a, b) => a + b) / raw.length;
    final detrended = raw.map((value) => value - mean).toList(growable: false);
    final filtered = ButterworthBandpass(config, rate).filter(detrended);
    final normalized = normalize(filtered);
    final sqi = calculateSqi(normalized, rate);
    return SignalAnalysis(filtered: normalized, samplingRate: rate, sqi: sqi, quality: qualityLabel(sqi));
  }

  double estimateSamplingRate(List<double> timestamps) {
    if (timestamps.length < 2 || timestamps.last <= timestamps.first) return config.targetSamplingRate;
    return (timestamps.length - 1) / (timestamps.last - timestamps.first);
  }

  List<double> normalize(List<double> values) {
    if (values.isEmpty) return const [];
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((value) => math.pow(value - mean, 2)).reduce((a, b) => a + b) / values.length;
    final deviation = math.sqrt(variance);
    if (deviation < 1e-9) return List<double>.filled(values.length, 0);
    return values.map((value) => (value - mean) / deviation).toList(growable: false);
  }

  double calculateSqi(List<double> signal, double samplingRate) {
    if (signal.length < 3) return 0;
    final rms = math.sqrt(signal.map((value) => value * value).reduce((a, b) => a + b) / signal.length);
    if (rms < 0.05) return 0;
    final bandPower = _spectralPower(signal, samplingRate, config.lowCutoffHz, config.highCutoffHz);
    final totalPower = _spectralPower(signal, samplingRate, 0.1, samplingRate / 2);
    final spectral = totalPower <= 0 ? 0.0 : (bandPower / totalPower).clamp(0.0, 1.0);
    final periodicity = _autocorrelationPeak(signal, samplingRate);
    final clipping = signal.where((value) => value.abs() > 3.5).length / signal.length;
    return (0.45 * spectral + 0.55 * periodicity - clipping * 0.5).clamp(0.0, 1.0);
  }

  String qualityLabel(double sqi) => sqi >= 0.75 ? 'Good' : sqi >= config.sqiThreshold ? 'Fair' : 'Poor';

  double _spectralPower(List<double> values, double rate, double low, double high) {
    var power = 0.0;
    for (var k = 1; k <= values.length ~/ 2; k++) {
      final frequency = k * rate / values.length;
      if (frequency < low || frequency > high) continue;
      var real = 0.0;
      var imaginary = 0.0;
      for (var n = 0; n < values.length; n++) {
        final angle = 2 * math.pi * k * n / values.length;
        real += values[n] * math.cos(angle);
        imaginary -= values[n] * math.sin(angle);
      }
      power += real * real + imaginary * imaginary;
    }
    return power;
  }

  double _autocorrelationPeak(List<double> values, double rate) {
    final minimumLag = math.max(1, (rate / config.highCutoffHz).floor());
    final maximumLag = math.min(values.length - 1, (rate / config.lowCutoffHz).ceil());
    var best = 0.0;
    var energy = 0.0;
    for (final value in values) {
      energy += value * value;
    }
    for (var lag = minimumLag; lag <= maximumLag; lag++) {
      var correlation = 0.0;
      for (var index = lag; index < values.length; index++) {
        correlation += values[index] * values[index - lag];
      }
      best = math.max(best, correlation / (energy == 0 ? 1 : energy));
    }
    return best.clamp(0.0, 1.0);
  }
}

class PPGWaveEstimate {
  const PPGWaveEstimate({
    required this.heartRateBpm,
    required this.signalQuality,
    required this.isValid,
  });

  final double heartRateBpm;
  final double signalQuality;
  final bool isValid;
}

class PPGWaveAnalyzer {
  const PPGWaveAnalyzer({
    this.sampleRate = 30.0,
    this.lowCutoffHz = 0.7,
    this.highCutoffHz = 3.0,
    this.smoothingWindow = 3,
  });

  final double sampleRate;
  final double lowCutoffHz;
  final double highCutoffHz;
  final int smoothingWindow;

  PPGWaveEstimate analyze(List<double> rawSignal) {
    if (rawSignal.length < 16) {
      return const PPGWaveEstimate(heartRateBpm: 0, signalQuality: 0, isValid: false);
    }

    final prepared = _prepare(rawSignal);
    final quality = _scoreQuality(prepared);
    if (quality < 0.24) {
      return PPGWaveEstimate(heartRateBpm: 0, signalQuality: quality, isValid: false);
    }

    final bpm = _dominantFrequencyBpm(prepared);
    final valid = bpm >= 42 && bpm <= 180;

    return PPGWaveEstimate(
      heartRateBpm: valid ? bpm : 0,
      signalQuality: quality,
      isValid: valid,
    );
  }

  List<double> _prepare(List<double> values) {
    final detrended = List<double>.from(values);
    final mean = _mean(detrended);
    for (var i = 0; i < detrended.length; i++) {
      detrended[i] -= mean;
    }

    final smoothed = _movingAverage(detrended, smoothingWindow);
    final filtered = _bandFocus(smoothed);
    final amplitude = _rootMeanSquare(filtered);
    if (amplitude < 1e-9) {
      return filtered;
    }

    for (var i = 0; i < filtered.length; i++) {
      filtered[i] /= amplitude;
    }
    return filtered;
  }

  List<double> _movingAverage(List<double> values, int radius) {
    final result = <double>[];
    for (var i = 0; i < values.length; i++) {
      var total = 0.0;
      var count = 0;
      final start = math.max(0, i - radius);
      final end = math.min(values.length - 1, i + radius);
      for (var j = start; j <= end; j++) {
        total += values[j];
        count++;
      }
      result.add(total / count);
    }
    return result;
  }

  List<double> _bandFocus(List<double> values) {
    final result = List<double>.filled(values.length, 0.0);
    for (var i = 1; i < values.length - 1; i++) {
      final prev = values[i - 1];
      final current = values[i];
      final next = values[i + 1];
      final slope = (next - prev) * 0.25;
      final smooth = (prev + current + next) / 3.0;
      result[i] = (current * 0.7) + (smooth * 0.2) + (slope * 0.1);
    }
    result[0] = values.first;
    result[result.length - 1] = values.last;
    return result;
  }

  double _scoreQuality(List<double> values) {
    if (values.isEmpty) return 0.0;
    final mean = _mean(values);
    final variance = _variance(values, mean);
    final std = math.sqrt(variance);
    if (std < 1e-8) return 0.0;

    final peakCount = _countProminentPeaks(values);
    final periodicity = (peakCount / math.max(1, values.length / 18.0)).clamp(0.0, 1.0);
    final amplitudeRatio = (std / (mean.abs() + 1e-8)).clamp(0.0, 1.0);
    return (0.55 * amplitudeRatio + 0.45 * periodicity).clamp(0.0, 1.0);
  }

  int _countProminentPeaks(List<double> values) {
    var count = 0;
    for (var i = 1; i < values.length - 1; i++) {
      final previous = values[i - 1];
      final current = values[i];
      final next = values[i + 1];
      if (current > previous && current > next && current > 0.12) {
        count++;
      }
    }
    return count;
  }

  double _dominantFrequencyBpm(List<double> values) {
    final binMin = math.max(1, ((lowCutoffHz * values.length) / sampleRate).round());
    final binMax = math.min(values.length ~/ 2, ((highCutoffHz * values.length) / sampleRate).round());
    if (binMin >= binMax || binMax <= 0) {
      return 0;
    }

    var bestPower = -1.0;
    var dominantBin = binMin;
    for (var bin = binMin; bin <= binMax; bin++) {
      var real = 0.0;
      var imaginary = 0.0;
      for (var index = 0; index < values.length; index++) {
        final angle = -2.0 * math.pi * bin * index / values.length;
        real += values[index] * math.cos(angle);
        imaginary += values[index] * math.sin(angle);
      }
      final power = real * real + imaginary * imaginary;
      if (power > bestPower) {
        bestPower = power;
        dominantBin = bin;
      }
    }

    if (dominantBin <= 0) return 0;
    final frequencyHz = dominantBin * sampleRate / values.length;
    return frequencyHz * 60.0;
  }

  double _mean(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((sum, value) => sum + value) / values.length;
  }

  double _variance(List<double> values, double mean) {
    if (values.isEmpty) return 0.0;
    var total = 0.0;
    for (final value in values) {
      final delta = value - mean;
      total += delta * delta;
    }
    return total / values.length;
  }

  double _rootMeanSquare(List<double> values) {
    if (values.isEmpty) return 0.0;
    var total = 0.0;
    for (final value in values) {
      total += value * value;
    }
    return math.sqrt(total / values.length);
  }
}

enum PPGChannel { red, green, blue }

extension PPGSampleChannel on PPGSample {
  double channel(PPGChannel channel) => switch (channel) {
        PPGChannel.red => red,
        PPGChannel.green => green,
        PPGChannel.blue => blue,
      };
}

class _Biquad {
  _Biquad(this.sampleRate, this.b0, this.b1, this.b2, this.a1, this.a2);

  final double sampleRate;
  final double b0;
  final double b1;
  final double b2;
  final double a1;
  final double a2;
  double _x1 = 0;
  double _x2 = 0;
  double _y1 = 0;
  double _y2 = 0;

  factory _Biquad.lowPass(double rate, double cutoff) {
    final w0 = 2 * math.pi * cutoff / rate;
    final alpha = math.sin(w0) / (2 * math.sqrt(0.5));
    final c = math.cos(w0);
    final a0 = 1 + alpha;
    return _Biquad(rate, (1 - c) / 2 / a0, (1 - c) / a0, (1 - c) / 2 / a0, -2 * c / a0, (1 - alpha) / a0);
  }

  factory _Biquad.highPass(double rate, double cutoff) {
    final w0 = 2 * math.pi * cutoff / rate;
    final alpha = math.sin(w0) / (2 * math.sqrt(0.5));
    final c = math.cos(w0);
    final a0 = 1 + alpha;
    return _Biquad(rate, (1 + c) / 2 / a0, -(1 + c) / a0, (1 + c) / 2 / a0, -2 * c / a0, (1 - alpha) / a0);
  }

  double process(double input) {
    final output = b0 * input + b1 * _x1 + b2 * _x2 - a1 * _y1 - a2 * _y2;
    _x2 = _x1;
    _x1 = input;
    _y2 = _y1;
    _y1 = output;
    return output;
  }
}