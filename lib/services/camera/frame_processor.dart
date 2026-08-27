import 'dart:math' as math;

import 'package:camera/camera.dart';

import '../../features/ppg_scan/domain/entities/ppg_entities.dart';

abstract class FrameProcessor {
  Future<PPGSample?> process(CameraImage frame);
}

class CameraFrameProcessor implements FrameProcessor {
  CameraFrameProcessor({this.roi = const RoiConfig()});

  final RoiConfig roi;

  @override
  Future<PPGSample?> process(CameraImage frame) async {
    final width = frame.width;
    final height = frame.height;
    if (width < roi.width || height < roi.height) return null;
    final left = (width - roi.width) ~/ 2;
    final top = (height - roi.height) ~/ 2;
    var red = 0.0;
    var green = 0.0;
    var blue = 0.0;
    var pixels = 0;

    for (var y = top; y < top + roi.height; y++) {
      for (var x = left; x < left + roi.width; x++) {
        final rgb = _pixel(frame, x, y);
        if (rgb == null) continue;
        red += rgb.$1;
        green += rgb.$2;
        blue += rgb.$3;
        pixels++;
      }
    }
    if (pixels == 0) return null;
    return PPGSample(
      timestamp: DateTime.now().microsecondsSinceEpoch / Duration.microsecondsPerSecond,
      red: red / pixels,
      green: green / pixels,
      blue: blue / pixels,
    );
  }

  (double, double, double)? _pixel(CameraImage image, int x, int y) {
    if (image.format.group == ImageFormatGroup.bgra8888) {
      final plane = image.planes.first;
      final offset = y * plane.bytesPerRow + x * 4;
      if (offset + 2 >= plane.bytes.length) return null;
      return (plane.bytes[offset + 2].toDouble(), plane.bytes[offset + 1].toDouble(), plane.bytes[offset].toDouble());
    }
    if (image.format.group != ImageFormatGroup.yuv420 || image.planes.length < 3) return null;
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];
    final yIndex = y * yPlane.bytesPerRow + x * yPlane.bytesPerPixel!;
    final uvX = x ~/ 2;
    final uvY = y ~/ 2;
    final uIndex = uvY * uPlane.bytesPerRow + uvX * uPlane.bytesPerPixel!;
    final vIndex = uvY * vPlane.bytesPerRow + uvX * vPlane.bytesPerPixel!;
    if (yIndex >= yPlane.bytes.length || uIndex >= uPlane.bytes.length || vIndex >= vPlane.bytes.length) return null;
    final luminance = yPlane.bytes[yIndex].toDouble();
    final u = uPlane.bytes[uIndex].toDouble() - 128;
    final v = vPlane.bytes[vIndex].toDouble() - 128;
    return (_clamp(luminance + 1.402 * v), _clamp(luminance - 0.344136 * u - 0.714136 * v), _clamp(luminance + 1.772 * u));
  }

  double _clamp(double value) => math.max(0, math.min(255, value));
}