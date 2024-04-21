import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestCameraGalleryPermissions() async {
    // Solicita permisos para la cámara y la galería
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.photos,
    ].request();

    // Comprueba si los permisos fueron concedidos
    bool hasCameraPermission = statuses[Permission.camera]?.isGranted ?? false;
    bool hasGalleryPermission = statuses[Permission.photos]?.isGranted ?? false;

    return hasCameraPermission && hasGalleryPermission;
  }
}
