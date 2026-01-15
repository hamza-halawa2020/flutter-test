import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  bool _isArabic = false;

  bool get isArabic => _isArabic;

  void toggleLanguage() {
    _isArabic = !_isArabic;
    notifyListeners();
  }

  void setArabic(bool isArabic) {
    _isArabic = isArabic;
    notifyListeners();
  }

  String translate(String key) {
    final translations = {
      // English/Arabic key translations
      'prayers': _isArabic ? 'الصلوات' : 'Prayers',
      'dashboard': _isArabic ? 'لوحة التحكم' : 'Dashboard',
      'statistics': _isArabic ? 'الإحصائيات' : 'Statistics',
      'history': _isArabic ? 'السجل' : 'History',
      'settings': _isArabic ? 'الإعدادات' : 'Settings',
      'today': _isArabic ? 'اليوم' : 'Today',
      'fajr': _isArabic ? 'الفجر' : 'Fajr',
      'dhuhr': _isArabic ? 'الظهر' : 'Dhuhr',
      'asr': _isArabic ? 'العصر' : 'Asr',
      'maghrib': _isArabic ? 'المغرب' : 'Maghrib',
      'isha': _isArabic ? 'العشاء' : 'Isha',
      'prayed': _isArabic ? 'صليت هذه الصلاة' : 'I prayed this prayer',
      'remaining': _isArabic ? 'المتبقي' : 'Remaining',
      'backup': _isArabic ? 'النسخ الاحتياطي' : 'Backup',
      'restore': _isArabic ? 'استعادة' : 'Restore',
      'export': _isArabic ? 'تصدير' : 'Export',
      'import': _isArabic ? 'استيراد' : 'Import',
      'confirm': _isArabic ? 'تأكيد' : 'Confirm',
      'cancel': _isArabic ? 'إلغاء' : 'Cancel',
      'delete': _isArabic ? 'حذف' : 'Delete',
      'save': _isArabic ? 'حفظ' : 'Save',
      'completed_today': _isArabic ? 'اكتمل اليوم' : 'Completed Today',
      'total': _isArabic ? 'المجموع' : 'Total',
      'filter_by_date': _isArabic ? 'التصفية حسب التاريخ' : 'Filter by Date',
      'filter_by_prayer': _isArabic ? 'التصفية حسب الصلاة' : 'Filter by Prayer',
      'dark_mode': _isArabic ? 'الوضع الليلي' : 'Dark Mode',
      'language': _isArabic ? 'اللغة' : 'Language',
      'setup': _isArabic ? 'الإعداد' : 'Setup',
      'initial_setup': _isArabic ? 'الإعداد الأولي' : 'Initial Setup',
      'enter_missed_prayers': _isArabic ? 'أدخل عدد الصلوات المفقودة' : 'Enter missed prayers count',
    };
    return translations[key] ?? key;
  }
}
