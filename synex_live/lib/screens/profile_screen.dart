import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import '../widgets/custom_button.dart';
import '../widgets/user_avatar.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(UserModel user) async {
    setState(() => _saving = true);
    final auth = context.read<AuthService>();
    final err = await auth.updateProfile(
      name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
    );
    setState(() {
      _saving = false;
      _editing = false;
    });
    if (!mounted) return;
    if (err != null) {
      AppHelpers.showSnackBar(context, err, isError: true);
    } else {
      AppHelpers.showSnackBar(context, 'Profile updated!');
    }
  }

  Future<void> _signOut() async {
    final ok = await AppHelpers.showConfirmDialog(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      isDestructive: true,
    );
    if (!ok || !mounted) return;
    await context.read<AuthService>().signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final isMe = auth.currentUserId == widget.userId;

    // Use auth.currentUser directly as fallback — no stream needed for own profile
    final fallbackUser = auth.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isMe)
            TextButton(
              onPressed: () {
                if (_editing) {
                  setState(() => _editing = false);
                } else {
                  final user = auth.currentUser;
                  if (user != null) {
                    _nameCtrl.text = user.name;
                    _bioCtrl.text = user.bio ?? '';
                  }
                  setState(() => _editing = true);
                }
              },
              child: Text(
                _editing ? 'Cancel' : 'Edit',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: StreamBuilder<UserModel?>(
        stream: UserService.streamById(widget.userId),
        builder: (_, snap) {
          // Use stream data, or fallback to auth user, or show loader
          final user = snap.data ?? fallbackUser;

          // Still loading and no fallback
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    UserAvatar(
                      name: user.name,
                      photoUrl: user.photoUrl,
                      size: 90,
                      showBorder: true,
                      borderColor: AppTheme.primary,
                    ),
                    if (isMe && _editing)
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // View mode
                if (!_editing) ...[
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: AppTheme.textPri,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(
                      color: AppTheme.textSec,
                      fontSize: 14,
                    ),
                  ),
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      user.bio!,
                      style: const TextStyle(
                        color: AppTheme.textSec,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ] else ...[
                  // Edit mode
                  TextField(
                    controller: _nameCtrl,
                    style: const TextStyle(color: AppTheme.textPri),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      filled: true,
                      fillColor: AppTheme.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bioCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: AppTheme.textPri),
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      filled: true,
                      fillColor: AppTheme.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    label: 'Save Changes',
                    isLoading: _saving,
                    onPressed: () => _saveProfile(user),
                  ),
                ],

                const SizedBox(height: 32),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _stat('${user.followersCount}', 'Followers'),
                    Container(
                      width: 1,
                      height: 32,
                      color: AppTheme.border,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    _stat('${user.followingCount}', 'Following'),
                  ],
                ),

                const SizedBox(height: 32),
                const Divider(color: AppTheme.border),
                const SizedBox(height: 24),

                // Sign out button
                if (isMe)
                  CustomButton(
                    label: 'Sign Out',
                    isLoading: false,
                    onPressed: _signOut,
                    variant: ButtonVariant.outlined,
                    color: AppTheme.accent,
                  ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _stat(String value, String label) => Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPri,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSec, fontSize: 13),
          ),
        ],
      );
}
