import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// @deprecated 请使用 [RecordPage]（/records）或 [IslandHomePage]（/island）。
@Deprecated('Use RecordPage at /records')
class TodayStoriesPage extends StatelessWidget {
  const TodayStoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go('/records');
    });
    return const SizedBox.shrink();
  }
}
