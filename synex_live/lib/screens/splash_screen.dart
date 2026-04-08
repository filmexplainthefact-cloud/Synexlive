import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _scale, _fade;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _ac, curve: Curves.elasticOut));
    _fade  = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ac, curve: const Interval(0, 0.5, curve: Curves.easeIn)));
    _ac.forward();
    Future.delayed(const Duration(milliseconds: 2200), _navigate);
  }

  @override
  void dispose() { _ac.dispose(); super.dispose(); }

  void _navigate() {
    if (!mounted) return;
    final auth = context.read<AuthService>();
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => auth.isLoggedIn ? const HomeScreen() : const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bgDark,
    body: Center(child: AnimatedBuilder(
      animation: _ac,
      builder: (_, child) => FadeTransition(opacity: _fade,
        child: ScaleTransition(scale: _scale, child: child)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 100, height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF9C64FF)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)],
          ),
          child: const Icon(Icons.radio_button_checked_rounded, color: Colors.white, size: 52)),
        const SizedBox(height: 24),
        const Text('Synex Live',
          style: TextStyle(color: AppTheme.textPri, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        const SizedBox(height: 8),
        const Text('Go Live. Connect. Inspire.',
          style: TextStyle(color: AppTheme.textSec, fontSize: 15)),
        const SizedBox(height: 60),
        SizedBox(width: 24, height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5,
            color: AppTheme.primary.withOpacity(0.7))),
      ]),
    )),
  );
}
