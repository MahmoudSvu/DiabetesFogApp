import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diabetes_fog_app/providers/monitoring_provider.dart';
import 'package:diabetes_fog_app/providers/ble_provider.dart';
import 'package:diabetes_fog_app/providers/locale_provider.dart';
import 'package:diabetes_fog_app/models/monitoring_state.dart';
import 'package:diabetes_fog_app/widgets/common_widgets.dart';
import 'package:diabetes_fog_app/theme/app_theme.dart';
import 'package:diabetes_fog_app/l10n/app_localizations.dart';
import 'package:diabetes_fog_app/services/geolocation_service.dart';
import 'package:diabetes_fog_app/models/event_log_model.dart';
import 'package:diabetes_fog_app/services/database_service.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class MonitoringDashboard extends ConsumerStatefulWidget {
  const MonitoringDashboard({super.key});

  @override
  ConsumerState<MonitoringDashboard> createState() => _MonitoringDashboardState();
}

class _MonitoringDashboardState extends ConsumerState<MonitoringDashboard> {
  String _selectedPeriod = 'week'; // 'week' or 'month'
  String? _lastLocationAddress;
  bool _isLoadingLocation = false;
  final GeolocationService _geolocationService = GeolocationService();
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _loadLastLocation();
    _initializeDefaultEvents();
  }

  Future<void> _loadLastLocation() async {
    try {
      final locationData = await _geolocationService.getLastKnownLocationWithAddress();
      setState(() {
        _lastLocationAddress = locationData['address'] as String?;
      });
    } catch (e) {
      print('Error loading last location: $e');
    }
  }

  Future<void> _initializeDefaultEvents() async {
    // التحقق من وجود أحداث في قاعدة البيانات
    final existingEvents = await _databaseService.getRecentEvents(limit: 1);
    
    // إذا لم تكن هناك أحداث، نضيف 5 أحداث افتراضية
    if (existingEvents.isEmpty) {
      final now = DateTime.now();
      final defaultEvents = [
        EventLogModel(
          timestamp: now.subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
          bgl: 120.0,
          state: MonitoringState.stable,
          eventType: 'reading',
          message: 'Normal reading',
        ),
        EventLogModel(
          timestamp: now.subtract(const Duration(hours: 4)).millisecondsSinceEpoch,
          bgl: 95.0,
          state: MonitoringState.preAlert,
          eventType: 'state_change',
          message: 'BGL below safe range',
        ),
        EventLogModel(
          timestamp: now.subtract(const Duration(hours: 6)).millisecondsSinceEpoch,
          bgl: 110.0,
          state: MonitoringState.stable,
          eventType: 'reading',
          message: 'Normal reading',
        ),
        EventLogModel(
          timestamp: now.subtract(const Duration(hours: 8)).millisecondsSinceEpoch,
          bgl: 70.0,
          state: MonitoringState.acuteRisk,
          eventType: 'alert',
          message: 'Acute risk detected',
        ),
        EventLogModel(
          timestamp: now.subtract(const Duration(hours: 10)).millisecondsSinceEpoch,
          bgl: 130.0,
          state: MonitoringState.stable,
          eventType: 'reading',
          message: 'Normal reading',
        ),
      ];

      for (var event in defaultEvents) {
        await _databaseService.insertEvent(event);
      }

      // تحديث provider
      ref.read(eventLogProvider.notifier).refresh();
    }
  }

  Future<void> _refreshLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final locationData = await _geolocationService.getCurrentLocationWithAddress();
      setState(() {
        _lastLocationAddress = locationData['address'] as String?;
        _isLoadingLocation = false;
      });
    } catch (e) {
      print('Error refreshing location: $e');
      setState(() {
        _isLoadingLocation = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    
    final currentBGL = ref.watch(currentBGLProvider);
    final currentState = ref.watch(currentStateProvider);
    final adaptiveInterval = ref.watch(adaptiveIntervalProvider);
    final eventLog = ref.watch(eventLogProvider);
    final bleConnection = ref.watch(bleConnectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.monitoringDashboard),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.monitor_heart,
              color: Color(0xFF041E76),
              size: 24,
            ),
          ),
        ),
        actions: [
          // مؤشر حالة الاتصال
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildConnectionIndicator(bleConnection, l10n),
          ),
          // زر تغيير اللغة
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              ref.read(localeProvider.notifier).toggleLocale();
            },
            tooltip: isArabic ? 'Switch to English' : 'التبديل إلى العربية',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(eventLogProvider.notifier).refresh();
          await _loadLastLocation();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // رسم بياني لحالة المريض
              _buildChartSection(l10n, isArabic),
              
              const SizedBox(height: 16),
              
              // صف الحالة الحالية مع البطارية والتردد
              _buildStatusRow(currentBGL, currentState, adaptiveInterval, l10n, isArabic),
              
              const SizedBox(height: 16),
              
              // الموقع النصي مع زر التحديث
              _buildLocationSection(l10n, isArabic),
              
              const SizedBox(height: 16),
              
              // سجل الأحداث
              _buildEventLog(eventLog, l10n, isArabic),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionIndicator(bleConnectionState, l10n) {
    Color color;
    String text;
    IconData icon;

    switch (bleConnectionState) {
      case BleConnectionState.connected:
        color = Colors.green;
        text = l10n.connected;
        icon = Icons.check_circle;
        break;
      case BleConnectionState.connecting:
      case BleConnectionState.scanning:
        color = Colors.orange;
        text = bleConnectionState == BleConnectionState.scanning ? 'Scanning...' : l10n.connecting;
        icon = Icons.sync;
        break;
      case BleConnectionState.error:
        color = Colors.red;
        text = 'Error';
        icon = Icons.error;
        break;
      default:
        color = Colors.grey;
        text = l10n.disconnected;
        icon = Icons.cancel;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: color, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildChartSection(l10n, isArabic) {
    return InfoCard(
      title: isArabic ? 'حالة المريض' : 'Patient Status',
      icon: Icons.show_chart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // خيارات الفترة الزمنية
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPeriodButton('week', isArabic ? 'أسبوع' : 'Week', isArabic),
              const SizedBox(width: 16),
              _buildPeriodButton('month', isArabic ? 'شهر' : 'Month', isArabic),
            ],
          ),
          const SizedBox(height: 16),
          // الرسم البياني
          SizedBox(
            height: 200,
            child: _buildChart(_selectedPeriod, ref.watch(eventLogProvider)),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period, String label, bool isArabic) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF041E76) : Colors.white.withOpacity(0.2),
          foregroundColor: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildChart(String period, List<EventLogModel> eventLog) {
    // استخدام البيانات الحقيقية من eventLog
    final isWeek = period == 'week';
    final daysToShow = isWeek ? 7 : 30;
    final cutoffTime = DateTime.now().subtract(Duration(days: daysToShow)).millisecondsSinceEpoch;
    
    // تصفية الأحداث حسب الفترة المحددة
    final filteredEvents = eventLog
        .where((event) => event.timestamp >= cutoffTime)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // إذا لم تكن هناك بيانات كافية، نستخدم البيانات المتاحة
    if (filteredEvents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No data available for selected period',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
          ),
        ),
      );
    }
    
    // تحويل الأحداث إلى نقاط للرسم البياني
    final spots = <FlSpot>[];
    final now = DateTime.now();
    
    for (int i = 0; i < filteredEvents.length; i++) {
      final event = filteredEvents[i];
      final eventDate = DateTime.fromMillisecondsSinceEpoch(event.timestamp);
      final daysAgo = now.difference(eventDate).inDays;
      final x = (daysToShow - daysAgo).toDouble();
      spots.add(FlSpot(x, event.bgl));
    }
    
    // حساب minY و maxY
    double minY = 50.0;
    double maxY = 200.0;
    if (spots.isNotEmpty) {
      final yValues = spots.map((s) => s.y).toList();
      minY = (yValues.reduce((a, b) => a < b ? a : b) - 20).clamp(0.0, double.infinity);
      maxY = (yValues.reduce((a, b) => a > b ? a : b) + 20).clamp(0.0, 300.0);
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: isWeek ? 1 : 5,
              getTitlesWidget: (value, meta) {
                final daysAgo = (isWeek ? 7 : 30) - value.toInt();
                if (daysAgo < 0 || daysAgo > (isWeek ? 7 : 30)) return const Text('');
                final date = DateTime.now().subtract(Duration(days: daysAgo));
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('d/M').format(date),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 20,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        minX: 0,
        maxX: (isWeek ? 7 : 30).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF041E76),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF041E76).withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(currentBGL, currentState, adaptiveInterval, l10n, isArabic) {
    return Row(
      children: [
        // التردد التكيفي (على اليسار)
        Expanded(
          child: _buildFrequencyCard(adaptiveInterval, l10n),
        ),
        const SizedBox(width: 16),
        // الحالة الحالية (في الوسط)
        Expanded(
          flex: 2,
          child: _buildStatusCard(currentBGL, currentState, l10n, isArabic),
        ),
        const SizedBox(width: 16),
        // البطارية (على اليمين)
        Expanded(
          child: _buildBatteryCard(currentBGL, l10n),
        ),
      ],
    );
  }

  Widget _buildStatusCard(currentBGL, currentState, l10n, isArabic) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: StateIndicator(
            state: currentState,
            isArabic: isArabic,
          ),
        ),
      ),
    );
  }

  Widget _buildBatteryCard(currentBGL, l10n) {
    final batteryLevel = currentBGL?.battery ?? 0.0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (currentBGL != null) ...[
              Icon(
                batteryLevel > 50 ? Icons.battery_full :
                batteryLevel > 20 ? Icons.battery_3_bar : Icons.battery_alert,
                color: batteryLevel > 50 ? Colors.green :
                batteryLevel > 20 ? Colors.orange : Colors.red,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                '${batteryLevel.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: batteryLevel > 20 ? Colors.white : Colors.red,
                ),
              ),
            ] else ...[
              Icon(Icons.battery_unknown, size: 32, color: Colors.white.withOpacity(0.5)),
              const SizedBox(height: 8),
              Text(
                'N/A',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyCard(int interval, l10n) {
    String intervalText;
    IconData icon;
    Color color;
    
    if (interval <= 60) {
      intervalText = '$interval s';
      icon = Icons.speed;
      color = Colors.red;
    } else if (interval <= 300) {
      intervalText = '${(interval / 60).toStringAsFixed(0)}m';
      icon = Icons.timer;
      color = Colors.orange;
    } else {
      intervalText = '${(interval / 60).toStringAsFixed(0)}m';
      icon = Icons.schedule;
      color = Colors.green;
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              intervalText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(l10n, isArabic) {
    return InfoCard(
      title: l10n.location,
      icon: Icons.location_on,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان النصي
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.place, color: Colors.white.withOpacity(0.8), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _lastLocationAddress ?? (isArabic ? 'جاري تحميل الموقع...' : 'Loading location...'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // زر التحديث
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoadingLocation ? null : _refreshLocation,
              icon: _isLoadingLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.refresh),
              label: Text(isArabic ? 'تحديث الموقع' : 'Refresh Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF041E76),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventLog(List eventLog, l10n, isArabic) {
    // عرض آخر 5 أحداث
    final displayEvents = eventLog.take(5).toList();
    
    return InfoCard(
      title: l10n.eventLog,
      icon: Icons.history,
      child: displayEvents.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(Icons.history, size: 48, color: Colors.white.withOpacity(0.5)),
                    const SizedBox(height: 8),
                    Text(
                      isArabic ? 'لا توجد أحداث' : 'No events yet',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayEvents.length,
                  itemBuilder: (context, index) {
                    final event = displayEvents[index];
                    final dateTime = DateTime.fromMillisecondsSinceEpoch(event.timestamp);
                    final formattedDate = DateFormat('HH:mm').format(dateTime);
                    final formattedDateFull = DateFormat('MMM dd, HH:mm').format(dateTime);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 2,
                      color: const Color(0xFF0A2B6B),
                      child: ListTile(
                        dense: true,
                        leading: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppTheme.getStateColor(event.state.index),
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(
                          '${event.bgl.toStringAsFixed(1)} ${l10n.mgdL}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              isArabic 
                                ? _getStateNameAr(event.state)
                                : event.state.displayName,
                              style: TextStyle(
                                color: AppTheme.getStateColor(event.state.index),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              formattedDateFull,
                              style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)),
                            ),
                          ],
                        ),
                        trailing: Text(
                          formattedDate,
                          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }

  // Helper method to get Arabic state name safely
  String _getStateNameAr(MonitoringState state) {
    switch (state) {
      case MonitoringState.stable:
        return 'مستقر';
      case MonitoringState.preAlert:
        return 'إنذار مسبق';
      case MonitoringState.acuteRisk:
        return 'خطر حاد';
      case MonitoringState.criticalEmergency:
        return 'طوارئ حرجة';
    }
  }
}
