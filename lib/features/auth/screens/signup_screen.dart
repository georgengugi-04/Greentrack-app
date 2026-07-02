import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/models/models.dart';

class SignupScreen extends ConsumerStatefulWidget {
  final UserRole role;
  const SignupScreen({super.key, required this.role});
  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _farmNameCtrl = TextEditingController();
  bool _obscure = true, _loading = false;
  String? _error;

  String get _roleLabel {
    switch (widget.role) {
      case UserRole.farmer:
        return '🌾 Farmer';
      case UserRole.shopper:
        return '🛒 Grocery Shopper';
      case UserRole.chef:
        return '👨‍🍳 Chef';
      case UserRole.diner:
        return '🥗 Diner';
    }
  }

  Future<void> _signup() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    if (_passCtrl.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).signUp(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          role: widget.role,
          farmName: widget.role == UserRole.farmer
              ? _farmNameCtrl.text.trim()
              : null);
    } catch (e) {
      String msg = 'Sign up failed.';
      if (e.toString().contains('email-already-in-use')) {
        msg = 'This email is already registered.';
      }
      if (e.toString().contains('weak-password')) msg = 'Password is too weak.';
      setState(() {
        _error = msg;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.clay,
        appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/onboarding'))),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          Text('Create Account', style: AppTextStyles.serif(28)),
          const SizedBox(height: 6),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: AppColors.mist,
                  borderRadius: BorderRadius.circular(8)),
              child: Text('Role: $_roleLabel',
                  style: AppTextStyles.sans(13,
                      weight: FontWeight.w600, color: AppColors.canopy))),
          const SizedBox(height: 24),
          if (_error != null) ...[
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.alert.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: AppColors.alert.withOpacity(0.3))),
                child: Text(_error!,
                    style: AppTextStyles.sans(13, color: AppColors.alert))),
            const SizedBox(height: 16),
          ],
          Text('Full Name', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'Mwangi Kariuki')),
          const SizedBox(height: 16),
          if (widget.role == UserRole.farmer) ...[
            Text('Farm Name', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 6),
            TextField(
                controller: _farmNameCtrl,
                decoration: const InputDecoration(
                    hintText: 'e.g. Kariuki Family Farm')),
            const SizedBox(height: 16),
          ],
          Text('Email', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'your@email.com')),
          const SizedBox(height: 16),
          Text('Password', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          TextField(
              controller: _passCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                  hintText: 'Min 6 characters',
                  suffixIcon: IconButton(
                      icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20),
                      onPressed: () => setState(() => _obscure = !_obscure)))),
          const SizedBox(height: 32),
          ElevatedButton(
              onPressed: _loading ? null : _signup,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52)),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Create Account')),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Already have an account? ',
                style: AppTextStyles.sans(13, color: AppColors.slate)),
            TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Sign In')),
          ]),
        ]),
      );
}
