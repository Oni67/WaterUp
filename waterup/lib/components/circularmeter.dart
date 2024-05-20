import 'package:flutter/material.dart';

class WaterProgressBar extends StatelessWidget {
  final double progress;
  final double size;
  final Color backgroundColor;
  final Color fillColor;
  final TextStyle textStyle;

  WaterProgressBar({
    required this.progress,
    this.size = 100.0,
    this.backgroundColor = Colors.grey,
    this.fillColor = Colors.blue,
    this.textStyle = const TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 4),
      painter: _WaterProgressBarPainter(
        progress: progress,
        backgroundColor: backgroundColor,
        fillColor: fillColor,
        textStyle: textStyle,
      ),
    );
  }
}

class _WaterProgressBarPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color fillColor;
  final TextStyle textStyle;

  _WaterProgressBarPainter({
    required this.progress,
    required this.backgroundColor,
    required this.fillColor,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    Paint linePaint = Paint()
      ..color = const Color.fromARGB(255, 82, 139, 168)
      ..strokeWidth = 15.0;

    double centerX = size.width / 2;
    double centerY = size.height;
    double barWidth = size.width * 0.6;
    double barHeight = size.height * progress / 100;

    // Left line
    canvas.drawLine(
      Offset(centerX - barWidth / 2, 0),
      Offset(centerX - barWidth / 2, centerY),
      linePaint,
    );

    // Right line
    canvas.drawLine(
      Offset(centerX + barWidth / 2, 0),
      Offset(centerX + barWidth / 2, centerY),
      linePaint,
    );

    // Bottom line
    canvas.drawLine(
      Offset(centerX - (barWidth + 15) / 2, centerY),
      Offset(centerX + (barWidth + 15)/ 2, centerY),
      linePaint,
    );

    // Grey rectangle
    canvas.drawRect(
      Rect.fromLTWH(
        centerX - barWidth / 2,
        0,
        barWidth,
        centerY,
      ),
      bgPaint,
    );

    // Water rectangle
    canvas.drawRect(
      Rect.fromLTWH(
        centerX - barWidth / 2,
        centerY - barHeight,
        barWidth,
        barHeight,
      ),
      fillPaint,
    );

    // Text
    TextSpan span = TextSpan(
      text: '${progress.toStringAsFixed(1)}%',
      style: textStyle,
    );

    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    tp.layout();
    tp.paint(
      canvas,
      Offset(centerX - tp.width / 2, centerY - barHeight - tp.height),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


