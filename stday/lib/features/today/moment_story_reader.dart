import 'package:flutter/material.dart';

import '../../core/constants/catalog.dart';
import '../../core/theme/mood_theme.dart';
import '../../data/models/profile_models.dart';
import '../../design_system/island_chip.dart';

/// 展示今日故事完整备注，支持长文滚动阅读。
Future<void> showMomentStoryReader({
  required BuildContext context,
  required MoodPalette palette,
  required DailyMomentModel moment,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => MomentStoryReaderSheet(
      palette: palette,
      moment: moment,
    ),
  );
}

class MomentStoryReaderSheet extends StatelessWidget {
  const MomentStoryReaderSheet({
    super.key,
    required this.palette,
    required this.moment,
  });

  final MoodPalette palette;
  final DailyMomentModel moment;

  @override
  Widget build(BuildContext context) {
    final story = moment.note?.trim();
    final hasStory = story != null && story.isNotEmpty;
    final subtitle =
        hasStory ? story! : '它看起来有话想跟你说。';
    final tagLabels = momentSelectionLabels(
      tags: moment.eventTags,
      emotionTag: moment.emotionTag,
    );
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
            color: palette.card.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
            boxShadow: [
              BoxShadow(
                color: palette.accent.withValues(alpha: 0.16),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tagLabels
                    .map(
                      (label) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: palette.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: palette.accent.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: palette.accent,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: SelectableText(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6E5A4A),
                      height: 1.55,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              IslandPrimaryAction(
                label: '确定',
                palette: palette,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
