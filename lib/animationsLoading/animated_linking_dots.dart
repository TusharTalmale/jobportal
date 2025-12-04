import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class DotLinkLoader extends StatefulWidget {
  final int dotCount;
  final double dotSize;
  final Color color;
  final Duration addSpeed;

  const DotLinkLoader({
    super.key,
    this.dotCount = 25,
    this.dotSize = 5,
    this.color = Colors.grey,
    this.addSpeed = const Duration(milliseconds: 150),
  });

  @override
  State<DotLinkLoader> createState() => _DotLinkLoaderState();
}

class _DotLinkLoaderState extends State<DotLinkLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final Random random = Random();
  List<Offset> points = [];
  List<double> angle = [];
  List<double> speed = [];

  int visibleDots = 1;
  Timer? timer;

  double containerW = 0;
  double containerH = 0;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    controller.addListener(() {
      moveDots();
      if (mounted) setState(() {});
    });

    timer = Timer.periodic(widget.addSpeed, (_) {
      setState(() {
        visibleDots++;
        if (visibleDots > widget.dotCount) {
          visibleDots = 1;
        }
      });
    });
  }

  void createDots() {
    points = List.generate(widget.dotCount, (_) {
      return Offset(random.nextDouble() * containerW,
          random.nextDouble() * containerH);
    });

    angle = List.generate(widget.dotCount, (_) {
      return random.nextDouble() * 2 * pi;
    });

    speed = List.generate(widget.dotCount, (_) {
      return 0.5 + random.nextDouble() * 0.8;
    });
  }

  void moveDots() {
    if (containerW == 0 || containerH == 0) return;

    for (int i = 0; i < points.length; i++) {
      double dx = cos(angle[i]) * speed[i];
      double dy = sin(angle[i]) * speed[i];

      Offset p = points[i] + Offset(dx, dy);

      if (p.dx < 0 || p.dx > containerW) {
        angle[i] = pi - angle[i];
      }
      if (p.dy < 0 || p.dy > containerH) {
        angle[i] = -angle[i];
      }

      points[i] = Offset(
        p.dx.clamp(0, containerW),
        p.dy.clamp(0, containerH),
      );

      angle[i] += (random.nextDouble() - 0.5) * 0.04;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        containerW = constraints.maxWidth;
        containerH = constraints.maxHeight;

        if (points.isEmpty && containerW > 0 && containerH > 0) {
          createDots();
        }

        return CustomPaint(
          painter: RandomLinkPainterV2(
            points,
            visibleDots,
            widget.dotSize,
            widget.color,
            (controller.value - 0.5).abs() * 2,
          ),
          size: Size(containerW, containerH),
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    timer?.cancel();
    super.dispose();
  }
}

class RandomLinkPainterV2 extends CustomPainter {
  final List<Offset> points;
  final int visibleDots;
  final double dotSize;
  final Color color;
  final double pulseValue;

  RandomLinkPainterV2(
    this.points,
    this.visibleDots,
    this.dotSize,
    this.color,
    this.pulseValue,
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final limit = visibleDots.clamp(0, points.length);

    final paint = Paint();
    final glowPaint = Paint()
      ..color = color.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    for (int i = 0; i < limit; i++) {
      final p1 = points[i];

      final pulse = 0.5 + pulseValue * 1.2; // dot grows 1.0 → 1.7x

      // Glow
      canvas.drawCircle(p1, dotSize * 3 * pulse, glowPaint);

      // Dot
      canvas.drawCircle(
          p1,
          dotSize * pulse,
          paint
            ..color = color
            ..style = PaintingStyle.fill);

      // Lines
      for (int j = i + 1; j < limit; j++) {
        final p2 = points[j];
        final dist = (p1 - p2).distance;

        if (dist < 150) {
          double opacity = 1 - (dist / 150);
          double thickness = 1.0 + (1 - dist / 150) * 1.3;

          canvas.drawLine(
              p1,
              p2,
              paint
                ..strokeWidth = thickness
                ..color = color.withOpacity(opacity));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant RandomLinkPainterV2 oldDelegate) => true;
}
