import 'package:flutter/material.dart';

import '../../core/state/hydroq_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../auth/login_screen.dart';
import '../notifications/notification_settings_screen.dart';
import '../recipes/recipe_screens.dart';
import 'device_status_screen.dart';
import 'tank_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HydroQController controller = HydroQScope.of(context);
    return CustomScrollView(
      key: const PageStorageKey<String>('profile-scroll'),
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          title: Text('Profil', style: Theme.of(context).textTheme.titleMedium),
        ),
        SliverToBoxAdapter(
          child: ResponsivePage(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SurfaceCard(
                  radius: AppRadius.large,
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(color: AppColors.green50, shape: BoxShape.circle),
                        child: const Icon(Icons.person_rounded, color: AppColors.green700, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(controller.userName, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 3),
                            Text(controller.userEmail, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit profil',
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pengeditan profil akan tersambung ke backend produksi.')),
                        ),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Kebun dan perangkat', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                SurfaceCard(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Column(
                    children: <Widget>[
                      _ProfileTile(
                        icon: Icons.water_outlined,
                        title: 'Pengaturan tangki',
                        subtitle: '${controller.tank.name} · ${controller.tank.capacityLiters.toStringAsFixed(0)} L',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const TankSettingsScreen()),
                        ),
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        icon: Icons.eco_outlined,
                        title: 'Profil aktif',
                        subtitle: controller.activeProfileLabel,
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pilih profil bawaan melalui Edukasi atau aktifkan resep kustom.')),
                        ),
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        icon: Icons.router_outlined,
                        title: 'Status perangkat',
                        subtitle: !controller.deviceConfigured
                            ? 'Belum ada perangkat terhubung'
                            : controller.device.online
                                ? 'HydroQ Hub online'
                                : 'HydroQ Hub offline',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const DeviceStatusScreen()),
                        ),
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        icon: Icons.tune_rounded,
                        title: 'Resep kustom',
                        subtitle: '${controller.recipes.length} resep tersimpan',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const RecipeListScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Preferensi', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                SurfaceCard(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Column(
                    children: <Widget>[
                      _ProfileTile(
                        icon: Icons.notifications_active_outlined,
                        title: 'Notifikasi',
                        subtitle: 'Atur pH, EC/TDS, volume, recovery, dan offline',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const NotificationSettingsScreen()),
                        ),
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        icon: Icons.straighten_rounded,
                        title: 'Satuan nutrisi',
                        subtitle: 'EC utama, TDS/ppm sebagai estimasi',
                        onTap: () => _showUnitInfo(context),
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        icon: Icons.lock_reset_rounded,
                        title: 'Ubah kata sandi',
                        subtitle: 'Tersedia setelah backend autentikasi terhubung',
                        onTap: () => _showPasswordInfo(context),
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        icon: Icons.info_outline_rounded,
                        title: 'Tentang HydroQ',
                        subtitle: 'Versi 1.0.0 · MVP demo',
                        onTap: () => showAboutDialog(
                          context: context,
                          applicationName: 'HydroQ',
                          applicationVersion: '1.0.0',
                          applicationLegalese: 'Monitoring air hidroponik yang jelas dan dapat dipercaya.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.critical,
                    side: const BorderSide(color: AppColors.critical),
                  ),
                  onPressed: () => _logout(context, controller),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Keluar akun'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPasswordInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Ubah kata sandi'),
        content: const Text(
          'Entry point sudah tersedia. Form perubahan kata sandi akan diaktifkan ketika endpoint autentikasi backend produksi tersambung.',
        ),
        actions: <Widget>[
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Mengerti')),
        ],
      ),
    );
  }

  void _showUnitInfo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Satuan nutrisi', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Text(
                'HydroQ menyimpan EC (mS/cm) sebagai nilai utama. TDS/ppm ditampilkan sebagai estimasi dengan faktor konversi 640.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, HydroQController controller) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Keluar dari HydroQ?'),
        content: const Text('Kamu harus masuk kembali untuk membuka dashboard.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Keluar')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    controller.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 12,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.green700, size: 21),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.neutral400),
      onTap: onTap,
    );
  }
}
