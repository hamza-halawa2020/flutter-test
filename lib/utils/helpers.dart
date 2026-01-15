import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatTime(DateTime dateTime) {
  return DateFormat('HH:mm').format(dateTime);
}

String formatDate(DateTime dateTime) {
  return DateFormat('yyyy-MM-dd').format(dateTime);
}

String formatFullDateTime(DateTime dateTime) {
  return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
}

String formatDateDisplay(DateTime dateTime) {
  return DateFormat('EEEE, MMMM d, yyyy').format(dateTime);
}

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

int getDayOfYear(DateTime date) {
  return int.parse(DateFormat('D').format(date));
}

Color getColorForPrayer(String prayerName) {
  switch (prayerName) {
    case 'Fajr':
      return Color(0xFF6B5B95);
    case 'Dhuhr':
      return Color(0xFFFFA500);
    case 'Asr':
      return Color(0xFFD4A574);
    case 'Maghrib':
      return Color(0xFFFF6B6B);
    case 'Isha':
      return Color(0xFF1A237E);
    default:
      return Color(0xFF06A77D);
  }
}

String getMotivationalMessage(int count) {
  if (count == 0) {
    return 'Start your journey! 🌙';
  } else if (count <= 5) {
    return 'Great start! Keep going! 💪';
  } else if (count <= 10) {
    return 'Amazing progress! 🎯';
  } else if (count <= 20) {
    return 'You\'re doing great! ⭐';
  } else if (count <= 50) {
    return 'Incredible dedication! 🏆';
  } else {
    return 'Mashallah! You\'re a true believer! 🌟';
  }
}
