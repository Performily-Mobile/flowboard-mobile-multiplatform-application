import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/theme/app_colors.dart';

/// Flowboard logo: a blue rounded square with three white bars, the same drawing as the app icon.
class FlowboardLogo extends StatelessWidget {
  /// Creates the logo with its [size].
  const FlowboardLogo({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(size: Size.square(size), painter: const _FlowboardLogoPainter()),
    );
  }
}

/// Draws the logo on a 30 x 30 grid scaled to the canvas.
class _FlowboardLogoPainter extends CustomPainter {
  const _FlowboardLogoPainter();

  static const List<List<double>> _bars = <List<double>>[
    <double>[7, 8.05, 15],
    <double>[7, 13.85, 11],
    <double>[7, 19.65, 7],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = size.width / 30;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(9 * unit)),
      Paint()..color = AppColors.primary,
    );
    final Paint bar = Paint()..color = Colors.white;
    for (final List<double> b in _bars) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(b[0] * unit, b[1] * unit, b[2] * unit, 2.3 * unit),
          Radius.circular(1.15 * unit),
        ),
        bar,
      );
    }
  }

  @override
  bool shouldRepaint(_FlowboardLogoPainter oldDelegate) => false;
}
