import 'package:camera/camera.dart';

import '../../../../services/camera/camera_service.dart';
import '../../../../services/permissions/permission_service.dart';
import '../entities/ppg_entities.dart';

abstract class CameraRepository {
  CameraController? get controller;
  Future<void> initialize();
  Future<void> startStream(void Function(CameraImage) onFrame);
  Future<void> stopStream();
  Future<void> setTorch(bool enabled);
  Future<void> dispose();
}

class CameraRepositoryImpl implements CameraRepository {
  CameraRepositoryImpl(this.service);

  final CameraService service;

  @override
  CameraController? get controller => service.controller;
  @override
  Future<void> initialize() => service.initialize();
  @override
  Future<void> startStream(void Function(CameraImage) onFrame) => service.startStream(onFrame);
  @override
  Future<void> stopStream() => service.stopStream();
  @override
  Future<void> setTorch(bool enabled) => service.setTorch(enabled);
  @override
  Future<void> dispose() => service.dispose();
}

abstract class PermissionRepository {
  Future<CameraPermissionStatus> requestCamera();
}

class PermissionRepositoryImpl implements PermissionRepository {
  PermissionRepositoryImpl(this.service);

  final PermissionService service;

  @override
  Future<CameraPermissionStatus> requestCamera() => service.requestCamera();
}

class ScanDataRepository {
  const ScanDataRepository();

  RoiConfig get roi => const RoiConfig();
}