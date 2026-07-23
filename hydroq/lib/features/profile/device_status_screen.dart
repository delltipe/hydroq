import 'package:flutter/material.dart';

import '../../core/models/models.dart';
import '../../core/state/hydroq_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class DeviceStatusScreen extends StatelessWidget {
  const DeviceStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HydroQController controller = HydroQScope.of(context);
    final DeviceInfo device = controller.device;

    return Scaffold(
      appBar: AppBar(title: const Text('Status perangkat')),
      body: SingleChildScrollView(
        child: ResponsivePage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (!controller.deviceConfigured) ...<Widget>[
                SurfaceCard(
                  radius: AppRadius.large,
                  backgroundColor: AppColors.informationSoft,
                  borderColor: AppColors.information.withValues(alpha: .22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(
                        Icons.sensors_off_outlined,
                        color: AppColors.information,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada perangkat terhubung',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pairing dan konfigurasi Wi-Fi dikelola backend. Setelah perangkat ditautkan, status sensor akan muncul di layar ini.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => controller.setDeviceConfigured(true),
                        icon: const Icon(Icons.developer_mode_rounded),
                        label: const Text('Aktifkan perangkat demo'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Opacity(
                opacity: controller.deviceConfigured ? 1 : .45,
                child: IgnorePointer(
                  ignoring: !controller.deviceConfigured,
                  child: SurfaceCard(
                    radius: AppRadius.large,
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: device.online
                                ? AppColors.successSoft
                                : AppColors.offlineSoft,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.router_rounded,
                            size: 36,
                            color: device.online
                                ? AppColors.success
                                : AppColors.offline,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          device.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        DeviceStatusPill(online: device.online),
                        const SizedBox(height: 20),
                        const Divider(),
                        InfoRow(
                          icon: Icons.qr_code_2_rounded,
                          label: 'Nomor seri',
                          value: device.serialNumber,
                        ),
                        InfoRow(
                          icon: Icons.memory_rounded,
                          label: 'Firmware',
                          value: device.firmwareVersion,
                        ),
                        InfoRow(
                          icon: Icons.wifi_rounded,
                          label: 'Jaringan Wi-Fi',
                          value: device.wifiName,
                        ),
                        InfoRow(
                          icon: Icons.schedule_rounded,
                          label: 'Kontak terakhir',
                          value: relativeTime(device.lastSeen),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Ketersediaan sensor',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Opacity(
                opacity: controller.deviceConfigured ? 1 : .45,
                child: IgnorePointer(
                  ignoring: !controller.deviceConfigured,
                  child: SurfaceCard(
                    child: Column(
                      children: <Widget>[
                        _SensorRow(
                          name: 'Sensor pH',
                          available: device.phSensorAvailable,
                          icon: Icons.science_outlined,
                          onChanged: (bool value) =>
                              controller.setSensorAvailability(ph: value),
                        ),
                        const Divider(height: 1),
                        _SensorRow(
                          name: 'Sensor EC',
                          available: device.ecSensorAvailable,
                          icon: Icons.grain_rounded,
                          onChanged: (bool value) =>
                              controller.setSensorAvailability(ec: value),
                        ),
                        const Divider(height: 1),
                        _SensorRow(
                          name: 'Sensor ultrasonik',
                          available: device.levelSensorAvailable,
                          icon: Icons.sensors_rounded,
                          onChanged: (bool value) =>
                              controller.setSensorAvailability(level: value),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SurfaceCard(
                backgroundColor: AppColors.informationSoft,
                borderColor: AppColors.information.withValues(alpha: .2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(
                      Icons.developer_mode_rounded,
                      color: AppColors.information,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Kontrol di bawah hanya tersedia pada mode demo untuk menguji tampilan offline, kegagalan sensor parsial, dan pemulihan.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: controller.deviceConfigured
                    ? () => controller.setDemoDeviceState(
                          online: !device.online,
                        )
                    : null,
                icon: Icon(
                  device.online
                      ? Icons.cloud_off_outlined
                      : Icons.cloud_done_outlined,
                ),
                label: Text(
                  device.online
                      ? 'Simulasikan perangkat offline'
                      : 'Sambungkan kembali perangkat',
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: controller.deviceConfigured && device.online
                    ? () => controller.setDemoStaleState(
                          stale: controller.snapshot.overallState != ReadingState.stale,
                        )
                    : null,
                icon: Icon(
                  controller.snapshot.overallState == ReadingState.stale
                      ? Icons.update_rounded
                      : Icons.schedule_rounded,
                ),
                label: Text(
                  controller.snapshot.overallState == ReadingState.stale
                      ? 'Pulihkan pembaruan realtime'
                      : 'Simulasikan data terlambat',
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => controller.setDeviceConfigured(
                  !controller.deviceConfigured,
                ),
                icon: Icon(
                  controller.deviceConfigured
                      ? Icons.link_off_rounded
                      : Icons.link_rounded,
                ),
                label: Text(
                  controller.deviceConfigured
                      ? 'Simulasikan akun tanpa perangkat'
                      : 'Aktifkan perangkat demo',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SensorRow extends StatelessWidget {
  const _SensorRow({
    required this.name,
    required this.available,
    required this.icon,
    required this.onChanged,
  });

  final String name;
  final bool available;
  final IconData icon;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: <Widget>[
          Icon(icon, color: AppColors.green700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Switch(value: available, onChanged: onChanged),
        ],
      ),
    );
  }
}
