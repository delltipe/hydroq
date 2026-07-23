import 'package:flutter/material.dart';

import '../../core/models/models.dart';
import '../../core/state/hydroq_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/plant_art.dart';
import '../recipes/recipe_screens.dart';

class PlantDetailScreen extends StatelessWidget {
  const PlantDetailScreen({super.key, required this.plant});

  final PlantProfile plant;

  @override
  Widget build(BuildContext context) {
    final HydroQController controller = HydroQScope.of(context);
    final bool active = controller.activePlant?.id == plant.id;

    return Scaffold(
      appBar: AppBar(title: Text(plant.name)),
      body: SingleChildScrollView(
        child: ResponsivePage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SurfaceCard(
                radius: AppRadius.large,
                backgroundColor: AppColors.green50,
                borderColor: AppColors.green100,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final Widget art = PlantArt(seed: plant.artSeed, size: constraints.maxWidth < 480 ? 180 : 220);
                    final Widget text = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(plant.category, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.green700)),
                        const SizedBox(height: 6),
                        Text(plant.name, style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 10),
                        Text(plant.description, style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            _InfoChip(icon: Icons.speed_rounded, text: plant.difficulty),
                            _InfoChip(icon: Icons.calendar_today_outlined, text: '${plant.daysToHarvest} hari'),
                          ],
                        ),
                      ],
                    );
                    if (constraints.maxWidth < 560) {
                      return Column(children: <Widget>[art, const SizedBox(height: 12), text]);
                    }
                    return Row(
                      children: <Widget>[
                        art,
                        const SizedBox(width: 24),
                        Expanded(child: text),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text('Rentang air ideal', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final List<Widget> cards = <Widget>[
                    _RangeCard(
                      icon: Icons.science_outlined,
                      label: 'pH',
                      value: '${plant.phMin.toStringAsFixed(1)}–${plant.phMax.toStringAsFixed(1)}',
                      note: 'Keasaman larutan',
                    ),
                    _RangeCard(
                      icon: Icons.grain_rounded,
                      label: 'EC',
                      value: '${plant.ecMin.toStringAsFixed(1)}–${plant.ecMax.toStringAsFixed(1)}',
                      note: 'mS/cm',
                    ),
                    _RangeCard(
                      icon: Icons.water_drop_outlined,
                      label: 'TDS',
                      value: '${plant.tdsMin}–${plant.tdsMax}',
                      note: 'ppm estimasi',
                    ),
                    _RangeCard(
                      icon: Icons.thermostat_outlined,
                      label: 'Suhu air',
                      value: '${plant.waterTempMin.toStringAsFixed(0)}–${plant.waterTempMax.toStringAsFixed(0)}°C',
                      note: 'Rentang rekomendasi',
                    ),
                  ];
                  if (constraints.maxWidth < 560) {
                    return Column(
                      children: cards.map((Widget card) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: card,
                      )).toList(),
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: cards.expand((Widget card) sync* {
                      yield Expanded(child: card);
                      if (card != cards.last) yield const SizedBox(width: 12);
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              _GuidanceSection(title: 'Tips nutrisi', icon: Icons.opacity_rounded, items: plant.nutritionTips),
              const SizedBox(height: 14),
              _GuidanceSection(title: 'Perawatan', icon: Icons.eco_outlined, items: plant.careTips),
              const SizedBox(height: 14),
              _GuidanceSection(title: 'Masalah umum', icon: Icons.troubleshoot_rounded, items: plant.commonProblems),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: active
                    ? null
                    : () => _confirmApply(context, controller),
                icon: Icon(active ? Icons.check_rounded : Icons.playlist_add_check_rounded),
                label: Text(active ? 'Profil sedang digunakan' : 'Gunakan profil ini'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  final CustomRecipe recipe = controller.copyPlantAsRecipe(plant);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => RecipeFormScreen(existing: recipe)),
                  );
                },
                icon: const Icon(Icons.copy_all_outlined),
                label: const Text('Salin sebagai resep kustom'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmApply(BuildContext context, HydroQController controller) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Gunakan profil tanaman?'),
        content: Text(
          'Profil ${plant.name} akan diterapkan pada ${controller.tank.name}. Target pH dan EC di Beranda akan diperbarui.',
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Gunakan profil')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    controller.applyPlantProfile(plant);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profil ${plant.name} aktif untuk ${controller.tank.name}.')),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: AppColors.green700),
          const SizedBox(width: 6),
          Text(text, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _RangeCard extends StatelessWidget {
  const _RangeCard({required this.icon, required this.label, required this.value, required this.note});

  final IconData icon;
  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: AppColors.green700),
          const SizedBox(height: 12),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 3),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(note, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _GuidanceSection extends StatelessWidget {
  const _GuidanceSection({required this.title, required this.icon, required this.items});

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: AppColors.green700),
              const SizedBox(width: 10),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((String item) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(top: 7),
                      child: CircleAvatar(radius: 3, backgroundColor: AppColors.green500),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item, style: Theme.of(context).textTheme.bodyMedium)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
