import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PlantArt extends StatelessWidget {
  const PlantArt({super.key, required this.seed, this.size = 150});

  final int seed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Ilustrasi tanaman',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _PlantArtPainter(seed)),
      ),
    );
  }
}

class _PlantArtPainter extends CustomPainter {
  _PlantArtPainter(this.seed);

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random(seed);
    final Offset center = Offset(size.width / 2, size.height * .72);
    final Paint background = Paint()..color = AppColors.green50;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(size.width * .16)),
      background,
    );

    final Paint shelf = Paint()..color = AppColors.green200;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, size.height * .82), width: size.width * .66, height: 8),
        const Radius.circular(8),
      ),
      shelf,
    );

    final Color potColor = Color.lerp(const Color(0xFFA66B41), const Color(0xFF6D4B38), random.nextDouble())!;
    final Path pot = Path()
      ..moveTo(size.width * .38, size.height * .57)
      ..lineTo(size.width * .62, size.height * .57)
      ..lineTo(size.width * .58, size.height * .78)
      ..quadraticBezierTo(size.width * .5, size.height * .82, size.width * .42, size.height * .78)
      ..close();
    canvas.drawPath(pot, Paint()..color = potColor);

    final Paint stemPaint = Paint()
      ..color = AppColors.green700
      ..strokeWidth = max(2.0, size.width * .016)
      ..strokeCap = StrokeCap.round;
    final double stemTop = size.height * (.22 + random.nextDouble() * .08);
    canvas.drawLine(Offset(center.dx, size.height * .6), Offset(center.dx, stemTop), stemPaint);

    final int leafCount = 6 + seed % 4;
    for (int i = 0; i < leafCount; i++) {
      final double angle = -pi * .9 + (pi * 1.8) * i / max(1, leafCount - 1);
      final double radius = size.width * (.17 + random.nextDouble() * .08);
      final Offset leafCenter = Offset(
        center.dx + cos(angle) * radius * .68,
        stemTop + size.height * .17 + sin(angle) * radius * .45,
      );
      final double rotation = angle + pi / 2;
      canvas.save();
      canvas.translate(leafCenter.dx, leafCenter.dy);
      canvas.rotate(rotation);
      final Rect leafRect = Rect.fromCenter(
        center: Offset.zero,
        width: size.width * (.14 + random.nextDouble() * .05),
        height: size.height * (.28 + random.nextDouble() * .06),
      );
      final Path leaf = Path()
        ..moveTo(0, leafRect.top)
        ..quadraticBezierTo(leafRect.right, 0, 0, leafRect.bottom)
        ..quadraticBezierTo(leafRect.left, 0, 0, leafRect.top)
        ..close();
      canvas.drawPath(
        leaf,
        Paint()..color = Color.lerp(AppColors.green400, AppColors.green800, random.nextDouble() * .65)!,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PlantArtPainter oldDelegate) => oldDelegate.seed != seed;
}
