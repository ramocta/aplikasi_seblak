class NotificationsTimeUtil {
  static String formatNotificationTime(String rawTime, {String? fallbackTime}) {
    try {
      final fallback = fallbackTime ?? _getCurrentTimeFormatted();

      if (rawTime.trim().isEmpty) {
        return fallback;
      }

      // If using standard Laravel ISO DateTime string (e.g., 2026-05-24 14:30:00)
      if (rawTime.length >= 16) {
        return rawTime.substring(11, 16); // Extract HH:mm part directly
      }

      // Fallback parser using DateTime
      final parsedDate = DateTime.parse(rawTime);
      return "${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return fallbackTime ?? _getCurrentTimeFormatted();
    }
  }

  static String _getCurrentTimeFormatted() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }
}

