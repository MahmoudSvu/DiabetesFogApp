import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diabetes_fog_app/services/api_service.dart';
import 'package:diabetes_fog_app/services/database_service.dart';
import 'package:diabetes_fog_app/models/settings_model.dart';

// Provider لخدمة API
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Provider لحالة تسجيل الدخول
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthState {
  final bool isAuthenticated;
  final String? deviceId;
  final String? patientCode;
  final bool isLoading;

  AuthState({
    this.isAuthenticated = false,
    this.deviceId,
    this.patientCode,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? deviceId,
    String? patientCode,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      deviceId: deviceId ?? this.deviceId,
      patientCode: patientCode ?? this.patientCode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  final DatabaseService _databaseService = DatabaseService();

  AuthNotifier(this._ref) : super(AuthState()) {
    _checkAuthStatus();
  }

  // التحقق من حالة تسجيل الدخول عند بدء التطبيق
  Future<void> _checkAuthStatus() async {
    try {
      final settings = await _databaseService.getSettings();
      if (settings?.deviceID != null && settings!.deviceID!.isNotEmpty) {
        // يوجد deviceId محفوظ - المستخدم مسجل دخول
        state = AuthState(
          isAuthenticated: true,
          deviceId: settings.deviceID,
          patientCode: settings.patientCode,
        );
      }
    } catch (e) {
      print('Error checking auth status: $e');
    }
  }

  // تسجيل الدخول
  Future<bool> login(String patientCode) async {
    try {
      state = state.copyWith(isLoading: true);

      final apiService = _ref.read(apiServiceProvider);
      final deviceId = await apiService.login(patientCode);

      if (deviceId != null && deviceId.isNotEmpty) {
        // حفظ deviceId و patientCode في قاعدة البيانات
        final settings = await _databaseService.getSettings();
        final updatedSettings = (settings ?? SettingsModel()).copyWith(
          deviceID: deviceId,
          patientCode: patientCode,
        );
        await _databaseService.saveSettings(updatedSettings);

        state = AuthState(
          isAuthenticated: true,
          deviceId: deviceId,
          patientCode: patientCode,
          isLoading: false,
        );

        return true;
      } else {
        state = state.copyWith(isLoading: false);
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    try {
      // حذف deviceId و patientCode من قاعدة البيانات
      final settings = await _databaseService.getSettings();
      if (settings != null) {
        final updatedSettings = settings.copyWith(
          deviceID: null,
          patientCode: null,
        );
        await _databaseService.saveSettings(updatedSettings);
      }

      state = AuthState(isAuthenticated: false);
    } catch (e) {
      print('Logout error: $e');
    }
  }
}
