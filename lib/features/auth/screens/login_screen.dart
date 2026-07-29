import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/session/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../shared/widgets/animated_emoji.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final bool startInSignUp;
  const LoginScreen({super.key, this.startInSignUp = false});

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
  late bool _isSignUp = widget.startInSignUp;
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  static final _emailRegex =
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      setState(() => _error = 'Please enter a valid email address.');
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
      final raw = e.toString();
      // "Incorrect email or password" is what Firebase's invalid-credential/
      // wrong-password codes mean literally, but there's a common case where
      // that's misleading: the account exists but was created via Google
      // Sign-In, so it has no password at all — any password typed for it
      // fails this same way. There used to be a client-side check for this
      // (fetchSignInMethodsForEmail), but Firebase removed that method for
      // security reasons (it enabled email enumeration) — so this can only
      // hint at both possibilities now, not tell them apart for certain.
      if (!_isSignUp &&
          (raw.contains('invalid-credential') || raw.contains('wrong-password'))) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = 'Incorrect email or password. If you originally signed up '
              'with Google, use "Continue with Google" below instead.';
        });
        return;
      }
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _friendlyError(raw);
      });
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email above first, then tap "Forgot password?"');
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset link sent to $email')),
      );
    } catch (e) {
      setState(() => _error = _friendlyError(e.toString()));
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _googleLoading = true; _error = null; });
    try {
      await ref.read(sessionProvider.notifier).signInWithGoogle();
    } catch (e) {
      setState(() {
        _googleLoading = false;
        // Surface the real reason instead of a generic message — on
        // Android this is almost always the SHA-1 fingerprint not being
        // registered for this app in the Firebase console (shows up as
        // ApiException: 10 / DEVELOPER_ERROR), which a generic "try again"
        // message hides.
        _error = e.toString().contains('ApiException: 10') ||
                e.toString().toLowerCase().contains('developer_error')
            ? 'Google sign-in isn\'t configured for this app build yet '
                '(missing SHA-1 in Firebase). Contact support.'
            : 'Google sign-in failed. Please try again.';
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
    if (raw.contains('operation-not-allowed')) {
      // Not a user mistake — Email/Password sign-in hasn't been turned on
      // for this Firebase project yet (Console → Authentication → Sign-in
      // method). Every attempt fails identically until that's enabled.
      return 'Email/password sign-in isn\'t enabled for this app yet. '
          'Contact the app admin, or try "Continue with Google" below.';
    }
    if (raw.contains('too-many-requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    return 'Sign in failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.night,
      resizeToAvoidBottomInset: true,
      body: Stack(children: [
        // Farm photo backdrop, same treatment as the splash screen, so the
        // whole pre-login flow (splash → role select → login) feels like
        // one continuous, deliberate experience instead of three different
        // screens bolted together.
        Positioned.fill(
          child: Opacity(
            opacity: 0.18,
            child: CachedNetworkImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=900&q=80',
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.night.withValues(alpha: 0.55),
                  AppColors.night.withValues(alpha: 0.92),
                  AppColors.night,
                ],
              ),
            ),
          ),
        ),

        // Since this screen is now reached via push from the Welcome
        // choice screen (rather than replacing it), give people an
        // explicit way back instead of relying on the system back
        // gesture alone.
        if (Navigator.of(context).canPop())
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 12, top: 8),
              child: Material(
                color: Colors.white.withValues(alpha: 0.10),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
          ),
        // Soft glow orbs for depth — same trick as the splash screen, kept
        // subtle so it reads as atmosphere rather than decoration.
        Positioned(
          top: -80, right: -60,
          child: Container(
            width: 260, height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.glow.withValues(alpha: 0.16),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: -100, left: -80,
          child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.amber.withValues(alpha: 0.10),
                Colors.transparent,
              ]),
            ),
          ),
        ),

        SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Container(width: 44, height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset('assets/images/logo_icon.png', fit: BoxFit.contain),
                )),
              const SizedBox(width: 10),
              RichText(text: const TextSpan(children: [
                TextSpan(text: 'green', style: TextStyle(color: Colors.white,
                    fontSize: 20, fontWeight: FontWeight.w300)),
                TextSpan(text: 'track', style: TextStyle(color: Colors.white,
                    fontSize: 20, fontWeight: FontWeight.w700)),
                TextSpan(text: '.', style: TextStyle(color: AppColors.glow,
                    fontSize: 20, fontWeight: FontWeight.w700)),
              ])),
            ]).animate().fadeIn(duration: 400.ms).slideY(begin: -0.15, end: 0),
            const SizedBox(height: 36),
            Text(_isSignUp ? 'Create account.' : 'Welcome back.',
                style: AppTextStyles.display(34, color: Colors.white))
                .animate().fadeIn(delay: 100.ms, duration: 450.ms).slideX(begin: -0.06, end: 0),
            const SizedBox(height: 6),
            Text(_isSignUp ? 'Join the GreenTrack network' : 'Sign in to your account',
                style: AppTextStyles.sans(14, color: Colors.white60))
                .animate().fadeIn(delay: 180.ms, duration: 450.ms),
            const SizedBox(height: 28),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.045),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // Error banner
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(color: Color(0xFFE8918D), fontSize: 14)),
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
                      color: Colors.white38, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),

              if (!_isSignUp) Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: _handleForgotPassword,
                  child: const Text('Forgot password?',
                      style: TextStyle(color: AppColors.glow,
                          fontWeight: FontWeight.w600))),
              ),
              ]),
            ).animate().fadeIn(delay: 220.ms, duration: 450.ms).slideY(begin: 0.04, end: 0),
            const SizedBox(height: 20),

            // Primary button
            SizedBox(height: 56, child: ElevatedButton(
              onPressed: _loading ? null : _signIn,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.night,
                elevation: 0,
                shadowColor: AppColors.glow.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16))),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.mint, AppColors.glow]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                      color: AppColors.glow.withValues(alpha: 0.35),
                      blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Center(
                  child: _loading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: AppColors.night, strokeWidth: 2))
                      : Text(_isSignUp ? 'Create Account' : 'Sign In',
                          style: const TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w800, color: AppColors.night)),
                ),
              ),
            )).animate().fadeIn(delay: 300.ms, duration: 450.ms),
            const SizedBox(height: 20),

            // Divider
            Row(children: [
              Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.12))),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or continue with',
                      style: AppTextStyles.sans(12.5, color: Colors.white38))),
              Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.12))),
            ]),
            const SizedBox(height: 20),

            // Google Sign-In
            SizedBox(height: 54, child: OutlinedButton(
              onPressed: _googleLoading ? null : _signInWithGoogle,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.16), width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: _googleLoading
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: 24, height: 24,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: const Center(child: Text('G',
                            style: TextStyle(fontWeight: FontWeight.w900,
                                color: Color(0xFF4285F4), fontSize: 14)))),
                      const SizedBox(width: 12),
                      const Text('Continue with Google',
                          style: TextStyle(fontSize: 15,
                              fontWeight: FontWeight.w600, color: Colors.white)),
                    ]),
            )),
            const SizedBox(height: 28),

            // Toggle sign-in / sign-up
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(_isSignUp
                  ? 'Already have an account? '
                  : "Don't have an account? ",
                  style: const TextStyle(color: Colors.white54)),
              GestureDetector(
                onTap: () => setState(() { _isSignUp = !_isSignUp; _error = null; }),
                child: Text(_isSignUp ? 'Sign In' : 'Sign Up',
                    style: const TextStyle(color: AppColors.glow,
                        fontWeight: FontWeight.w700)),
              ),
            ]),

            // Dev shortcut (remove before production)
            const SizedBox(height: 28),
            Divider(color: Colors.white.withValues(alpha: 0.1)),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text('QUICK ACCESS (DEV)',
                  style: AppTextStyles.sans(11, color: Colors.white30,
                      weight: FontWeight.w700).copyWith(letterSpacing: 0.8),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _DevBtn('🌱', 'Farmer', () {
                ref.read(sessionProvider.notifier).signInAs(UserRole.farmer);
              })),
              const SizedBox(width: 8),
              Expanded(child: _DevBtn('👨\u200d🍳', 'Chef', () {
                ref.read(sessionProvider.notifier).signInAs(UserRole.chef);
              })),
              const SizedBox(width: 8),
              Expanded(child: _DevBtn('🛒', 'Consumer', () {
                ref.read(sessionProvider.notifier).signInAs(UserRole.consumer);
              })),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _DevBtn('📦', 'Aggregator', () {
                ref.read(sessionProvider.notifier).signInAs(UserRole.aggregator);
              })),
              const SizedBox(width: 8),
              Expanded(child: _DevBtn('🚚', 'Transporter', () {
                ref.read(sessionProvider.notifier).signInAs(UserRole.transporter);
              })),
              const SizedBox(width: 8),
              Expanded(child: _DevBtn('🏬', 'Distributor', () {
                ref.read(sessionProvider.notifier).signInAs(UserRole.distributor);
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
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5,
          color: Colors.white70));
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
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
    ),
    child: TextField(
      controller: controller, obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        // Without these two, the field inherits the app's light-theme
        // InputDecorationTheme (filled: true, fillColor: Colors.white)
        // whenever the phone is in light mode — painting a white box
        // behind text that's hardcoded white above, so it's invisible.
        filled: false,
        fillColor: Colors.transparent,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: Icon(prefix, color: Colors.white38, size: 20),
        suffixIcon: suffix,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    ),
  );
}

class _DevBtn extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  const _DevBtn(this.emoji, this.label, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedEmoji(emoji, size: 13),
        const SizedBox(width: 5),
        Text(label, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: Colors.white70)),
      ]),
    ),
  );
}
