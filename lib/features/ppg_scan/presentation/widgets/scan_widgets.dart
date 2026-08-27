import 'package:camera/camera.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CameraPreviewWidget extends StatelessWidget {
  const CameraPreviewWidget({required this.controller, super.key});
  final CameraController? controller;

  static bool canRenderPreview(CameraController? controller) {
    if (controller == null) return false;
    try {
      return controller.value.isInitialized;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final camera = controller;
    if (!canRenderPreview(camera)) {
      return const SizedBox.shrink();
    }

    try {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(fit: StackFit.expand, children: [
          CameraPreview(camera!),
          const RoiOverlay(),
        ]),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}

class RoiOverlay extends StatelessWidget {
  const RoiOverlay({super.key});

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Center(
          child: Container(
            width: 156,
            height: 156,
            decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2), borderRadius: BorderRadius.circular(22), color: Colors.white.withValues(alpha: 0.06)),
            child: const Center(child: Text('64 x 64 ROI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
          ),
        ),
      );
}

class WaveformWidget extends StatelessWidget {
  const WaveformWidget({required this.samples, super.key});
  final List<double> samples;

  @override
  Widget build(BuildContext context) {
    final spots = samples.asMap().entries.map((entry) => FlSpot(entry.key.toDouble(), entry.value)).toList();
    return SizedBox(
      height: 120,
      child: spots.length < 2
          ? const Center(child: Text('Waiting for signal...', style: TextStyle(color: Color(0xff6a7b7d))))
          : LineChart(LineChartData(
              minY: -3,
              maxY: 3,
              minX: 0,
              maxX: spots.last.x,
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: const LineTouchData(enabled: false),
              lineBarsData: [LineChartBarData(spots: spots, isCurved: true, barWidth: 2.5, color: const Color(0xff0b6e69), dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: const Color(0xff0b6e69).withValues(alpha: 0.08)))],
            )),
    );
  }
}

class SignalQualityIndicator extends StatelessWidget {
  const SignalQualityIndicator({required this.quality, super.key});
  final double quality;

  @override
  Widget build(BuildContext context) {
    final label = quality >= 0.75 ? 'Good' : quality >= 0.5 ? 'Fair' : quality == 0 ? 'Waiting' : 'Poor';
    return Row(children: [Container(width: 9, height: 9, decoration: BoxDecoration(shape: BoxShape.circle, color: quality >= 0.5 ? const Color(0xff17856e) : const Color(0xffc47b2c))), const SizedBox(width: 8), Text('Signal quality: $label', style: const TextStyle(fontWeight: FontWeight.w600))]);
  }
}