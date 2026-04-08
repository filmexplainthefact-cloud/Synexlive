import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/app_theme.dart';

class LiveCardShimmer extends StatelessWidget {
  const LiveCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.card,
      highlightColor: AppTheme.border,
      child: Column(children: List.generate(4, (_) =>
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            const CircleAvatar(radius: 26, backgroundColor: AppTheme.border),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(height: 14, width: double.infinity, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 8),
              Container(height: 12, width: 120, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(4))),
            ])),
          ]),
        )
      )),
    );
  }
}
