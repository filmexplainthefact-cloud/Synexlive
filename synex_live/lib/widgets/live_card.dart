import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/live_model.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import 'user_avatar.dart';

class LiveCard extends StatelessWidget {
  final LiveModel live;
  final VoidCallback onTap;

  const LiveCard({super.key, required this.live, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(children: [
          // Avatar
          Stack(children: [
            UserAvatar(name: live.hostName, photoUrl: live.hostPhotoUrl, size: 52,
              showBorder: true, borderColor: AppTheme.liveRed),
            Positioned(bottom: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.liveRed, borderRadius: BorderRadius.circular(6)),
                child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
              )),
          ]),
          const SizedBox(width: 14),
          // Info
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(live.title,
              style: const TextStyle(color: AppTheme.textPri, fontSize: 15, fontWeight: FontWeight.w600),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(live.hostName, style: const TextStyle(color: AppTheme.textSec, fontSize: 13)),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.remove_red_eye_outlined, color: AppTheme.textHint, size: 14),
              const SizedBox(width: 4),
              Text(AppHelpers.formatCount(live.viewerCount),
                style: const TextStyle(color: AppTheme.textHint, fontSize: 12)),
              const SizedBox(width: 12),
              const Icon(Icons.access_time, color: AppTheme.textHint, size: 14),
              const SizedBox(width: 4),
              Text(timeago.format(live.startedAt),
                style: const TextStyle(color: AppTheme.textHint, fontSize: 12)),
            ]),
          ])),
          // Speaker count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.mic_outlined, color: AppTheme.primary, size: 14),
              const SizedBox(width: 4),
              Text('${live.speakers.length}',
                style: const TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
      ),
    );
  }
}
