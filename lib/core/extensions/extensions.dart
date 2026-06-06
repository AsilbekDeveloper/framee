import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ─── BuildContext Extensions ───────────────────────────────────────────────────
extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  bool get isTablet => screenWidth >= 600;

  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void hideKeyboard() => FocusScope.of(this).unfocus();
}

// ─── String Extensions ────────────────────────────────────────────────────────
extension StringX on String {
  String get initials {
    final parts = trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String get firstInitial =>
      isNotEmpty ? this[0].toUpperCase() : '?';

  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  bool get isValidUsername =>
      RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(this);

  bool get isValidUrl =>
      Uri.tryParse(this)?.hasAbsolutePath ?? false;

  String get withAt => startsWith('@') ? this : '@$this';

  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }

  String get capitalizeFirst =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

// ─── DateTime Extensions ──────────────────────────────────────────────────────
extension DateTimeX on DateTime {
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(this);
  }

  String get fullDate => DateFormat('MMMM d, y').format(this);
  String get shortDate => DateFormat('MMM d').format(this);
  String get time => DateFormat('h:mm a').format(this);
}

// ─── num Extensions ───────────────────────────────────────────────────────────
extension NumX on num {
  String get compact {
    if (this >= 1000000) return '${(this / 1000000).toStringAsFixed(1)}M';
    if (this >= 1000) return '${(this / 1000).toStringAsFixed(1)}k';
    return toString();
  }
}

// ─── List Extensions ──────────────────────────────────────────────────────────
extension ListX<T> on List<T> {
  List<T> get safeReversed => reversed.toList();

  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
}
