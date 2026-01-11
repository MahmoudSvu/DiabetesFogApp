import 'package:flutter/material.dart';
import 'package:diabetes_fog_app/main.dart';
import 'package:diabetes_fog_app/services/database_service.dart';
import 'package:diabetes_fog_app/models/settings_model.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;

    // حفظ حالة شاشة الترحيب في قاعدة البيانات
    // نستخدم حقل deviceID كعلامة - إذا كان 'welcome_seen' يعني أن المستخدم رأى الترحيب
    final dbService = DatabaseService();
    final settings = await dbService.getSettings();
    final currentSettings = settings ?? SettingsModel();
    // حفظ علامة أن المستخدم رأى شاشة الترحيب
    // نضع 'welcome_seen' كعلامة مؤقتة (سيتم استبدالها عندما يدخل المستخدم deviceID حقيقي)
    if (currentSettings.deviceID == null || 
        currentSettings.deviceID!.isEmpty || 
        currentSettings.deviceID == 'welcome_seen') {
      await dbService.saveSettings(currentSettings.copyWith(deviceID: 'welcome_seen'));
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041E76),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF041E76),
              const Color(0xFF031452),
              const Color(0xFF0A2B6B),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.monitor_heart,
                      size: 80,
                      color: Color(0xFF041E76),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Title with slide animation
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Column(
                    children: [
                      Text(
                        'مراقبة السكري',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Diabetes Monitoring',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFFE0E0E0),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 60),
              
              // Description
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text(
                    'نظام ذكي لمراقبة مستويات الجلوكوز في الدم\nمع تنبيهات فورية واتصال طارئ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
              
              // Loading indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

