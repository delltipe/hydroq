import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/models/models.dart';
import '../../core/state/hydroq_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/plant_art.dart';
import 'plant_detail_screen.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HydroQController controller = HydroQScope.of(context);
    final List<PlantProfile> filtered = controller.plants.where((PlantProfile plant) {
      final String query = _query.toLowerCase().trim();
      return query.isEmpty ||
          plant.name.toLowerCase().contains(query) ||
          plant.category.toLowerCase().contains(query) ||
          plant.aliases.any((String alias) => alias.toLowerCase().contains(query));
    }).toList();

    return CustomScrollView(
      key: const PageStorageKey<String>('education-scroll'),
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Edukasi', style: Theme.of(context).textTheme.titleMedium),
              Text('Kenali kebutuhan tanaman hidroponik', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: ResponsivePage(
            maxWidth: 980,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextField(
                  controller: _searchController,
                  onChanged: (String value) {
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 280), () {
                      if (mounted) setState(() => _query = value);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari tanaman...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Hapus pencarian',
                            onPressed: () {
                              _debounce?.cancel();
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                SectionHeader(
                  title: _query.isEmpty ? 'Tanaman hidroponik' : 'Hasil pencarian',
                  subtitle: '${filtered.length} tanaman tersedia',
                ),
                const SizedBox(height: 14),
                if (filtered.isEmpty)
                  const SizedBox(
                    height: 380,
                    child: EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Tanaman tidak ditemukan',
                      message: 'Coba gunakan kata pencarian lain.',
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      int columns = 2;
                      if (constraints.maxWidth >= 820) columns = 4;
                      if (constraints.maxWidth >= 560 && constraints.maxWidth < 820) columns = 3;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: columns == 2 ? 286 : 270,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return _PlantCard(plant: filtered[index]);
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlantCard extends StatelessWidget {
  const _PlantCard({required this.plant});

  final PlantProfile plant;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${plant.name}, pH ${plant.phMin} sampai ${plant.phMax}, EC ${plant.ecMin} sampai ${plant.ecMax}',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => PlantDetailScreen(plant: plant)),
        ),
        child: SurfaceCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: PlantArt(seed: plant.artSeed, size: 145),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(plant.name, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(plant.difficulty, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.green700)),
              const SizedBox(height: 10),
              Text('pH ${plant.phMin.toStringAsFixed(1)}–${plant.phMax.toStringAsFixed(1)}', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 3),
              Text('EC ${plant.ecMin.toStringAsFixed(1)}–${plant.ecMax.toStringAsFixed(1)}', style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}
