import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:diabetes_fog_app/providers/settings_provider.dart';
import 'package:diabetes_fog_app/providers/ble_provider.dart';
import 'package:diabetes_fog_app/l10n/app_localizations.dart';

class EdgeConnectivitySection extends ConsumerStatefulWidget {
  const EdgeConnectivitySection({super.key});

  @override
  ConsumerState<EdgeConnectivitySection> createState() => _EdgeConnectivitySectionState();
}

class _EdgeConnectivitySectionState extends ConsumerState<EdgeConnectivitySection> {
  final _deviceIDController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settings = ref.read(settingsProvider);
    if (settings != null) {
      _deviceIDController.text = settings.deviceID ?? '';
    }
  }

  @override
  void dispose() {
    _deviceIDController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bleConnection = ref.watch(bleConnectionProvider);
    final scannedDevices = ref.watch(scannedDevicesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bluetooth, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  l10n.edgeConnectivity,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // حقل Device ID
            TextField(
              controller: _deviceIDController,
              decoration: InputDecoration(
                labelText: l10n.deviceID,
                hintText: 'device_001',
                prefixIcon: const Icon(Icons.devices),
              ),
            ),
            const SizedBox(height: 16),
            
            // زر الحفظ
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF041E76),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l10n.save),
              ),
            ),
            const SizedBox(height: 16),
            
            // حالة الاتصال وزر الاتصال/قطع الاتصال
            Row(
              children: [
                Expanded(
                  child: _buildConnectionStatus(bleConnection, l10n),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: bleConnection == BleConnectionState.connected
                      ? () => ref.read(bleConnectionProvider.notifier).disconnect()
                      : () => ref.read(bleConnectionProvider.notifier).startScan(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bleConnection == BleConnectionState.connected
                        ? Colors.red
                        : Colors.green,
                  ),
                  child: Text(
                    bleConnection == BleConnectionState.connected
                        ? l10n.disconnect
                        : l10n.scan,
                  ),
                ),
              ],
            ),
            
            // قائمة الأجهزة المكتشفة
            if (scannedDevices.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Discovered Devices:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: scannedDevices.length,
                  itemBuilder: (context, index) {
                    final device = scannedDevices[index].device;
                    return ListTile(
                      leading: const Icon(Icons.bluetooth_connected),
                      title: Text(device.platformName.isNotEmpty 
                          ? device.platformName 
                          : 'Unknown Device'),
                      subtitle: Text(device.remoteId.toString()),
                      trailing: ElevatedButton(
                        onPressed: bleConnection == BleConnectionState.connected
                            ? null
                            : () => ref.read(bleConnectionProvider.notifier).connect(device),
                        child: const Text('Connect'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(BleConnectionState state, l10n) {
    Color color;
    String text;
    IconData icon;

    switch (state) {
      case BleConnectionState.connected:
        color = Colors.green;
        text = l10n.connected;
        icon = Icons.check_circle;
        break;
      case BleConnectionState.connecting:
      case BleConnectionState.scanning:
        color = Colors.orange;
        text = state == BleConnectionState.scanning ? 'Scanning...' : l10n.connecting;
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    final settings = ref.read(settingsProvider);
    if (settings != null) {
      await ref.read(settingsProvider.notifier).updateSettings(
            settings.copyWith(
              deviceID: _deviceIDController.text,
            ),
          );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
      }
    }
  }
}
