import 'package:flutter/material.dart';
import '../models/live_request_model.dart';
import '../utils/app_theme.dart';
import 'user_avatar.dart';

class RequestTile extends StatelessWidget {
  final LiveRequestModel request;
  final VoidCallback onAccept, onReject;

  const RequestTile({super.key, required this.request, required this.onAccept, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        UserAvatar(name: request.userName, photoUrl: request.userPhotoUrl, size: 40),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(request.userName,
            style: const TextStyle(color: AppTheme.textPri, fontSize: 14, fontWeight: FontWeight.w600)),
          const Text('Wants to speak', style: TextStyle(color: AppTheme.textSec, fontSize: 12)),
        ])),
        // Reject
        GestureDetector(
          onTap: onReject,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.close, color: AppTheme.accent, size: 18),
          ),
        ),
        const SizedBox(width: 8),
        // Accept
        GestureDetector(
          onTap: onAccept,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppTheme.speakerGreen.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.check, color: AppTheme.speakerGreen, size: 18),
          ),
        ),
      ]),
    );
  }
}
