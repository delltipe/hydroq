import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    super.key,
    required this.child,
    this.maxWidth = 720,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double horizontal = constraints.maxWidth >= 600 ? 24 : 20;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: padding ?? EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.backgroundColor = AppColors.neutral0,
    this.borderColor = AppColors.neutral200,
    this.radius = AppRadius.medium,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.state, this.compact = false});

  final ReadingState state;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status ${state.label}',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: state.softColor,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(state.icon, size: compact ? 14 : 16, color: state.color),
            const SizedBox(width: 6),
            Text(
              compact ? state.shortLabel : state.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: state.color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceStatusPill extends StatelessWidget {
  const DeviceStatusPill({super.key, required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    final Color color = online ? AppColors.success : AppColors.offline;
    final Color background = online ? AppColors.successSoft : AppColors.offlineSoft;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            online ? 'Perangkat online' : 'Perangkat offline',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.reading,
    this.volumePercent,
  });

  final MetricReading reading;
  final int? volumePercent;

  @override
  Widget build(BuildContext context) {
    final bool unavailable = reading.value == null;
    return Semantics(
      label: '${reading.label}, ${reading.formattedValue} ${reading.unit}, status ${reading.state.label}',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.neutral25,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.neutral100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  reading.label == 'pH'
                      ? Icons.science_outlined
                      : reading.label == 'Volume'
                          ? Icons.water_drop_outlined
                          : Icons.grain_rounded,
                  size: 19,
                  color: reading.state.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reading.label,
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 5,
              children: <Widget>[
                Text(
                  reading.formattedValue,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                      ),
                ),
                if (reading.unit.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      reading.unit,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.neutral600,
                          ),
                    ),
                  ),
              ],
            ),
            if (reading.secondaryValue != null) ...<Widget>[
              const SizedBox(height: 2),
              Text(reading.secondaryValue!, style: Theme.of(context).textTheme.bodySmall),
            ],
            if (volumePercent != null) ...<Widget>[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: volumePercent!.clamp(0, 100) / 100,
                  backgroundColor: AppColors.green100,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green500),
                ),
              ),
              const SizedBox(height: 5),
              Text('$volumePercent% dari kapasitas', style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            StatusBadge(state: unavailable ? ReadingState.unavailable : reading.state, compact: true),
            const SizedBox(height: 8),
            Text(
              'Target ${reading.targetText}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.neutral600),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.green50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.green700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(color: AppColors.green50, shape: BoxShape.circle),
                child: Icon(icon, size: 34, color: AppColors.green700),
              ),
              const SizedBox(height: 20),
              Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(message, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
              if (actionLabel != null && onAction != null) ...<Widget>[
                const SizedBox(height: 20),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String relativeTime(DateTime dateTime) {
  final Duration difference = DateTime.now().difference(dateTime);
  if (difference.inSeconds < 60) return '${difference.inSeconds.clamp(0, 59)} detik lalu';
  if (difference.inMinutes < 60) return '${difference.inMinutes} menit lalu';
  if (difference.inHours < 24) return '${difference.inHours} jam lalu';
  return '${difference.inDays} hari lalu';
}
