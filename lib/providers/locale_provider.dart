import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider لإدارة اللغة الحالية
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('ar', '')); // اللغة العربية كافتراضية

  void setLocale(Locale locale) {
    state = locale;
  }

  void toggleLocale() {
    if (state.languageCode == 'ar') {
      state = const Locale('en', '');
    } else {
      state = const Locale('ar', '');
    }
  }

  bool get isArabic => state.languageCode == 'ar';
}

