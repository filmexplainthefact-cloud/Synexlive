import 'package:flutter/material.dart';

class AppHelpers {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showToast(String msg, {bool isError = false}) {
    messengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError
          ? const Color(0xFFFF6B6B)
          : const Color(0xFF6C63FF),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  static void showSnackBar(BuildContext ctx, String msg,
      {bool isError = false}) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError
          ? const Color(0xFFFF6B6B)
          : const Color(0xFF6C63FF),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  static Future<bool> showConfirmDialog(
    BuildContext ctx, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final res = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A26),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700)),
        content: Text(message,
            style: const TextStyle(color: Color(0xFF8888AA))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(cancelText,
                  style: const TextStyle(
                      color: Color(0xFF8888AA)))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(confirmText,
                  style: TextStyle(
                      color: isDestructive
                          ? const Color(0xFFFF6B6B)
                          : const Color(0xFF6C63FF),
                      fontWeight: FontWeight.w700))),
        ],
      ),
    );
    return res ?? false;
  }

  static String formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  static String getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  static Color getAvatarColor(String name) {
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFFFF6B6B),
      const Color(0xFF2ED573),
      const Color(0xFFFFD93D),
      const Color(0xFF48DBFB),
      const Color(0xFFFF9FF3),
    ];
    int hash = 0;
    for (var c in name.runes) hash = c + ((hash << 5) - hash);
    return colors[hash.abs() % colors.length];
  }
}
