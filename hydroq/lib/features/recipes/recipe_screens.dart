import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/models.dart';
import '../../core/state/hydroq_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HydroQController controller = HydroQScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Resep kustom')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const RecipeFormScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Buat resep'),
      ),
      body: ResponsivePage(
        child: controller.recipes.isEmpty
            ? EmptyState(
                icon: Icons.tune_rounded,
                title: 'Belum ada resep kustom',
                message: 'Buat batas pH, EC, volume, dan aturan peringatan sesuai kebutuhan kebunmu.',
                actionLabel: 'Buat resep pertama',
                onAction: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const RecipeFormScreen()),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.only(bottom: 96),
                itemCount: controller.recipes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (BuildContext context, int index) {
                  return _RecipeCard(recipe: controller.recipes[index]);
                },
              ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe});

  final CustomRecipe recipe;

  @override
  Widget build(BuildContext context) {
    final HydroQController controller = HydroQScope.read(context);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(recipe.name, style: Theme.of(context).textTheme.titleMedium)),
              if (recipe.active) const StatusBadge(state: ReadingState.normal, compact: true),
              PopupMenuButton<String>(
                tooltip: 'Menu resep',
                onSelected: (String value) {
                  if (value == 'edit') {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => RecipeFormScreen(existing: recipe)),
                    );
                  } else if (value == 'delete') {
                    _confirmDelete(context, controller);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(value: 'edit', child: Text('Edit resep')),
                  PopupMenuItem<String>(
                    value: 'delete',
                    enabled: !recipe.active,
                    child: Text(recipe.active ? 'Nonaktifkan sebelum menghapus' : 'Hapus resep'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _RecipeValue(label: 'pH', value: '${recipe.phMin.toStringAsFixed(1)}–${recipe.phMax.toStringAsFixed(1)}'),
              _RecipeValue(label: 'EC', value: '${recipe.ecMin.toStringAsFixed(1)}–${recipe.ecMax.toStringAsFixed(1)}'),
              _RecipeValue(label: 'Volume min.', value: '${recipe.minimumVolumeLiters.toStringAsFixed(1)} L'),
              _RecipeValue(label: 'Margin warning', value: '${recipe.warningMarginPercent}%'),
              _RecipeValue(label: 'Persistensi', value: '${recipe.persistenceMinutes} mnt'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: recipe.active
                ? OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Resep sedang aktif'),
                  )
                : FilledButton.icon(
                    onPressed: () {
                      controller.activateRecipe(recipe);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${recipe.name} sekarang aktif.')),
                      );
                    },
                    icon: const Icon(Icons.playlist_add_check_rounded),
                    label: const Text('Gunakan resep'),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, HydroQController controller) async {
    if (recipe.active) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resep aktif tidak dapat dihapus. Aktifkan profil atau resep lain terlebih dahulu.')),
      );
      return;
    }
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Hapus resep?'),
        content: Text('${recipe.name} akan dihapus permanen dari perangkat ini.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.critical),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      controller.deleteRecipe(recipe.id);
    }
  }
}

class _RecipeValue extends StatelessWidget {
  const _RecipeValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: AppColors.neutral50, borderRadius: BorderRadius.circular(AppRadius.small)),
      child: Text('$label $value', style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class RecipeFormScreen extends StatefulWidget {
  const RecipeFormScreen({super.key, this.existing});

  final CustomRecipe? existing;

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phMin;
  late final TextEditingController _phMax;
  late final TextEditingController _ecMin;
  late final TextEditingController _ecMax;
  late final TextEditingController _volume;
  late final TextEditingController _warningMargin;
  late final TextEditingController _persistence;
  late final String _initialSignature;
  bool _saved = false;

  Iterable<TextEditingController> get _controllers => <TextEditingController>[
        _name,
        _phMin,
        _phMax,
        _ecMin,
        _ecMax,
        _volume,
        _warningMargin,
        _persistence,
      ];

  String get _signature => _controllers.map((TextEditingController controller) => controller.text).join('|');

  @override
  void initState() {
    super.initState();
    final CustomRecipe? recipe = widget.existing;
    _name = TextEditingController(text: recipe?.name ?? 'Resep Baru');
    _phMin = TextEditingController(text: recipe?.phMin.toStringAsFixed(1) ?? '5.5');
    _phMax = TextEditingController(text: recipe?.phMax.toStringAsFixed(1) ?? '6.5');
    _ecMin = TextEditingController(text: recipe?.ecMin.toStringAsFixed(1) ?? '1.2');
    _ecMax = TextEditingController(text: recipe?.ecMax.toStringAsFixed(1) ?? '1.8');
    _volume = TextEditingController(text: recipe?.minimumVolumeLiters.toStringAsFixed(1) ?? '18');
    _warningMargin = TextEditingController(text: recipe?.warningMarginPercent.toString() ?? '10');
    _persistence = TextEditingController(text: recipe?.persistenceMinutes.toString() ?? '3');
    _initialSignature = _signature;
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _requiredNumber(String? value, {required double min, required double max, required String label}) {
    final double? number = double.tryParse(value ?? '');
    if (number == null) return '$label harus berupa angka.';
    if (number < min || number > max) return '$label harus berada di rentang $min–$max.';
    return null;
  }

  Future<bool> _confirmDiscard() async {
    if (_saved || _signature == _initialSignature) return true;
    final bool? discard = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Buang perubahan?'),
        content: const Text('Perubahan resep belum disimpan.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Lanjut mengedit')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Buang perubahan')),
        ],
      ),
    );
    return discard == true;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final double phMin = double.parse(_phMin.text);
    final double phMax = double.parse(_phMax.text);
    final double ecMin = double.parse(_ecMin.text);
    final double ecMax = double.parse(_ecMax.text);
    final double volume = double.parse(_volume.text);
    final HydroQController controller = HydroQScope.read(context);
    if (phMin >= phMax) {
      _showError('Batas minimum pH harus lebih kecil dari batas maksimum.');
      return;
    }
    if (ecMin >= ecMax) {
      _showError('Batas minimum EC harus lebih kecil dari batas maksimum.');
      return;
    }
    if (volume > controller.tank.capacityLiters) {
      _showError('Volume minimum tidak boleh melebihi kapasitas tangki ${controller.tank.capacityLiters.toStringAsFixed(1)} L.');
      return;
    }
    final CustomRecipe recipe = CustomRecipe(
      id: widget.existing?.id ?? 'recipe-${DateTime.now().millisecondsSinceEpoch}',
      name: _name.text.trim(),
      phMin: phMin,
      phMax: phMax,
      ecMin: ecMin,
      ecMax: ecMax,
      minimumVolumeLiters: volume,
      warningMarginPercent: int.parse(_warningMargin.text),
      persistenceMinutes: int.parse(_persistence.text),
      sourcePlantId: widget.existing?.sourcePlantId,
      active: widget.existing?.active ?? false,
    );
    controller.saveRecipe(recipe);
    _saved = true;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resep berhasil disimpan.')));
    Navigator.of(context).pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final List<TextInputFormatter> decimalFormat = <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
    ];
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) async {
        if (didPop) return;
        final bool shouldPop = await _confirmDiscard();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.existing == null ? 'Buat resep' : 'Edit resep')),
        body: SingleChildScrollView(
          child: ResponsivePage(
            maxWidth: 620,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SurfaceCard(
                    backgroundColor: AppColors.green50,
                    borderColor: AppColors.green100,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Icon(Icons.tune_rounded, color: AppColors.green700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Resep kustom menggantikan target profil tanaman sampai kamu memilih profil lain.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.green800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Nama resep'),
                    validator: (String? value) {
                      final String name = value?.trim() ?? '';
                      if (name.length < 3) return 'Nama resep minimal 3 karakter.';
                      if (name.length > 40) return 'Nama resep maksimal 40 karakter.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('Rentang pH', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 10),
                  _ResponsiveFieldPair(
                    first: TextFormField(
                      controller: _phMin,
                      inputFormatters: decimalFormat,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Minimum'),
                      validator: (String? value) => _requiredNumber(value, min: 0, max: 14, label: 'pH minimum'),
                    ),
                    second: TextFormField(
                      controller: _phMax,
                      inputFormatters: decimalFormat,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Maksimum'),
                      validator: (String? value) => _requiredNumber(value, min: 0, max: 14, label: 'pH maksimum'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Rentang EC', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 10),
                  _ResponsiveFieldPair(
                    first: TextFormField(
                      controller: _ecMin,
                      inputFormatters: decimalFormat,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Minimum', suffixText: 'mS/cm'),
                      validator: (String? value) => _requiredNumber(value, min: 0, max: 10, label: 'EC minimum'),
                    ),
                    second: TextFormField(
                      controller: _ecMax,
                      inputFormatters: decimalFormat,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Maksimum', suffixText: 'mS/cm'),
                      validator: (String? value) => _requiredNumber(value, min: 0, max: 10, label: 'EC maksimum'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _volume,
                    inputFormatters: decimalFormat,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Volume minimum aman', suffixText: 'L'),
                    validator: (String? value) => _requiredNumber(value, min: 1, max: 5000, label: 'Volume minimum'),
                  ),
                  const SizedBox(height: 16),
                  _ResponsiveFieldPair(
                    first: TextFormField(
                      controller: _warningMargin,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Margin warning', suffixText: '%'),
                      validator: (String? value) {
                        final int? number = int.tryParse(value ?? '');
                        if (number == null || number < 1 || number > 50) return 'Margin warning harus 1–50%.';
                        return null;
                      },
                    ),
                    second: TextFormField(
                      controller: _persistence,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Persistensi alert', suffixText: 'menit'),
                      validator: (String? value) {
                        final int? number = int.tryParse(value ?? '');
                        if (number == null || number < 1 || number > 60) return 'Persistensi harus 1–60 menit.';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save_outlined), label: const Text('Simpan resep')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResponsiveFieldPair extends StatelessWidget {
  const _ResponsiveFieldPair({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 420) {
          return Column(children: <Widget>[first, const SizedBox(height: 12), second]);
        }
        return Row(children: <Widget>[Expanded(child: first), const SizedBox(width: 12), Expanded(child: second)]);
      },
    );
  }
}
