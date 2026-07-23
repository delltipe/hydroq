import 'dart:math';

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

class HydroLineChart extends StatelessWidget {
  const HydroLineChart({
    super.key,
    required this.points,
    required this.metric,
    required this.minimumTarget,
    required this.maximumTarget,
    this.height = 220,
  });

  final List<ChartPoint> points;
  final ReportMetric metric;
  final double minimumTarget;
  final double maximumTarget;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Grafik ${metric.label} dengan ${points.length} titik data',
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _LineChartPainter(
            points: points,
            minimumTarget: minimumTarget,
            maximumTarget: maximumTarget,
          ),
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.points,
    required this.minimumTarget,
    required this.maximumTarget,
  });

  final List<ChartPoint> points;
  final double minimumTarget;
  final double maximumTarget;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    const double left = 12;
    const double right = 8;
    const double top = 12;
    const double bottom = 34;
    final Rect plot = Rect.fromLTRB(left, top, size.width - right, size.height - bottom);
    final List<double> values = <double>[
      ...points.map((ChartPoint point) => point.value),
      minimumTarget,
      maximumTarget,
    ];
    double minValue = values.reduce(min);
    double maxValue = values.reduce(max);
    final double padding = max(.1, (maxValue - minValue) * .18);
    minValue -= padding;
    maxValue += padding;

    double yFor(double value) {
      return plot.bottom - ((value - minValue) / (maxValue - minValue)) * plot.height;
    }

    final Paint gridPaint = Paint()
      ..color = AppColors.neutral200
      ..strokeWidth = 1;
    for (int i = 0; i <= 3; i++) {
      final double y = plot.top + plot.height * i / 3;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
    }

    final Rect targetRect = Rect.fromLTRB(
      plot.left,
      yFor(maximumTarget),
      plot.right,
      yFor(minimumTarget),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(targetRect, const Radius.circular(8)),
      Paint()..color = AppColors.green50,
    );

    final Path line = Path();
    final Path area = Path();
    for (int i = 0; i < points.length; i++) {
      final double x = plot.left + plot.width * i / (points.length - 1);
      final double y = yFor(points[i].value);
      if (i == 0) {
        line.moveTo(x, y);
        area.moveTo(x, plot.bottom);
        area.lineTo(x, y);
      } else {
        line.lineTo(x, y);
        area.lineTo(x, y);
      }
    }
    area.lineTo(plot.right, plot.bottom);
    area.close();
    canvas.drawPath(area, Paint()..color = AppColors.green100.withValues(alpha: .55));
    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.green500
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final Paint pointPaint = Paint()..color = AppColors.green600;
    for (int i = 0; i < points.length; i++) {
      final double x = plot.left + plot.width * i / (points.length - 1);
      final double y = yFor(points[i].value);
      canvas.drawCircle(Offset(x, y), 3.5, pointPaint);
    }

    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    final int labelStep = max(1, (points.length / 5).ceil());
    for (int i = 0; i < points.length; i += labelStep) {
      final double x = plot.left + plot.width * i / (points.length - 1);
      textPainter.text = TextSpan(
        text: points[i].label,
        style: const TextStyle(fontSize: 10, color: AppColors.neutral500),
      );
      textPainter.layout(maxWidth: 64);
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, plot.bottom + 10));
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.minimumTarget != minimumTarget ||
        oldDelegate.maximumTarget != maximumTarget;
  }
}
