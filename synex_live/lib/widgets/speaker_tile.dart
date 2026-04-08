import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'user_avatar.dart';

class SpeakerTile extends StatelessWidget {
  final String userId, userName;
  final String? photoUrl;
  final bool isMuted, isHost;
  final bool canControl; // host can control
  final VoidCallback? onMute, onRemove, onBlock;

  const SpeakerTile({
    super.key, required this.userId, required this.userName,
    this.photoUrl, this.isMuted = false, this.isHost = false,
    this.canControl = false, this.onMute, this.onRemove, this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isHost ? AppTheme.primary.withOpacity(0.4) : AppTheme.border),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Stack(alignment: Alignment.bottomRight, children: [
          UserAvatar(name: userName, photoUrl: photoUrl, size: 52,
            showBorder: isHost, borderColor: AppTheme.primary),
          if (isMuted)
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
              child: const Icon(Icons.mic_off, color: Colors.white, size: 10),
            ),
        ]),
        const SizedBox(height: 6),
        Text(isHost ? '${userName.split(' ')[0]} ðŸ‘‘' : userName.split(' ')[0],
          style: const TextStyle(color: AppTheme.textPri, fontSize: 12, fontWeight: FontWeight.w600),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        if (!isMuted)
          const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.mic, color: AppTheme.speakerGreen, size: 12),
            SizedBox(width: 2),
            Text('Live', style: TextStyle(color: AppTheme.speakerGreen, fontSize: 10)),
          ]),
        if (canControl && !isHost) ...[
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _iconBtn(isMuted ? Icons.mic : Icons.mic_off,
              isMuted ? AppTheme.speakerGreen : AppTheme.accent, onMute),
            const SizedBox(width: 6),
            _iconBtn(Icons.person_remove_outlined, AppTheme.accent, onRemove),
          ]),
        ],
      ]),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback? onTap) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, color: color, size: 14),
      ),
    );
}
