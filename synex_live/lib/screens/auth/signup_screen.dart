import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _form      = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _confCtrl  = TextEditingController();
  bool _obscurePass = true, _obscureConf = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthService>();
    final err = await auth.signUpWithEmail(
      name: _nameCtrl.text, email: _emailCtrl.text, password: _passCtrl.text);
    if (!mounted) return;
    if (err != null) AppHelpers.showSnackBar(context, err, isError: true);
    else Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(backgroundColor: AppTheme.bgDark, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context))),
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 16),
          const Text('Create Account', style: TextStyle(color: AppTheme.textPri, fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Join thousands of live creators', style: TextStyle(color: AppTheme.textSec, fontSize: 14)),
          const SizedBox(height: 36),
          CustomTextField(controller: _nameCtrl, label: 'Display Name',
            hint: 'Your name', prefixIcon: Icons.person_outline_rounded,
            validator: AppValidators.validateName),
          const SizedBox(height: 16),
          CustomTextField(controller: _emailCtrl, label: 'Email Address',
            hint: 'you@example.com', keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined, validator: AppValidators.validateEmail),
          const SizedBox(height: 16),
          CustomTextField(controller: _passCtrl, label: 'Password',
            hint: 'Min 6 characters', obscureText: _obscurePass,
            prefixIcon: Icons.lock_outline_rounded,
            validator: AppValidators.validatePassword,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
              icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppTheme.textSec, size: 20))),
          const SizedBox(height: 16),
          CustomTextField(controller: _confCtrl, label: 'Confirm Password',
            hint: 'Re-enter password', obscureText: _obscureConf,
            prefixIcon: Icons.lock_outline_rounded,
            textInputAction: TextInputAction.done,
            validator: (v) => AppValidators.validateConfirmPassword(v, _passCtrl.text),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscureConf = !_obscureConf),
              icon: Icon(_obscureConf ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppTheme.textSec, size: 20))),
          const SizedBox(height: 36),
          Consumer<AuthService>(builder: (_, auth, __) =>
            CustomButton(label: 'Create Account', isLoading: auth.isLoading, onPressed: _signUp)),
          const SizedBox(height: 24),
          Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('Already have an account? ', style: TextStyle(color: AppTheme.textSec)),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text('Sign In',
                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700))),
          ])),
          const SizedBox(height: 32),
        ])),
      )),
    );
  }
}
