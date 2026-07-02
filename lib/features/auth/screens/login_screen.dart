import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/session/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _googleLoading = false;
  String? _error;
  bool _isSignUp = false;
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      if (_isSignUp) {
        final name = _nameCtrl.text.trim();
        if (name.isEmpty) {
          setState(() { _loading = false; _error = 'Please enter your name.'; });
          return;
        }
        await ref.read(sessionProvider.notifier).signUpWithEmail(email, password, name);
      } else {
        await ref.read(sessionProvider.notifier).signInWithEmail(email, password);
      }
      // Router auto-redirects based on session / Firebase state
    } catch (e) {
      setState(() {
        _loading = false;
        _error = _friendlyError(e.toString());
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _googleLoading = true; _error = null; });
    try {
      await ref.read(sessionProvider.notifier).signInWithGoogle();
    } catch (e) {
      setState(() {
        _googleLoading = false;
        _error = 'Google sign-in failed. Please try again.';
      });
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('user-not-found')) return 'No account found with this email.';
    if (raw.contains('wrong-password') || raw.contains('invalid-credential')) {
      return 'Incorrect email or password.';
    }
    if (raw.contains('email-already-in-use')) return 'An account with this email already exists.';
    if (raw.contains('weak-password')) return 'Password must be at least 6 characters.';
    if (raw.contains('invalid-email')) return 'Please enter a valid email address.';
    if (raw.contains('network-request-failed')) return 'No internet connection.';
    return 'Sign in failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.parchment,
      resizeToAvoidBottomInset: true,
      body: Column(children: [
        // ── Dark green header ────────────────────────────────────────────
        Container(
          height: h * 0.28,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF0D3320), Color(0xFF1B4332)],
            ),
          ),
          child: SafeArea(child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12)),
                  child: const Center(child: Text('🌿', style: TextStyle(fontSize: 22)))),
                const SizedBox(width: 10),
                RichText(text: const TextSpan(children: [
                  TextSpan(text: 'green', style: TextStyle(color: Colors.white,
                      fontSize: 20, fontWeight: FontWeight.w300)),
                  TextSpan(text: 'track', style: TextStyle(color: Colors.white,
                      fontSize: 20, fontWeight: FontWeight.w700)),
                  TextSpan(text: '.', style: TextStyle(color: AppColors.amber,
                      fontSize: 20, fontWeight: FontWeight.w700)),
                ])),
              ]),
              const Spacer(),
              Text(_isSignUp ? 'Create account.' : 'Welcome back.',
                  style: const TextStyle(color: Colors.white,
                      fontSize: 32, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(_isSignUp ? 'Join the GreenTrack network' : 'Sign in to your account',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 14)),
              const SizedBox(height: 28),
            ]),
          )),
        ),

        // ── Form section ──────────────────────────────────────────────────
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

            // Error banner
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Text(_error!,
                    style: const TextStyle(color: AppColors.error, fontSize: 14)),
              ),
              const SizedBox(height: 16),
            ],

            // Name field (sign-up only)
            if (_isSignUp) ...[
              const _Label('Full Name'),
              const SizedBox(height: 6),
              _InputField(controller: _nameCtrl, hint: 'Mwangi Kamau',
                  prefix: Icons.person_outline),
              const SizedBox(height: 16),
            ],

            const _Label('Email'),
            const SizedBox(height: 6),
            _InputField(controller: _emailCtrl, hint: 'your@email.com',
                prefix: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),

            const _Label('Password'),
            const SizedBox(height: 6),
            _InputField(
              controller: _passCtrl,
              hint: '••••••••',
              prefix: Icons.lock_outline,
              obscure: _obscure,
              suffix: IconButton(
                icon: Icon(_obscure ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary, size: 20),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),

            if (!_isSignUp) Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: () {},
                child: const Text('Forgot password?',
                    style: TextStyle(color: AppColors.leaf,
                        fontWeight: FontWeight.w600))),
            ),
            const SizedBox(height: 16),

            // Primary button
            SizedBox(height: 54, child: ElevatedButton(
              onPressed: _loading ? null : _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forest,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
              child: _loading
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(_isSignUp ? 'Create Account' : 'Sign In',
                      style: const TextStyle(fontSize: 16,
                          fontWeight: FontWeight.w700, color: Colors.white)),
            )),
            const SizedBox(height: 16),

            // Divider
            const Row(children: [
              Expanded(child: Divider()),
              Padding(padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or continue with',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
              Expanded(child: Divider()),
            ]),
            const SizedBox(height: 16),

            // Google Sign-In
            SizedBox(height: 54, child: OutlinedButton(
              onPressed: _googleLoading ? null : _signInWithGoogle,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _googleLoading
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      // Google G logo using text
                      Container(width: 24, height: 24,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4)]),
                        child: const Center(child: Text('G',
                            style: TextStyle(fontWeight: FontWeight.w900,
                                color: Color(0xFF4285F4), fontSize: 14)))),
                      const SizedBox(width: 12),
                      const Text('Continue with Google',
                          style: TextStyle(fontSize: 15,
                              fontWeight: FontWeight.w600)),
                    ]),
            )),
            const SizedBox(height: 24),

            // Toggle sign-in / sign-up
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(_isSignUp
                  ? 'Already have an account? '
                  : "Don't have an account? ",
                  style: const TextStyle(color: AppColors.textSecondary)),
              GestureDetector(
                onTap: () => setState(() { _isSignUp = !_isSignUp; _error = null; }),
                child: Text(_isSignUp ? 'Sign In' : 'Sign Up',
                    style: const TextStyle(color: AppColors.leaf,
                        fontWeight: FontWeight.w700)),
              ),
            ]),

            // Dev shortcut (remove before production)
            const SizedBox(height: 24),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text('Quick access (dev)',
                  style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary, fontSize: 11),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _DevBtn('🌱 Farmer', () {
                ref.read(sessionProvider.notifier).signInAs(
                    UserRole.farmer);
              })),
              const SizedBox(width: 8),
              Expanded(child: _DevBtn('👨‍🍳 Chef', () {
                ref.read(sessionProvider.notifier).signInAs(
                    UserRole.chef);
              })),
              const SizedBox(width: 8),
              Expanded(child: _DevBtn('🛒 Consumer', () {
                ref.read(sessionProvider.notifier).signInAs(
                    UserRole.consumer);
              })),
            ]),
          ]),
        )),
      ]),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14,
          color: AppColors.textPrimary));
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefix;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  const _InputField({required this.controller, required this.hint,
      required this.prefix, this.obscure = false,
      this.keyboardType, this.suffix});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: TextField(
      controller: controller, obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(prefix, color: AppColors.textSecondary, size: 20),
        suffixIcon: suffix,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    ),
  );
}

class _DevBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DevBtn(this.label, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          color: AppColors.parchment,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border)),
      child: Text(label, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
    ),
  );
}
