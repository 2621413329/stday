import 'package:flutter/material.dart';

import '../core/theme/app_fonts.dart';
import '../core/theme/mood_theme.dart';

/// 小人头顶说话气泡。
class CompanionSpeechBubble extends StatelessWidget {
  const CompanionSpeechBubble({
    super.key,
    required this.text,
    required this.palette,
    this.maxWidth = 220,
  });

  final String text;
  final MoodPalette palette;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: palette.card.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: palette.accent.withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: palette.accent.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              text,
              style: appTextStyle(
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4A3F36),
              ),
            ),
          ),
          CustomPaint(
            size: const Size(18, 10),
            painter: _BubbleTailPainter(color: palette.card.withValues(alpha: 0.98)),
          ),
        ],
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  _BubbleTailPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.5, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) =>
      oldDelegate.color != color;
}
