import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionRequester {
  static Future<bool> requestNotificationPermission() async {
    // For iOS and Android 13+ devices only, request notification permission

    // Check current status
    var status = await Permission.notification.status;

    if (status.isDenied || status.isRestricted) {
      // Request permission
      status = await Permission.notification.request();
    }

    if (status.isGranted) {
      print('Notification permission granted');
      return true;
    } else {
      print('Notification permission denied');
      return false;
    }
  }
}
