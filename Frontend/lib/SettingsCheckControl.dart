import 'package:shared_preferences/shared_preferences.dart';

class SettingsCheckControl {
  static Future<void> checkAndSetDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    // Check for 'notifications' setting, set to true if null
    prefs.setBool('notifications', prefs.getBool('notifications') ?? true);
    // Repeat for other settings
    prefs.setBool('popups', prefs.getBool('popups') ?? true);
    prefs.setBool('rememberLog', prefs.getBool('rememberLog') ?? false);
    prefs.setBool('locationServ', prefs.getBool('locationServ') ?? false);
    prefs.setBool('todayPopShown', false);
  }
}
