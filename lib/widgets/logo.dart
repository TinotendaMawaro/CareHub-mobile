import 'package:flutter/material.dart';

class HeartPainter extends CustomPainter {
  final Color color;

  HeartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, size.height / 4);
    path.cubicTo(size.width / 4, 0, 0, size.height / 4, 0, size.height / 2);
    path.cubicTo(0, size.height * 3 / 4, size.width / 4, size.height, size.width / 2, size.height);
    path.cubicTo(size.width * 3 / 4, size.height, size.width, size.height * 3 / 4, size.width, size.height / 2);
    path.cubicTo(size.width, size.height / 4, size.width * 3 / 4, 0, size.width / 2, size.height / 4);
    path.close();

    canvas.drawPath(path, paint);

    // Add shadow
    final shadowPaint = Paint()
      ..color = Color.fromRGBO(0, 0, 0, 0.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10.0);
    canvas.drawPath(path.shift(Offset(2.0, 2.0)), shadowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HeartHandshakePainter extends CustomPainter {
  final Color color;

  HeartHandshakePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw heart
    final heartPath = Path();
    heartPath.moveTo(size.width / 2, size.height / 4);
    heartPath.cubicTo(size.width / 4, 0, 0, size.height / 4, 0, size.height / 2);
    heartPath.cubicTo(0, size.height * 3 / 4, size.width / 4, size.height, size.width / 2, size.height);
    heartPath.cubicTo(size.width * 3 / 4, size.height, size.width, size.height * 3 / 4, size.width, size.height / 2);
    heartPath.cubicTo(size.width, size.height / 4, size.width * 3 / 4, 0, size.width / 2, size.height / 4);
    heartPath.close();
    canvas.drawPath(heartPath, paint);

    // Draw handshake
    final handshakePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Left hand
    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.6), Offset(size.width * 0.2, size.height * 0.75), handshakePaint);
    canvas.drawLine(Offset(size.width * 0.2, size.height * 0.75), Offset(size.width * 0.25, size.height * 0.8), handshakePaint);
    canvas.drawLine(Offset(size.width * 0.25, size.height * 0.8), Offset(size.width * 0.3, size.height * 0.75), handshakePaint);

    // Right hand
    canvas.drawLine(Offset(size.width * 0.7, size.height * 0.6), Offset(size.width * 0.8, size.height * 0.75), handshakePaint);
    canvas.drawLine(Offset(size.width * 0.8, size.height * 0.75), Offset(size.width * 0.75, size.height * 0.8), handshakePaint);
    canvas.drawLine(Offset(size.width * 0.75, size.height * 0.8), Offset(size.width * 0.7, size.height * 0.75), handshakePaint);

    // Connection
    canvas.drawLine(Offset(size.width * 0.35, size.height * 0.6), Offset(size.width * 0.65, size.height * 0.6), handshakePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HeartLogo extends StatelessWidget {
  final double size;

  const HeartLogo({super.key, this.size = 100.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: HeartPainter(color: const Color(0xFF00C853)),
    );
  }
}

class HeartHandshakeLogo extends StatelessWidget {
  final double size;

  const HeartHandshakeLogo({super.key, this.size = 100.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: HeartHandshakePainter(color: const Color(0xFF00C853)),
    );
  }
}
