import 'package:shared_preferences/shared_preferences.dart';

Future<String?> fnGetBaseUrl() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? BaseUrl = prefs.getString('BaseUrl');
  return BaseUrl;
}

Future<String?> fnGetDeviceId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? deviceId = prefs.getString('DeviceId');
  return deviceId;
}
