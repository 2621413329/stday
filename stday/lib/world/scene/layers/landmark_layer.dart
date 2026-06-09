import 'dart:math' as math;

import 'dart:ui';

import '../../rendering/cozy_tree_renderer.dart';

import 'world_layer.dart';

/// 岛屿视觉中心：主角身后的成长之树（cozy 簇状树冠，无大光晕）。

class LandmarkLayer extends WorldLayer {
  LandmarkLayer() : super(layerPriority: -15);

  double _time = 0;

  @override
  void update(double dt) {
    super.update(dt);

    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    if (!isMounted) return;

    if (state.island.style.biome != 'growth_world') return;

    final s = sceneSize;

    final tier = state.island.prosperityTier;

    final wind = state.environment.windStrength;

    // 主角身后略偏上，作为当前唯一核心地标。

    final base = Offset(s.x * 0.5, s.y * 0.50);

    final growth = (0.72 + tier * 0.06).clamp(0.72, 1.0);

    final scaleMul = (0.92 + tier * 0.035).clamp(0.92, 1.08);

    if (tier <= 0) {
      CozyTreeRenderer.drawPuffy(
        canvas,
        base,
        0.72,
        wind,
        _time,
        scaleMul: 0.88,
      );

      return;
    }

    CozyTreeRenderer.drawPuffy(
      canvas,
      base,
      growth,
      wind,
      _time,
      scaleMul: scaleMul,
    );

    if (tier >= 4) {
      final pulse = 0.5 + 0.5 * math.sin(_time * 1.2);

      for (var i = 0; i < 4; i++) {
        final a = i * math.pi / 2 + _time * 0.2;

        final p = base + Offset(math.cos(a) * 18, math.sin(a) * 10 - 38);

        canvas.drawCircle(
          p,
          1.8,
          Paint()
            ..color =
                const Color(0xFFFFF59D).withValues(alpha: 0.2 + pulse * 0.25),
        );
      }
    }
  }
}
