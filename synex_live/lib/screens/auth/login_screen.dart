import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  bool _obscure = true;
  late AnimationController _ac;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _ac.forward();
  }

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); _ac.dispose(); super.dispose(); }

  Future<void> _signIn() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthService>();
    final err = await auth.signInWithEmail(email: _emailCtrl.text, password: _passCtrl.text);
    if (!mounted) return;
    if (err != null) AppHelpers.showSnackBar(context, err, isError: true);
    else _goHome();
  }

  Future<void> _googleSignIn() async {
    final auth = context.read<AuthService>();
    final err = await auth.signInWithGoogle();
    if (!mounted) return;
    if (err != null) AppHelpers.showSnackBar(context, err, isError: true);
    else _goHome();
  }

  void _goHome() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: FadeTransition(opacity: _fade,
        child: SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 60),
            // Logo
            Center(child: Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF9C64FF)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 20)],
              ),
              child: const Icon(Icons.radio_button_checked_rounded, color: Colors.white, size: 36),
            )),
            const SizedBox(height: 32),
            const Center(child: Text('Welcome Back',
              style: TextStyle(color: AppTheme.textPri, fontSize: 28, fontWeight: FontWeight.w800))),
            const SizedBox(height: 8),
            const Center(child: Text('Sign in to continue streaming',
              style: TextStyle(color: AppTheme.textSec, fontSize: 14))),
            const SizedBox(height: 40),
            CustomTextField(controller: _emailCtrl, label: 'Email Address',
              hint: 'you@example.com', keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined, validator: AppValidators.validateEmail),
            const SizedBox(height: 16),
            CustomTextField(controller: _passCtrl, label: 'Password',
              hint: 'Enter your password', obscureText: _obscure,
              prefixIcon: Icons.lock_outline_rounded,
              validator: AppValidators.validatePassword,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppTheme.textSec, size: 20))),
            const SizedBox(height: 32),
            Consumer<AuthService>(builder: (_, auth, __) =>
              CustomButton(label: 'Sign In', isLoading: auth.isLoading, onPressed: _signIn)),
            const SizedBox(height: 20),
            Row(children: const [
              Expanded(child: Divider(color: AppTheme.border)),
              Padding(padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('or', style: TextStyle(color: AppTheme.textSec))),
              Expanded(child: Divider(color: AppTheme.border)),
            ]),
            const SizedBox(height: 20),
            Consumer<AuthService>(builder: (_, auth, __) =>
              CustomButton(label: 'Continue with Google',
                isLoading: false,
                onPressed: auth.isLoading ? null : _googleSignIn,
                variant: ButtonVariant.outlined,
                icon: Container(width: 20, height: 20,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Center(child: Text('G',
                    style: TextStyle(color: Color(0xFF4285F4), fontSize: 12, fontWeight: FontWeight.w800)))))),
            const SizedBox(height: 32),
            Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text("Don't have an account? ", style: TextStyle(color: AppTheme.textSec)),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                child: const Text('Sign Up',
                  style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700))),
            ])),
            const SizedBox(height: 32),
          ])),
        )),
      ),
    );
  }
}
