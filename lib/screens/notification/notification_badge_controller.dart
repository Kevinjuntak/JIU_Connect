class NotificationBadgeController {
  static int _badgeCount = 0;

  static int get badgeCount => _badgeCount;

  static void updateBadge(int count) {
    _badgeCount = count;
  }

  static void clearBadge() {
    _badgeCount = 0;
  }
}
