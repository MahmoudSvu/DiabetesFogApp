import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:diabetes_fog_app/providers/monitoring_provider.dart';
import 'package:diabetes_fog_app/providers/ble_provider.dart';
import 'package:diabetes_fog_app/providers/locale_provider.dart';
import 'package:diabetes_fog_app/models/monitoring_state.dart';
import 'package:diabetes_fog_app/widgets/common_widgets.dart';
import 'package:diabetes_fog_app/theme/app_theme.dart';
import 'package:diabetes_fog_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class MonitoringDashboard extends ConsumerStatefulWidget {
  const MonitoringDashboard({super.key});

  @override
  ConsumerState<MonitoringDashboard> createState() => _MonitoringDashboardState();
}

class _MonitoringDashboardState extends ConsumerState<MonitoringDashboard> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    // في التطبيق الحقيقي، سيتم الحصول على الموقع من GeolocationService
    // للتبسيط، سنستخدم موقع افتراضي
    setState(() {
      _currentLocation = const LatLng(33.5132, 36.2768); // مدينة دمشق
    });
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
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // لوحة الحالة الفورية
              _buildStatusCard(currentBGL, currentState, l10n, isArabic),
              
              const SizedBox(height: 16),
              
              // صف المؤشرات
              Row(
                children: [
                  Expanded(
                    child: _buildBatteryCard(currentBGL, l10n),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFrequencyCard(adaptiveInterval, l10n),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // خريطة الموقع
              _buildLocationMap(l10n),
              
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

  Widget _buildStatusCard(currentBGL, currentState, l10n, isArabic) {
    return InfoCard(
      title: l10n.currentState,
      icon: Icons.monitor_heart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentBGL != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.currentBGL,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                ),
                Text(
                  '${currentBGL.bgl.toStringAsFixed(1)} ${l10n.mgdL}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getStateColor(currentState.index),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.trend,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                ),
                _buildTrendIndicator(currentBGL.trend),
              ],
            ),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.signal_wifi_off, size: 48, color: Colors.white.withOpacity(0.5)),
                    const SizedBox(height: 8),
                    Text(
                      'No data available',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Waiting for device connection...',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          StateIndicator(
            state: currentState,
            isArabic: isArabic,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIndicator(int trend) {
    IconData icon;
    Color color;
    String text;

    if (trend > 0) {
      icon = Icons.arrow_upward;
      color = Colors.red;
      text = 'Rising';
    } else if (trend < 0) {
      icon = Icons.arrow_downward;
      color = Colors.blue;
      text = 'Falling';
    } else {
      icon = Icons.arrow_forward;
      color = Colors.grey;
      text = 'Stable';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBatteryCard(currentBGL, l10n) {
    final batteryLevel = currentBGL?.battery ?? 0.0;
    
    return InfoCard(
      title: l10n.battery,
      icon: batteryLevel > 20 ? Icons.battery_charging_full : Icons.battery_alert,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentBGL != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: batteryLevel / 100,
                minHeight: 8,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  batteryLevel > 50 ? Colors.green : 
                  batteryLevel > 20 ? Colors.orange : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${batteryLevel.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: batteryLevel > 20 ? Colors.black87 : Colors.red,
                  ),
                ),
                Icon(
                  batteryLevel > 50 ? Icons.battery_full :
                  batteryLevel > 20 ? Icons.battery_3_bar : Icons.battery_alert,
                  color: batteryLevel > 50 ? Colors.green :
                  batteryLevel > 20 ? Colors.orange : Colors.red,
                ),
              ],
            ),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'N/A',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFrequencyCard(int interval, l10n) {
    String intervalText;
    IconData icon;
    Color color;
    
    if (interval <= 60) {
      intervalText = '$interval ${l10n.seconds}';
      icon = Icons.speed;
      color = Colors.red;
    } else if (interval <= 300) {
      intervalText = '${(interval / 60).toStringAsFixed(0)} min';
      icon = Icons.timer;
      color = Colors.orange;
    } else {
      intervalText = '${(interval / 60).toStringAsFixed(0)} min';
      icon = Icons.schedule;
      color = Colors.green;
    }
    
    return InfoCard(
      title: l10n.adaptiveFrequency,
      icon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                intervalText,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
      const SizedBox(height: 8),
      Text(
        'Update interval',
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildLocationMap(l10n) {
    return InfoCard(
      title: l10n.location,
      icon: Icons.location_on,
      child: SizedBox(
        height: 200,
        child: _currentLocation != null
            ? GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentLocation!,
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('patient_location'),
                    position: _currentLocation!,
                    infoWindow: const InfoWindow(title: 'Patient Location'),
                  ),
                },
                onMapCreated: (controller) {
                  _mapController = controller;
                },
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  Widget _buildEventLog(List eventLog, l10n, isArabic) {
    return InfoCard(
      title: l10n.eventLog,
      icon: Icons.history,
      child: eventLog.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(Icons.history, size: 48, color: Colors.white.withOpacity(0.5)),
                    const SizedBox(height: 8),
                    Text(
                      'No events yet',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Events will appear here',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
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
                  itemCount: eventLog.length > 10 ? 10 : eventLog.length,
                  itemBuilder: (context, index) {
                    final event = eventLog[index];
                    final dateTime = DateTime.fromMillisecondsSinceEpoch(event.timestamp);
                    final formattedDate = DateFormat('HH:mm:ss').format(dateTime);
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
                              isArabic ? event.state.displayNameAr : event.state.displayName,
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
                if (eventLog.length > 10)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Showing latest 10 of ${eventLog.length} events',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
    );
  }
}

