import 'package:equatable/equatable.dart';

enum RoiPosition { centered }

class RoiConfig extends Equatable {
  const RoiConfig({this.width = 64, this.height = 64, this.position = RoiPosition.centered});

  final int width;
  final int height;
  final RoiPosition position;

  @override
  List<Object> get props => [width, height, position];
}

class PPGSample extends Equatable {
  const PPGSample({required this.timestamp, required this.red, required this.green, required this.blue});

  final double timestamp;
  final double red;
  final double green;
  final double blue;

  @override
  List<Object> get props => [timestamp, red, green, blue];
}

class BloodPressure extends Equatable {
  const BloodPressure({required this.systolic, required this.diastolic});

  final double systolic;
  final double diastolic;

  @override
  List<Object> get props => [systolic, diastolic];
}

class VitalsResult extends Equatable {
  const VitalsResult({
    required this.heartRateBpm,
    required this.spo2Percent,
    required this.bloodPressure,
    required this.signalQuality,
    required this.timestamp,
    this.experimental = true,
  });

  final double heartRateBpm;
  final double spo2Percent;
  final BloodPressure bloodPressure;
  final double signalQuality;
  final DateTime timestamp;
  final bool experimental;

  @override
  List<Object> get props => [heartRateBpm, spo2Percent, bloodPressure, signalQuality, timestamp, experimental];
}