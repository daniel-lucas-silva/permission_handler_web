import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class PermissionHandlerWeb {
  static const Map<int, String> permissionsGroup = {
    1: "camera",
    15: "persistent-storage",
    17: "notifications",
    //
    3: "geolocation",
    4: "geolocation",
    5: "geolocation",
    //
    7: "microphone",
    14: "microphone",
    //
    6: "storage-access",
    9: "storage-access",
    10: "storage-access",
    22: "storage-access",
    //
    21: "bluetooth",
    28: "bluetooth",
    29: "bluetooth",
    30: "bluetooth",
    //
    96: "device-info",
    97: "speaker",
    98: "midi",
    99: "push",
  };

  static void registerWith(Registrar registrar) {
    const MethodChannel channel = MethodChannel(
      'flutter.baseflow.com/permissions/methods',
      StandardMethodCodec(),
    );

    final PermissionHandlerWeb instance = PermissionHandlerWeb();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'checkServiceStatus':
        return _checkServiceStatus(call.arguments['permission']);
      case 'checkPermissionStatus':
        return _checkPermissionStatus(call.arguments['permission']);
      case 'requestPermissions':
        return _requestPermissions(call.arguments['permissions']);
      // Handle other method calls
      case 'shouldShowRequestPermissionRationale':
      case 'openAppSettings':
        return false;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: "THE PERMISSION_HANDLER PLUGIN FOR WEB DOESN'T IMPLEMENT "
              "the method '${call.method}'",
        );
    }
  }

  Future<int> _checkServiceStatus(int permission) async {
    final serviceStatus = await _checkPermissionStatus(permission);
    return serviceStatus;
  }

  Future<int> _checkPermissionStatus(int permission) async {
    final permissionName = _permissionValueToPermissionName(permission);
    if (permissionName == null) return 0; // Denied

    final status = await html.window.navigator.permissions?.query({'name': permissionName});
    return _convertWebPermissionStatusToPluginPermissionStatus(status?.state);
  }

  Future<Map<int, int>> _requestPermissions(List<int> permissions) async {
    Map<int, int> statuses = {};
    for (var permission in permissions) {
      final status = await _checkPermissionStatus(permission);
      statuses[permission] = status;
    }
    return statuses;
  }

  // Convert the permission value to the browser permission name.
  String? _permissionValueToPermissionName(int permissionValue) {
    // Maps permission values to their browser permission names.
    return permissionsGroup[permissionValue];
  }

  // Converts the web permission status to the permission handler permission status.
  int _convertWebPermissionStatusToPluginPermissionStatus(String? state) {
    switch (state) {
      case 'prompt':
        return 0; // Denied
      case 'granted':
        return 1; // Granted
      case 'denied':
        return 4; // Permanently denied
      default:
        return 0; // Denied
    }
  }
}
