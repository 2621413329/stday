import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Alignment, Colors, LinearGradient;

import 'world_layer.dart';

/// 环境生命感：飞鸟、光粒、薄雾、流星（与 mood 氛围联动，不改变岛体）。
class AmbientLifeLayer extends WorldLayer {
  AmbientLifeLayer() : super(layerPriority: 15);

  double _time = 0;
  double _shootingStar = -1;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    if (_shootingStar < 0 && _time % 18 < dt) {
      _shootingStar = 0;
    }
    if (_shootingStar >= 0) _shootingStar += dt;
    if (_shootingStar > 2.5) _shootingStar = -1;
  }

  @override
  void render(Canvas canvas) {
    if (!isMounted) return;
    final s = sceneSize;
    final env = state.environment;
    final preset = env.lifePreset;

    if (env.fogOpacity > 0) _drawFog(canvas, s, env.fogOpacity);
    _drawFloatingLights(canvas, s, env.particlePreset);

    switch (preset) {
      case 'seagulls':
        _drawBirds(canvas, s, count: 4, speed: 0.35);
      case 'breeze':
        _drawBirds(canvas, s, count: 2, speed: 0.22);
      case 'wind':
        _drawBirds(canvas, s, count: 1, speed: 0.5);
      default:
        break;
    }

    if (_shootingStar >= 0 && state.island.prosperityTier >= 3) {
      _drawShootingStar(canvas, s);
    }
  }

  void _drawFog(Canvas canvas, Vector2 s, double opacity) {
    canvas.drawRect(
      Offset.zero & Size(s.x, s.y * 0.55),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: opacity * 0.35),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, s.x, s.y * 0.55)),
    );
  }

  void _drawFloatingLights(Canvas canvas, Vector2 s, String preset) {
    final count = preset == 'golden_sparkle' ? 18 : 10;
    for (var i = 0; i < count; i++) {
      final x = s.x * (0.12 + (i * 0.053) % 0.76);
      final y = s.y * (0.18 + (i * 0.071) % 0.42) +
          math.sin(_time * 0.9 + i * 1.3) * 6;
      final alpha = 0.15 + 0.2 * math.sin(_time * 1.4 + i).abs();
      canvas.drawCircle(
        Offset(x, y),
        preset == 'golden_sparkle' ? 2.6 : 2.0,
        Paint()
          ..color = (preset == 'golden_sparkle'
                  ? const Color(0xFFFFD54F)
                  : const Color(0xFFB3E5FC))
              .withValues(alpha: alpha),
      );
    }
  }

  void _drawBirds(Canvas canvas, Vector2 s,
      {required int count, required double speed}) {
    for (var i = 0; i < count; i++) {
      final bx =
          (s.x * (0.1 + i * 0.22) + _time * 28 * speed + i * 40) % (s.x + 60) -
              30;
      final by = s.y * (0.14 + i * 0.05) + math.sin(_time * 0.6 + i) * 8;
      _drawBird(canvas, Offset(bx, by));
    }
  }

  void _drawBird(Canvas canvas, Offset p) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: p, width: 10, height: 7),
      0.2,
      2.2,
      false,
      paint,
    );
  }

  void _drawShootingStar(Canvas canvas, Vector2 s) {
    final t = _shootingStar.clamp(0.0, 2.5);
    final start = Offset(s.x * 0.78, s.y * 0.12);
    final end = start + Offset(-80 * t, 40 * t);
    canvas.drawLine(
      start,
      end,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.7 * (1 - t / 2.5)),
            Colors.transparent,
          ],
        ).createShader(Rect.fromPoints(start, end))
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }
}
