import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/utils/service_locator.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/primary_button.dart';

/// Sign up UI with fake auth creation.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _localErrorMessage;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_clearAuthError);
    _passwordCtrl.addListener(_clearAuthError);
    _confirmCtrl.addListener(_clearAuthError);
  }

  void _clearAuthError() {
    ServiceLocator.authProvider.clearError();
    if (_localErrorMessage != null) {
      setState(() => _localErrorMessage = null);
    }
  }

  @override
  void dispose() {
    _emailCtrl.removeListener(_clearAuthError);
    _passwordCtrl.removeListener(_clearAuthError);
    _confirmCtrl.removeListener(_clearAuthError);
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() {
        _localErrorMessage = 'Passwords do not match';
      });
      return;
    }

    final authProvider = ServiceLocator.authProvider;
    await authProvider.signup(_emailCtrl.text.trim(), _passwordCtrl.text);

    if (!mounted) return;
    if (authProvider.signupSuccessMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.signupSuccessMessage!)),
      );
      authProvider.clearSignupSuccessMessage();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ServiceLocator.authProvider,
      builder: (context, _) {
        final authProvider = ServiceLocator.authProvider;
        final errorMessage = _localErrorMessage ?? authProvider.errorMessage;

        return Scaffold(
          body: LoadingOverlay(
            visible: authProvider.isLoading,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0E2546), Color(0xFF070C15)],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: AppSpacing.screenPadding,
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.xl),
                      Image.asset('assets/images/logo.png', height: 90),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Unmasking AI-generated deception',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.xl,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardOverlay,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [AppShadows.medium],
                          border: Border.all(color: AppColors.subtle),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Greetings',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(letterSpacing: -0.2),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              TextFormField(
                                controller: _nameCtrl,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.person_outline),
                                  hintText: 'Full Name',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Name is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.mail_outline),
                                  hintText: 'Email Address',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.lock_outline),
                                  hintText: 'Password',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (value.length < 6) {
                                    return 'Password is too short';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TextFormField(
                                controller: _confirmCtrl,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.lock_outline),
                                  hintText: 'Confirm Password',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Confirm your password';
                                  }
                                  if (value != _passwordCtrl.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              if (errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.md,
                                  ),
                                  child: Text(
                                    errorMessage,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.redAccent),
                                  ),
                                ),
                              PrimaryButton(
                                label: 'Sign Up',
                                onPressed: authProvider.isLoading
                                    ? null
                                    : _handleSignup,
                                isBusy: authProvider.isLoading,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Align(
                                alignment: Alignment.center,
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Already have an account? Login',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
