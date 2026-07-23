import 'package:flutter/material.dart';

import '../../core/models/models.dart';
import '../../core/state/hydroq_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  late NotificationPreferences _preferences;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _preferences = HydroQScope.read(context).notificationPreferences;
      _initialized = true;
    }
  }

  void _save() {
    HydroQScope.read(context).updateNotificationPreferences(_preferences);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferensi notifikasi disimpan.')));
    Navigator.of(context).pop();
  }

  void _toggleAll(bool value) {
    setState(() {
      _preferences = NotificationPreferences(
        allEnabled: value,
        phEnabled: value,
        ecEnabled: value,
        volumeEnabled: value,
        recoveryEnabled: value,
        deviceOfflineEnabled: value,
      );
    });
  }

  NotificationPreferences _withCategory(NotificationPreferences next) {
    final bool anyEnabled = next.phEnabled || next.ecEnabled || next.volumeEnabled || next.recoveryEnabled || next.deviceOfflineEnabled;
    return next.copyWith(allEnabled: anyEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan notifikasi')),
      body: SingleChildScrollView(
        child: ResponsivePage(
          maxWidth: 620,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SurfaceCard(
                backgroundColor: AppColors.green50,
                borderColor: AppColors.green100,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(Icons.notifications_active_outlined, color: AppColors.green700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'HydroQ tetap dapat digunakan jika izin push ditolak. Logika severity, persistensi, dan deduplikasi tetap dikelola backend.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.green800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SurfaceCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: <Widget>[
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_rounded, color: AppColors.green700),
                      title: const Text('Semua push notification'),
                      subtitle: const Text('Aktifkan atau nonaktifkan seluruh kategori sekaligus.'),
                      value: _preferences.allEnabled,
                      onChanged: _toggleAll,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.science_outlined, color: AppColors.green700),
                      title: const Text('pH'),
                      subtitle: const Text('Warning, critical, dan perubahan penting pada pH.'),
                      value: _preferences.phEnabled,
                      onChanged: _preferences.allEnabled
                          ? (bool value) => setState(() => _preferences = _withCategory(_preferences.copyWith(phEnabled: value)))
                          : null,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.grain_rounded, color: AppColors.green700),
                      title: const Text('EC / TDS'),
                      subtitle: const Text('Perubahan konsentrasi nutrisi yang memerlukan perhatian.'),
                      value: _preferences.ecEnabled,
                      onChanged: _preferences.allEnabled
                          ? (bool value) => setState(() => _preferences = _withCategory(_preferences.copyWith(ecEnabled: value)))
                          : null,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.water_drop_outlined, color: AppColors.green700),
                      title: const Text('Volume air'),
                      subtitle: const Text('Saat volume mendekati atau melewati batas minimum.'),
                      value: _preferences.volumeEnabled,
                      onChanged: _preferences.allEnabled
                          ? (bool value) => setState(() => _preferences = _withCategory(_preferences.copyWith(volumeEnabled: value)))
                          : null,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
                      title: const Text('Kondisi kembali normal'),
                      subtitle: const Text('Satu pemberitahuan ketika kondisi kembali stabil.'),
                      value: _preferences.recoveryEnabled,
                      onChanged: _preferences.allEnabled
                          ? (bool value) => setState(() => _preferences = _withCategory(_preferences.copyWith(recoveryEnabled: value)))
                          : null,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.cloud_off_outlined, color: AppColors.offline),
                      title: const Text('Perangkat offline'),
                      subtitle: const Text('Saat HydroQ Hub berhenti mengirim data.'),
                      value: _preferences.deviceOfflineEnabled,
                      onChanged: _preferences.allEnabled
                          ? (bool value) => setState(() => _preferences = _withCategory(_preferences.copyWith(deviceOfflineEnabled: value)))
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const SurfaceCard(
                backgroundColor: AppColors.neutral50,
                child: InfoRow(
                  icon: Icons.verified_user_outlined,
                  label: 'Izin sistem',
                  value: 'Mode demo · belum diminta',
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save_outlined), label: const Text('Simpan preferensi')),
            ],
          ),
        ),
      ),
    );
  }
}
