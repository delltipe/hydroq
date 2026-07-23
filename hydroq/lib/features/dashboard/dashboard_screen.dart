import 'package:flutter/material.dart';

import '../../core/models/models.dart';
import '../../core/state/hydroq_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/line_chart.dart';
import '../alerts/alert_history_screen.dart';
import '../profile/device_status_screen.dart';
import '../reports/report_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ReportMetric _metric = ReportMetric.ph;
  ReportPeriod _period = ReportPeriod.daily;

  @override
  Widget build(BuildContext context) {
    final HydroQController controller = HydroQScope.of(context);
    final SensorSnapshot snapshot = controller.snapshot;
    final ReportSummary report = controller.getReport(_metric, _period);
    final MetricReading target = _targetFor(snapshot, _metric);

    return RefreshIndicator(
      onRefresh: controller.refreshNow,
      child: CustomScrollView(
        key: const PageStorageKey<String>('dashboard-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(controller.tank.name, style: Theme.of(context).textTheme.titleMedium),
                Text(controller.activeProfileLabel, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            actions: <Widget>[
              IconButton(
                tooltip: 'Perbarui data',
                onPressed: controller.isRefreshing ? null : controller.refreshNow,
                icon: controller.isRefreshing
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
              ),
              IconButton(
                tooltip: 'Riwayat peringatan',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const AlertHistoryScreen()),
                ),
                icon: Badge(
                  label: Text('${controller.alerts.where((AlertEvent alert) => !alert.resolved).length}'),
                  child: const Icon(Icons.notifications_none_rounded),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
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
                          const Icon(Icons.sensors_off_outlined, color: AppColors.information, size: 30),
                          const SizedBox(height: 12),
                          Text('Perangkat belum dikonfigurasi', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 6),
                          Text(
                            'Monitoring belum tersedia untuk akun ini. Hubungkan perangkat melalui proses backend, lalu periksa statusnya di HydroQ.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(builder: (_) => const DeviceStatusScreen()),
                            ),
                            icon: const Icon(Icons.router_outlined),
                            label: const Text('Lihat status perangkat'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  _StatusHeader(snapshot: snapshot, configured: controller.deviceConfigured),
                  const SizedBox(height: 20),
                  _WaterConditionCard(snapshot: snapshot, configured: controller.deviceConfigured),
                  const SizedBox(height: 28),
                  SectionHeader(
                    title: 'Laporan kondisi air',
                    subtitle: 'Bandingkan pH, nutrisi, dan volume dalam satu grafik.',
                    actionLabel: 'Lihat lengkap',
                    onAction: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const ReportScreen()),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _ReportSelector<ReportMetric>(
                          values: ReportMetric.values,
                          selected: _metric,
                          labelOf: (ReportMetric value) => value.label,
                          onSelected: (ReportMetric value) => setState(() => _metric = value),
                        ),
                        const SizedBox(height: 10),
                        _ReportSelector<ReportPeriod>(
                          values: ReportPeriod.values,
                          selected: _period,
                          labelOf: (ReportPeriod value) => value.label,
                          onSelected: (ReportPeriod value) => setState(() => _period = value),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: <Widget>[
                            StatusBadge(
                              state: report.criticalCount > 0
                                  ? ReadingState.critical
                                  : report.warningCount > 0
                                      ? ReadingState.warning
                                      : ReadingState.normal,
                              compact: true,
                            ),
                            const Spacer(),
                            Text(
                              'Rata-rata ${_format(report.average)}',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.neutral600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        HydroLineChart(
                          points: report.points,
                          metric: _metric,
                          minimumTarget: target.minimum,
                          maximumTarget: target.maximum,
                          height: 190,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: <Widget>[
                            _MiniStat(label: 'Minimum', value: _format(report.minimum)),
                            _MiniStat(label: 'Maksimum', value: _format(report.maximum)),
                            _MiniStat(label: 'Warning', value: '${report.warningCount}'),
                            _MiniStat(label: 'Critical', value: '${report.criticalCount}'),
                            _MiniStat(label: 'Tidak normal', value: '${report.abnormalDurationMinutes} mnt'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SectionHeader(
                    title: 'Peringatan terbaru',
                    subtitle: 'Kondisi yang memerlukan perhatian atau sudah pulih.',
                    actionLabel: 'Lihat semua',
                    onAction: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const AlertHistoryScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (controller.alerts.isEmpty)
                    const EmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: 'Belum ada peringatan',
                      message: 'Riwayat warning, critical, dan recovery akan tampil di sini.',
                    )
                  else
                    ...controller.alerts.take(4).map(
                          (AlertEvent alert) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _AlertPreview(alert: alert),
                          ),
                        ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  MetricReading _targetFor(SensorSnapshot snapshot, ReportMetric metric) {
    switch (metric) {
      case ReportMetric.ph:
        return snapshot.ph;
      case ReportMetric.ec:
        return snapshot.ec;
      case ReportMetric.volume:
        return snapshot.volume;
    }
  }

  String _format(double value) {
    final String suffix = _metric.unit.isEmpty ? '' : ' ${_metric.unit}';
    final int decimals = _metric == ReportMetric.ec ? 2 : 1;
    return '${value.toStringAsFixed(decimals)}$suffix';
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.snapshot, required this.configured});

  final SensorSnapshot snapshot;
  final bool configured;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runAlignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: <Widget>[
        DeviceStatusPill(online: configured && snapshot.deviceOnline),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.sync_rounded, size: 16, color: AppColors.neutral500),
            const SizedBox(width: 6),
            Text(
              configured ? 'Diperbarui ${relativeTime(snapshot.updatedAt)}' : 'Belum ada data perangkat',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

class _WaterConditionCard extends StatelessWidget {
  const _WaterConditionCard({required this.snapshot, required this.configured});

  final SensorSnapshot snapshot;
  final bool configured;

  @override
  Widget build(BuildContext context) {
    final ReadingState aggregateState = configured ? snapshot.overallState : ReadingState.unavailable;
    return SurfaceCard(
      radius: AppRadius.large,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Kondisi air saat ini', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 5),
                    Text(_statusMessage(aggregateState), style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              StatusBadge(state: aggregateState),
            ],
          ),
          if (configured && !snapshot.deviceOnline) ...<Widget>[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.offlineSoft, borderRadius: BorderRadius.circular(AppRadius.small)),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.cloud_off_outlined, color: AppColors.offline),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Nilai yang ditampilkan adalah data terakhir, bukan data live.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.neutral700),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final List<Widget> metrics = <Widget>[
                MetricTile(reading: configured ? snapshot.ph : _unavailable(snapshot.ph)),
                MetricTile(reading: configured ? snapshot.ec : _unavailable(snapshot.ec)),
                MetricTile(
                  reading: configured ? snapshot.volume : _unavailable(snapshot.volume),
                  volumePercent: configured ? snapshot.volumePercent : null,
                ),
              ];
              if (constraints.maxWidth < 540) {
                return Column(
                  children: metrics
                      .map((Widget metric) => Padding(padding: const EdgeInsets.only(bottom: 12), child: metric))
                      .toList(),
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: metrics[0]),
                  const SizedBox(width: 12),
                  Expanded(child: metrics[1]),
                  const SizedBox(width: 12),
                  Expanded(child: metrics[2]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  MetricReading _unavailable(MetricReading reading) {
    return MetricReading(
      label: reading.label,
      value: null,
      unit: reading.unit,
      minimum: reading.minimum,
      maximum: reading.maximum,
      state: ReadingState.unavailable,
      updatedAt: reading.updatedAt,
    );
  }

  String _statusMessage(ReadingState state) {
    switch (state) {
      case ReadingState.normal:
        return 'Semua parameter berada dalam rentang aman.';
      case ReadingState.warning:
        return 'Ada parameter yang mulai mendekati batas.';
      case ReadingState.critical:
        return 'Ada parameter di luar batas aman. Segera periksa tangki.';
      case ReadingState.stale:
        return 'Data belum diperbarui sesuai interval yang diharapkan.';
      case ReadingState.offline:
        return 'Perangkat sedang offline. Data terakhir tetap ditampilkan.';
      case ReadingState.incomplete:
        return 'Sebagian sensor belum mengirim data.';
      case ReadingState.unavailable:
        return 'Monitoring belum tersedia sampai perangkat dikonfigurasi.';
    }
  }
}

class _ReportSelector<T> extends StatelessWidget {
  const _ReportSelector({required this.values, required this.selected, required this.labelOf, required this.onSelected});

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
        final bool active = value == selected;
        return ChoiceChip(
          label: Text(labelOf(value)),
          selected: active,
          showCheckmark: false,
          onSelected: (_) => onSelected(value),
          selectedColor: AppColors.green50,
          side: BorderSide(color: active ? AppColors.green200 : AppColors.neutral200),
          labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: active ? AppColors.green700 : AppColors.neutral600,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
        );
      }).toList(),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(color: AppColors.neutral50, borderRadius: BorderRadius.circular(AppRadius.small)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('$label ', style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.neutral900)),
        ],
      ),
    );
  }
}

class _AlertPreview extends StatelessWidget {
  const _AlertPreview({required this.alert});

  final AlertEvent alert;

  @override
  Widget build(BuildContext context) {
    final String duration = alert.resolved
        ? alert.durationMinutes == null
            ? 'Pulih'
            : 'Pulih · ${alert.durationMinutes} menit'
        : alert.durationMinutes == null
            ? 'Sedang berlangsung'
            : '${alert.durationMinutes} menit · berlangsung';
    return SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: alert.state.softColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(alert.state.icon, color: alert.state.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(child: Text(alert.title, style: Theme.of(context).textTheme.titleSmall)),
                    StatusBadge(state: alert.state, compact: true),
                  ],
                ),
                const SizedBox(height: 4),
                Text(alert.message, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 7),
                Text(
                  '${alert.metric} · ${alert.valueText}${alert.targetRange == null ? '' : ' · target ${alert.targetRange}'}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: alert.state.color),
                ),
                const SizedBox(height: 3),
                Text('${relativeTime(alert.createdAt)} · $duration', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
