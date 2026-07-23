import 'package:flutter/material.dart';

import '../../core/models/models.dart';
import '../../core/state/hydroq_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class AlertHistoryScreen extends StatefulWidget {
  const AlertHistoryScreen({super.key});

  @override
  State<AlertHistoryScreen> createState() => _AlertHistoryScreenState();
}

class _AlertHistoryScreenState extends State<AlertHistoryScreen> {
  String _filter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final HydroQController controller = HydroQScope.of(context);
    final List<AlertEvent> alerts = controller.alerts.where((AlertEvent alert) {
      if (_filter == 'Aktif') return !alert.resolved;
      if (_filter == 'Pulih') return alert.resolved;
      return true;
    }).toList()..sort((AlertEvent a, AlertEvent b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat peringatan')),
      body: ResponsivePage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Wrap(
              spacing: 8,
              children: <String>['Semua', 'Aktif', 'Pulih'].map((String label) {
                final bool selected = _filter == label;
                return ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: AppColors.green50,
                  side: BorderSide(color: selected ? AppColors.green200 : AppColors.neutral200),
                  onSelected: (_) => setState(() => _filter = label),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (alerts.isEmpty)
              const Expanded(
                child: EmptyState(
                  icon: Icons.notifications_off_outlined,
                  title: 'Tidak ada peringatan',
                  message: 'Belum ada kejadian yang sesuai dengan filter ini.',
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: alerts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    return _AlertCard(alert: alerts[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});

  final AlertEvent alert;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: alert.state.softColor, borderRadius: BorderRadius.circular(14)),
                child: Icon(alert.state.icon, color: alert.state.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(alert.title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(alert.message, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              StatusBadge(state: alert.state, compact: true),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neutral50,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Column(
              children: <Widget>[
                _Detail(label: 'Parameter', value: alert.metric),
                _Detail(label: 'Nilai', value: alert.valueText),
                if (alert.targetRange != null) _Detail(label: 'Target saat kejadian', value: alert.targetRange!),
                _Detail(label: 'Mulai', value: _dateTime(alert.createdAt)),
                _Detail(
                  label: 'Selesai',
                  value: alert.endedAt == null ? 'Sedang berlangsung' : _dateTime(alert.endedAt!),
                ),
                _Detail(
                  label: 'Durasi',
                  value: alert.durationMinutes == null
                      ? alert.resolved ? 'Tidak tersedia' : 'Berlangsung'
                      : '${alert.durationMinutes} menit',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _dateTime(DateTime value) {
    final String day = value.day.toString().padLeft(2, '0');
    final String month = value.month.toString().padLeft(2, '0');
    final String hour = value.hour.toString().padLeft(2, '0');
    final String minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} · $hour:$minute';
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
          Text(value, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.neutral800)),
        ],
      ),
    );
  }
}
