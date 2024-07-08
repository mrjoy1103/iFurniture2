import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  static Future<String?> getServerAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('server_address');
  }

  static Future<String?> getDeviceName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('device_name');
  }

  static Future<String?> getTokenAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }
}
