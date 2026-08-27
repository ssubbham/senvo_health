import 'package:permission_handler/permission_handler.dart';

enum CameraPermissionStatus { granted, denied, permanentlyDenied, restricted }

class PermissionService {
  Future<CameraPermissionStatus> requestCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) return CameraPermissionStatus.granted;
    if (status.isPermanentlyDenied) return CameraPermissionStatus.permanentlyDenied;
    if (status.isRestricted || status.isLimited) return CameraPermissionStatus.restricted;
    return CameraPermissionStatus.denied;
  }
}