import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart'
    show Alignment, Colors, LinearGradient, RadialGradient;

/// Growth Island Mascot：奶油白软陶公仔，极简、治愈、无服装配饰。
class CozyHeroRenderer {
  CozyHeroRenderer._();

  /// [CompanionPainter] / Avatar 用：在矩形内绘制。
  static void paintInRect(
    Canvas canvas,
    Size size, {
    String expression = 'calm',
    String prop = 'none',
    String? gender,
    Color? starCoreColor,
    double performanceLevel = 0,
  }) {
    final charSize = size.width * 0.88;
    paintAt(
      canvas,
      groundX: size.width * 0.5,
      groundY: size.height * 0.76,
      charSize: charSize,
      expression: expression,
      gender: gender,
      starCoreColor: starCoreColor,
      performanceLevel: performanceLevel,
      bodyBob: math.sin(performanceLevel * math.pi) * charSize * 0.035,
      scale: 1 + performanceLevel * 0.06,
    );
  }

  /// 岛屿场景用：以脚底锚点绘制。
  static void paintAt(
    Canvas canvas, {
    required double groundX,
    required double groundY,
    required double charSize,
    String expression = 'calm',
    String prop = 'none',
    String? gender,
    Color? starCoreColor,
    double performanceLevel = 0,
    double bodyBob = 0,
    double dx = 0,
    double dy = 0,
    double rotation = 0,
    double scale = 1,
  }) {
    final cx = groundX + dx;
    final cy = groundY - charSize * 0.48 + bodyBob + dy;
    final female = _isFemale(gender);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rotation);
    canvas.scale(scale, scale);

    _drawGroundContactShadow(canvas, charSize);
    _drawArms(canvas, charSize, female: female);
    _drawBody(
      canvas,
      charSize,
      female: female,
      starCoreColor: starCoreColor ?? const Color(0xFFFFF6D8),
      performanceLevel: performanceLevel,
    );
    _drawHead(canvas, charSize, expression, female: female);

    canvas.restore();
  }

  static bool _isFemale(String? gender) {
    final normalized = gender?.toLowerCase();
    return normalized == 'female' || normalized == 'girl' || normalized == '女';
  }

  static void _drawGroundContactShadow(Canvas canvas, double charSize) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, charSize * 0.36),
        width: charSize * 0.54,
        height: charSize * 0.13,
      ),
      Paint()
        ..color = const Color(0xFF2B4B5A).withValues(alpha: 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  static Paint _clayPaint(Rect bounds,
      {Alignment center = const Alignment(-0.34, -0.48)}) {
    return Paint()
      ..shader = RadialGradient(
        center: center,
        radius: 1.08,
        colors: const [
          Color(0xFFFFFFFF),
          Color(0xFFFFFBF2),
          Color(0xFFECE5D4),
          Color(0xFFCFC5AF),
        ],
        stops: const [0.0, 0.36, 0.72, 1.0],
      ).createShader(bounds);
  }

  static Paint _softOutline(double charSize) {
    return Paint()
      ..color = const Color(0xFFD8D1BF).withValues(alpha: 0.62)
      ..style = PaintingStyle.stroke
      ..strokeWidth = charSize * 0.010;
  }

  static void _drawHead(
    Canvas canvas,
    double charSize,
    String expression, {
    required bool female,
  }) {
    final headCenter = Offset(0, -charSize * 0.265);
    final headWidth = charSize * (female ? 0.70 : 0.73);
    final headHeight = charSize * (female ? 0.67 : 0.66);
    final headPath = _bunHeadPath(
      center: headCenter,
      width: headWidth,
      height: headHeight,
      cheekSoftness: female ? 1.05 : 1.00,
    );
    final bounds = Rect.fromCenter(
      center: headCenter,
      width: headWidth,
      height: headHeight,
    );

    canvas.drawPath(
      headPath.shift(Offset(charSize * 0.035, charSize * 0.040)),
      Paint()..color = const Color(0xFF6B6252).withValues(alpha: 0.10),
    );
    canvas.drawPath(headPath, _clayPaint(bounds.inflate(charSize * 0.10)));
    _drawVolumeShade(canvas, headPath, bounds, charSize, strength: 0.18);
    canvas.drawPath(headPath, _softOutline(charSize));

    canvas.drawOval(
      Rect.fromCenter(
        center: headCenter + Offset(-headWidth * 0.18, -headHeight * 0.19),
        width: headWidth * 0.26,
        height: headHeight * 0.16,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.38),
    );

    _drawFace(canvas, headCenter, charSize, expression, female: female);
  }

  static Path _bunHeadPath({
    required Offset center,
    required double width,
    required double height,
    required double cheekSoftness,
  }) {
    final halfW = width * 0.5;
    final top = center.dy - height * 0.48;
    final upperY = center.dy - height * 0.36;
    final cheekY = center.dy + height * 0.08;
    final jawY = center.dy + height * 0.34;
    final bottomY = center.dy + height * 0.45;
    return Path()
      ..moveTo(center.dx, top)
      ..cubicTo(
        center.dx - halfW * 0.34,
        upperY,
        center.dx - halfW * 0.92 * cheekSoftness,
        center.dy - height * 0.20,
        center.dx - halfW * 0.98,
        cheekY,
      )
      ..cubicTo(
        center.dx - halfW * 0.95,
        jawY,
        center.dx - halfW * 0.42,
        bottomY,
        center.dx - halfW * 0.08,
        bottomY,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy + height * 0.47,
        center.dx + halfW * 0.08,
        bottomY,
      )
      ..cubicTo(
        center.dx + halfW * 0.42,
        bottomY,
        center.dx + halfW * 0.95,
        jawY,
        center.dx + halfW * 0.98,
        cheekY,
      )
      ..cubicTo(
        center.dx + halfW * 0.92 * cheekSoftness,
        center.dy - height * 0.20,
        center.dx + halfW * 0.34,
        upperY,
        center.dx,
        top,
      )
      ..close();
  }

  static void _drawVolumeShade(
    Canvas canvas,
    Path path,
    Rect bounds,
    double charSize, {
    required double strength,
  }) {
    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(
      bounds.inflate(charSize * 0.12),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0.06),
            Colors.transparent,
            const Color(0xFF8A806D).withValues(alpha: strength),
          ],
          stops: const [0.0, 0.48, 1.0],
        ).createShader(bounds.inflate(charSize * 0.12)),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(bounds.center.dx, bounds.bottom - bounds.height * 0.05),
        width: bounds.width * 0.74,
        height: bounds.height * 0.20,
      ),
      Paint()
        ..color = const Color(0xFF756B5B).withValues(alpha: strength * 0.42),
    );
    canvas.restore();
  }

  static void _drawFace(
    Canvas canvas,
    Offset headCenter,
    double charSize,
    String expression, {
    required bool female,
  }) {
    final eyeY = headCenter.dy + charSize * 0.028;
    final eyeOffset = charSize * (female ? 0.088 : 0.094);
    final eyeR = charSize * 0.025;
    final eyePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.45),
        radius: 0.9,
        colors: const [Color(0xFF1F211F), Color(0xFF050505)],
      ).createShader(Rect.fromCircle(center: headCenter, radius: charSize));

    canvas.drawCircle(Offset(headCenter.dx - eyeOffset, eyeY), eyeR, eyePaint);
    canvas.drawCircle(Offset(headCenter.dx + eyeOffset, eyeY), eyeR, eyePaint);

    final mouthCenter = headCenter + Offset(0, charSize * 0.098);
    final mouthPaint = Paint()
      ..color = const Color(0xFF5F584F).withValues(alpha: 0.86)
      ..style = PaintingStyle.stroke
      ..strokeWidth = charSize * 0.014
      ..strokeCap = StrokeCap.round;
    final smileLift =
        expression == 'happy' || expression == 'proud' ? 1.12 : 0.82;
    canvas.drawArc(
      Rect.fromCenter(
        center: mouthCenter,
        width: charSize * 0.128,
        height: charSize * 0.062 * smileLift,
      ),
      0.16,
      math.pi - 0.32,
      false,
      mouthPaint,
    );
  }

  static void _drawBody(
    Canvas canvas,
    double charSize, {
    required bool female,
    required Color starCoreColor,
    required double performanceLevel,
  }) {
    final bodyCenter = Offset(0, charSize * 0.155);
    final bodyWidth = charSize * (female ? 0.46 : 0.50);
    final bodyHeight = charSize * (female ? 0.58 : 0.56);
    final bodyRect = Rect.fromCenter(
      center: bodyCenter,
      width: bodyWidth,
      height: bodyHeight,
    );
    final body = RRect.fromRectAndRadius(
      bodyRect,
      Radius.circular(bodyWidth * 0.48),
    );

    _drawLegs(canvas, charSize, female: female);
    canvas.drawRRect(
      body.shift(Offset(charSize * 0.028, charSize * 0.032)),
      Paint()..color = const Color(0xFF6B6252).withValues(alpha: 0.10),
    );
    canvas.drawRRect(body, _clayPaint(bodyRect.inflate(charSize * 0.08)));
    _drawRRectVolumeShade(canvas, body, bodyRect, charSize, strength: 0.16);
    canvas.drawRRect(body, _softOutline(charSize));

    canvas.drawOval(
      Rect.fromCenter(
        center: bodyCenter + Offset(-bodyWidth * 0.16, -bodyHeight * 0.18),
        width: bodyWidth * 0.30,
        height: bodyHeight * 0.16,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.24),
    );

    _drawStarCore(
      canvas,
      bodyCenter + Offset(0, -bodyHeight * 0.02),
      charSize,
      starCoreColor,
      performanceLevel,
    );
  }

  static void _drawRRectVolumeShade(
    Canvas canvas,
    RRect rrect,
    Rect bounds,
    double charSize, {
    required double strength,
  }) {
    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawRect(
      bounds.inflate(charSize * 0.10),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.transparent,
            const Color(0xFF8A806D).withValues(alpha: strength),
          ],
          stops: const [0.0, 0.46, 1.0],
        ).createShader(bounds.inflate(charSize * 0.10)),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(bounds.center.dx, bounds.bottom - bounds.height * 0.08),
        width: bounds.width * 0.72,
        height: bounds.height * 0.22,
      ),
      Paint()
        ..color = const Color(0xFF756B5B).withValues(alpha: strength * 0.40),
    );
    canvas.restore();
  }

  static void _drawArms(
    Canvas canvas,
    double charSize, {
    required bool female,
  }) {
    final armPaint = _clayPaint(Rect.fromCenter(
      center: Offset.zero,
      width: charSize * 0.70,
      height: charSize * 0.70,
    ));
    final outline = _softOutline(charSize);
    for (final side in [-1.0, 1.0]) {
      final shoulder = Offset(side * charSize * (female ? 0.210 : 0.225),
          -charSize * (female ? 0.020 : 0.024));
      final hand = shoulder +
          Offset(
            side * charSize * (female ? 0.086 : 0.100),
            charSize * (female ? 0.275 : 0.260),
          );
      final arm = Path()
        ..moveTo(shoulder.dx, shoulder.dy)
        ..quadraticBezierTo(
          shoulder.dx + side * charSize * 0.020,
          shoulder.dy + charSize * 0.132,
          hand.dx,
          hand.dy,
        );
      canvas.drawPath(
        arm.shift(Offset(charSize * 0.018 * side, charSize * 0.020)),
        Paint()
          ..color = const Color(0xFF6B6252).withValues(alpha: 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = charSize * 0.082
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawPath(
        arm,
        armPaint
          ..style = PaintingStyle.stroke
          ..strokeWidth = charSize * 0.080
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawPath(
        arm,
        outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = charSize * 0.010
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  static void _drawLegs(
    Canvas canvas,
    double charSize, {
    required bool female,
  }) {
    final legPaint = _clayPaint(Rect.fromCenter(
      center: Offset(0, charSize * 0.36),
      width: charSize * 0.42,
      height: charSize * 0.24,
    ));
    final outline = _softOutline(charSize);
    final legY = charSize * 0.465;
    final legOffset = charSize * (female ? 0.083 : 0.096);
    for (final dx in [-legOffset, legOffset]) {
      final foot = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(dx, legY),
          width: charSize * (female ? 0.132 : 0.146),
          height: charSize * 0.165,
        ),
        Radius.circular(charSize * 0.068),
      );
      canvas.drawRRect(
        foot.shift(Offset(charSize * 0.012, charSize * 0.014)),
        Paint()..color = const Color(0xFF6B6252).withValues(alpha: 0.08),
      );
      canvas.drawRRect(foot, legPaint);
      canvas.drawRRect(foot, outline);
    }
  }

  static void _drawStarCore(
    Canvas canvas,
    Offset center,
    double charSize,
    Color color,
    double performanceLevel,
  ) {
    final pulse = 0.82 + 0.18 * math.sin(performanceLevel * math.pi);
    final glowRadius = charSize * (0.160 + performanceLevel * 0.032);
    canvas.drawCircle(
      center,
      glowRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.52 * pulse),
            color.withValues(alpha: 0.22 * pulse),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: glowRadius)),
    );

    final star = _starPath(center, charSize * 0.088);
    canvas.drawPath(
      star,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.25, -0.35),
          radius: 0.9,
          colors: [
            Colors.white.withValues(alpha: 0.98),
            color.withValues(alpha: 0.90),
          ],
        ).createShader(
            Rect.fromCircle(center: center, radius: charSize * 0.105)),
    );
    canvas.drawPath(
      star,
      Paint()
        ..color = color.withValues(alpha: 0.46)
        ..style = PaintingStyle.stroke
        ..strokeWidth = charSize * 0.008
        ..strokeJoin = StrokeJoin.round,
    );
  }

  static Path _starPath(Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? radius : radius * 0.48;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final p = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path..close();
  }
}
