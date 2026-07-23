import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/models.dart';
import '../../core/state/hydroq_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class TankSettingsScreen extends StatefulWidget {
  const TankSettingsScreen({super.key});

  @override
  State<TankSettingsScreen> createState() => _TankSettingsScreenState();
}

class _TankSettingsScreenState extends State<TankSettingsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _capacityController;
  late final TextEditingController _heightController;
  late final TextEditingController _minimumController;
  bool _controllersInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_controllersInitialized) {
      final TankConfiguration tank = HydroQScope.read(context).tank;
      _nameController = TextEditingController(text: tank.name);
      _capacityController = TextEditingController(text: tank.capacityLiters.toStringAsFixed(0));
      _heightController = TextEditingController(text: tank.heightCm.toStringAsFixed(0));
      _minimumController = TextEditingController(text: tank.minimumSafeVolumeLiters.toStringAsFixed(0));
      _controllersInitialized = true;
    }
  }

  @override
  void dispose() {
    if (_controllersInitialized) {
      _nameController.dispose();
      _capacityController.dispose();
      _heightController.dispose();
      _minimumController.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final double capacity = double.parse(_capacityController.text);
    final double minimum = double.parse(_minimumController.text);
    if (minimum > capacity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Volume minimum aman tidak boleh melebihi kapasitas tangki.')),
      );
      return;
    }
    final CustomRecipe? activeRecipe = HydroQScope.read(context).activeRecipe;
    if (activeRecipe != null && activeRecipe.minimumVolumeLiters > capacity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kapasitas tangki harus minimal ${activeRecipe.minimumVolumeLiters.toStringAsFixed(1)} L '
            'karena resep aktif memakai batas volume tersebut.',
          ),
        ),
      );
      return;
    }
    final TankConfiguration configuration = TankConfiguration(
      name: _nameController.text.trim(),
      capacityLiters: capacity,
      heightCm: double.parse(_heightController.text),
      minimumSafeVolumeLiters: minimum,
    );
    HydroQScope.read(context).updateTank(configuration);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengaturan tangki disimpan.')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final List<TextInputFormatter> decimal = <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan tangki')),
      body: SingleChildScrollView(
        child: ResponsivePage(
          maxWidth: 560,
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
                      const Icon(Icons.straighten_rounded, color: AppColors.green700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Kapasitas dan tinggi tangki digunakan untuk mengubah jarak sensor ultrasonik menjadi liter dan persentase.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.green800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama tangki', prefixIcon: Icon(Icons.water_outlined)),
                  validator: (String? value) => (value ?? '').trim().isEmpty ? 'Nama tangki wajib diisi.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _capacityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: decimal,
                  decoration: const InputDecoration(labelText: 'Kapasitas maksimum', suffixText: 'L'),
                  validator: (String? value) {
                    final double? number = double.tryParse(value ?? '');
                    if (number == null || number <= 0 || number > 5000) return 'Masukkan kapasitas 1–5000 liter.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _heightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: decimal,
                  decoration: const InputDecoration(labelText: 'Tinggi tangki', suffixText: 'cm'),
                  validator: (String? value) {
                    final double? number = double.tryParse(value ?? '');
                    if (number == null || number <= 0 || number > 500) return 'Masukkan tinggi 1–500 cm.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _minimumController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: decimal,
                  decoration: const InputDecoration(labelText: 'Volume minimum aman', suffixText: 'L'),
                  validator: (String? value) {
                    final double? number = double.tryParse(value ?? '');
                    if (number == null || number <= 0 || number > 5000) return 'Masukkan volume minimum yang valid.';
                    final double? capacity = double.tryParse(_capacityController.text);
                    if (capacity != null && number > capacity) return 'Tidak boleh melebihi kapasitas tangki.';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save_outlined), label: const Text('Simpan perubahan')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
