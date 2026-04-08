import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/live_service.dart';
import '../models/live_model.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import '../widgets/live_card.dart';
import '../widgets/loading_shimmer.dart';
import 'go_live_screen.dart';
import 'live_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 28, height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF9C64FF)]),
              borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.radio_button_checked_rounded, color: Colors.white, size: 16)),
          const SizedBox(width: 8),
          const Text('Synex Live',
            style: TextStyle(color: AppTheme.textPri, fontSize: 18, fontWeight: FontWeight.w800)),
        ]),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ProfileScreen(userId: auth.currentUserId ?? ''))),
            icon: const Icon(Icons.person_outline_rounded, color: AppTheme.textPri)),
        ],
      ),
      body: StreamBuilder<List<LiveModel>>(
        stream: LiveService.getLiveSessions(),
        builder: (context, snap) {
          // Loading
          if (snap.connectionState == ConnectionState.waiting) {
            return const SingleChildScrollView(child: LiveCardShimmer());
          }
          // Error
          if (snap.hasError) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.wifi_off_rounded, color: AppTheme.textSec, size: 48),
              const SizedBox(height: 12),
              Text('Connection error', style: const TextStyle(color: AppTheme.textSec)),
              TextButton(onPressed: () {}, child: const Text('Retry')),
            ]));
          }
          final lives = snap.data ?? [];
          // Empty state
          if (lives.isEmpty) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.card, borderRadius: BorderRadius.circular(24)),
                child: const Icon(Icons.live_tv_outlined, color: AppTheme.textSec, size: 40)),
              const SizedBox(height: 16),
              const Text('No live sessions right now',
                style: TextStyle(color: AppTheme.textPri, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Be the first to go live!',
                style: TextStyle(color: AppTheme.textSec, fontSize: 14)),
            ]));
          }
          return RefreshIndicator(
            color: AppTheme.primary, backgroundColor: AppTheme.card,
            onRefresh: () async {},
            child: CustomScrollView(slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 8, bottom: 100),
                sliver: SliverList(delegate: SliverChildBuilderDelegate(
                  (_, i) => LiveCard(
                    live: lives[i],
                    onTap: () async {
                      final userId = auth.currentUserId ?? '';
                      final blocked = await LiveService.isBlocked(lives[i].id, userId);
                      if (!context.mounted) return;
                      if (blocked) {
                        AppHelpers.showSnackBar(context, 'You are blocked from this live.', isError: true);
                        return;
                      }
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => LiveScreen(liveId: lives[i].id)));
                    },
                  ),
                  childCount: lives.length,
                )),
              ),
            ]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoLiveScreen())),
        backgroundColor: AppTheme.liveRed,
        icon: const Icon(Icons.videocam_rounded, color: Colors.white),
        label: const Text('Go Live', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
