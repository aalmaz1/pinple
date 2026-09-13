import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinple/core/localization/app_localizations.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/core/utils/validators.dart';
import 'package:pinple/core/widgets/app_widgets.dart';
import 'package:pinple/features/auth/providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            nickname: _nicknameController.text.trim(),
          );
      if (mounted) {
        context.go('/verify-email');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.signupTitle)),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: l10n.signupWelcome,
                subtitle: l10n.signupSubtitle,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: l10n.emailLabel,
                        hintText: 'example@smail.kongju.ac.kr',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => validateEmail(v, l10n),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _nicknameController,
                      decoration: InputDecoration(
                        labelText: l10n.nicknameLabel,
                        hintText: l10n.nicknameHint,
                      ),
                      validator: (v) => validateNickname(v, l10n),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: l10n.passwordLabel,
                        hintText: l10n.passwordHint,
                      ),
                      obscureText: true,
                      validator: (v) => validatePassword(v, l10n),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: l10n.confirmPasswordLabel,
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return l10n.passwordMismatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      child: _isLoading
                          ? const AppLoader(color: Colors.white)
                          : Text(l10n.signupTitle),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
