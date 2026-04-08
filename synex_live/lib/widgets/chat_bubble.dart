import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/chat_model.dart';
import '../utils/app_theme.dart';
import 'user_avatar.dart';

class ChatBubble extends StatelessWidget {
  final ChatModel chat;
  final bool isMe;

  const ChatBubble({super.key, required this.chat, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            UserAvatar(name: chat.userName, photoUrl: chat.userPhotoUrl, size: 28),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 3),
                  child: Row(children: [
                    Text(chat.userName,
                      style: const TextStyle(color: AppTheme.textSec, fontSize: 11, fontWeight: FontWeight.w600)),
                    if (chat.isHost) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(4)),
                        child: const Text('HOST', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ]),
                ),
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isMe ? AppTheme.primary : AppTheme.card,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                ),
                child: Text(chat.message,
                  style: TextStyle(
                    color: isMe ? Colors.white : AppTheme.textPri, fontSize: 14)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                child: Text(timeago.format(chat.timestamp),
                  style: const TextStyle(color: AppTheme.textHint, fontSize: 10)),
              ),
            ],
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }
}
