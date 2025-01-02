import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';

class BackgroundPainter extends CustomPainter {
  final Color color;

  BackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(AppSizes.opacityLight)
      ..style = PaintingStyle.fill;

    // Üst sol köşedeki büyük daire
    canvas.drawCircle(
      const Offset(0, 0),
      size.width * 0.4,
      paint,
    );

    // Alt sağ köşedeki büyük daire
    canvas.drawCircle(
      Offset(size.width, size.height),
      size.width * 0.4,
      paint,
    );

    // Rastgele küçük daireler
    final random = math.Random(42);
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * AppSizes.iconL + AppSizes.paddingXS;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }

    // Sudoku ızgarası deseni
    final gridPaint = Paint()
      ..color = color.withOpacity(AppSizes.opacityFaint)
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSizes.borderNormal;

    final cellSize = size.width / AppSizes.defaultBoardSize;
    for (int i = 0; i <= AppSizes.defaultBoardSize; i++) {
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.width, i * cellSize),
        gridPaint,
      );
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.height),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
