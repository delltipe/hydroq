import 'package:flutter/material.dart';

import '../../core/models/models.dart';
import '../../core/state/hydroq_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/line_chart.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  ReportMetric _metric = ReportMetric.ph;
  ReportPeriod _period = ReportPeriod.daily;

  @override
  Widget build(BuildContext context) {
    final HydroQController controller = HydroQScope.of(context);
    final ReportSummary report = controller.getReport(_metric, _period);
    final MetricReading target;
    switch (_metric) {
      case ReportMetric.ph:
        target = controller.snapshot.ph;
        break;
      case ReportMetric.ec:
        target = controller.snapshot.ec;
        break;
      case ReportMetric.volume:
        target = controller.snapshot.volume;
        break;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan lengkap')),
      body: SingleChildScrollView(
        child: ResponsivePage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Pilih parameter', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 10),
              _SelectionRow<ReportMetric>(
                values: ReportMetric.values,
                selected: _metric,
                labelOf: (ReportMetric value) => value.label,
                onSelected: (ReportMetric value) => setState(() => _metric = value),
              ),
              const SizedBox(height: 20),
              Text('Periode laporan', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 10),
              _SelectionRow<ReportPeriod>(
                values: ReportPeriod.values,
                selected: _period,
                labelOf: (ReportPeriod value) => value.label,
                onSelected: (ReportPeriod value) => setState(() => _period = value),
              ),
              const SizedBox(height: 24),
              SurfaceCard(
                radius: AppRadius.large,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(child: Text('Grafik ${_metric.label}', style: Theme.of(context).textTheme.titleLarge)),
                        Text(_period.label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.green700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Area hijau menunjukkan rentang target yang sedang aktif.', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 18),
                    HydroLineChart(
                      points: report.points,
                      metric: _metric,
                      minimumTarget: target.minimum,
                      maximumTarget: target.maximum,
                      height: 260,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final int columns = constraints.maxWidth >= 760 ? 4 : constraints.maxWidth >= 480 ? 3 : 2;
                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: columns >= 3 ? 1.18 : 1.42,
                    children: <Widget>[
                      _ReportStat(label: 'Rata-rata', value: _format(report.average), icon: Icons.analytics_outlined),
                      _ReportStat(label: 'Terendah', value: _format(report.minimum), icon: Icons.south_rounded),
                      _ReportStat(label: 'Tertinggi', value: _format(report.maximum), icon: Icons.north_rounded),
                      _ReportStat(label: 'Sampel', value: '${report.sampleCount}', icon: Icons.data_usage_rounded),
                      _ReportStat(label: 'Warning', value: '${report.warningCount}', icon: Icons.warning_amber_rounded),
                      _ReportStat(label: 'Critical', value: '${report.criticalCount}', icon: Icons.error_outline_rounded),
                      _ReportStat(label: 'Durasi abnormal', value: '${report.abnormalDurationMinutes} mnt', icon: Icons.timer_outlined),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              SurfaceCard(
                backgroundColor: AppColors.green50,
                borderColor: AppColors.green100,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(Icons.lightbulb_outline_rounded, color: AppColors.green700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _insight(report),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.green800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _format(double value) {
    final String suffix = _metric.unit.isEmpty ? '' : ' ${_metric.unit}';
    return '${value.toStringAsFixed(_metric == ReportMetric.ec ? 2 : 1)}$suffix';
  }

  String _insight(ReportSummary report) {
    if (report.criticalCount > 0) {
      return 'Terdapat kondisi kritis pada periode ini. Periksa riwayat peringatan untuk melihat waktu dan durasinya.';
    }
    if (report.warningCount > 0) {
      return 'Nilai sempat mendekati batas, tetapi sebagian besar data masih berada di sekitar rentang target.';
    }
    return 'Parameter stabil dan berada dalam rentang target sepanjang periode yang dipilih.';
  }
}

class _SelectionRow<T> extends StatelessWidget {
  const _SelectionRow({required this.values, required this.selected, required this.labelOf, required this.onSelected});

  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((T value) {
        final bool isSelected = value == selected;
        return ChoiceChip(
          label: Text(labelOf(value)),
          selected: isSelected,
          onSelected: (_) => onSelected(value),
          selectedColor: AppColors.green50,
          labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isSelected ? AppColors.green700 : AppColors.neutral600,
              ),
          side: BorderSide(color: isSelected ? AppColors.green200 : AppColors.neutral200),
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}

class _ReportStat extends StatelessWidget {
  const _ReportStat({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 20, color: AppColors.green700),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
