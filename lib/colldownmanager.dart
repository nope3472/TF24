import 'package:shared_preferences/shared_preferences.dart';

class CooldownManager {
  static const String _lastColorTimestampKey = 'last_color_timestamp';
  static const int cooldownDuration = 15; // Cooldown duration in seconds

  /// Checks if the user can color a pixel based on the cooldown period.
  Future<bool> canColorPixel() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? lastColorTimestamp = prefs.getInt(_lastColorTimestampKey);

      if (lastColorTimestamp == null) {
        return true; // No timestamp recorded, can color pixel
      }

      DateTime lastColorTime =
      DateTime.fromMillisecondsSinceEpoch(lastColorTimestamp);
      DateTime now = DateTime.now();

      // Returns true if the cooldown period has passed
      return now.difference(lastColorTime).inSeconds >= cooldownDuration;
    } catch (e) {
      return false; // In case of error, assume cooldown is active
    }
  }

  /// Records the timestamp of when the user colors a pixel.
  Future<void> recordPixelColored() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          _lastColorTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
    }
  }

  /// Returns the remaining cooldown time in seconds.
  Future<int> getRemainingCooldownTime() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? lastColorTimestamp = prefs.getInt(_lastColorTimestampKey);

      if (lastColorTimestamp == null) {
        return 0; // No timestamp, no cooldown time remaining
      }

      DateTime lastColorTime =
      DateTime.fromMillisecondsSinceEpoch(lastColorTimestamp);
      DateTime now = DateTime.now();

      int elapsedSeconds = now.difference(lastColorTime).inSeconds;
      int remainingTime = cooldownDuration - elapsedSeconds;

      return remainingTime > 0
          ? remainingTime
          : 0; // Return 0 if cooldown has expired
    } catch (e) {
      return cooldownDuration; // In case of error, assume full cooldown time remaining
    }
  }
}