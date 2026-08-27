import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';

abstract class CameraService {
  CameraController? get controller;
  Future<void> initialize();
  Future<void> startStream(void Function(CameraImage image) onFrame);
  Future<void> stopStream();
  Future<void> setTorch(bool enabled);
  Future<void> dispose();
}

class CameraServiceImpl implements CameraService {
  CameraController? _controller;
  bool _streaming = false;

  @override
  CameraController? get controller => _controller;

  @override
  Future<void> initialize() async {
    final cameras = await availableCameras();
    final rear = cameras.where((camera) => camera.lensDirection == CameraLensDirection.back).firstOrNull;
    if (rear == null) throw CameraException('no_rear_camera', 'No rear camera is available.');
    final controller = CameraController(
      rear,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.yuv420,
    );
    await controller.initialize();
    _controller = controller;
  }

  @override
  Future<void> startStream(void Function(CameraImage image) onFrame) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) throw StateError('Camera is not initialized.');
    if (_streaming) return;
    await controller.startImageStream(onFrame);
    _streaming = true;
  }

  @override
  Future<void> stopStream() async {
    final controller = _controller;
    if (_streaming && controller != null) await controller.stopImageStream();
    _streaming = false;
  }

  @override
  Future<void> setTorch(bool enabled) async {
    final controller = _controller;
    if (controller == null) throw StateError('Camera is not initialized.');
    await controller.setFlashMode(enabled ? FlashMode.torch : FlashMode.off);
  }

  @override
  Future<void> dispose() async {
    await stopStream();
    await _controller?.dispose();
    _controller = null;
  }
}