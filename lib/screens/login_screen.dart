import 'package:flutter/material.dart';

import '../app_language.dart';
import '../services/auth_service.dart';
import '../theme.dart';

/// Sign in / sign up with email + password.
///
/// Phone OTP and Google sign-in are ready in [AuthService] but hidden until
/// they are configured in Supabase (see README).
///
/// This screen never navigates by itself: when Supabase reports a new
/// session, [AuthGate] swaps it for the app.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _busy = false;

  String? _error;
  String? _info;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _email => _emailController.text.trim();

  bool get _emailLooksValid =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email);

  /// Runs [action] with a spinner, showing any Supabase error.
  Future<void> _run(Future<void> Function() action) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) {
        final raw = AuthService.describeError(e, context.t('genericError'));
        // Turn common Supabase auth errors into plain advice.
        final lower = raw.toLowerCase();
        final message = lower.contains('rate limit')
            ? context.t('authRateLimited')
            : lower.contains('already registered')
            ? context.t('authAlreadyRegistered')
            : lower.contains('invalid login credentials')
            ? context.t('authInvalidLogin')
            : lower.contains('email not confirmed')
            ? context.t('authEmailNotConfirmed')
            : raw;
        setState(() => _error = message);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _submitEmail() {
    if (_isSignUp && _nameController.text.trim().isEmpty) {
      setState(() => _error = context.t('nameRequiredError'));
      return;
    }
    if (!_emailLooksValid) {
      setState(() => _error = context.t('emailRequiredError'));
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _error = context.t('passwordLengthError'));
      return;
    }
    _run(() async {
      if (_isSignUp) {
        final res = await AuthService.signUpWithEmail(
          email: _email,
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
        );
        // No session means Supabase wants the email confirmed first.
        if (res.session == null && mounted) {
          setState(() {
            _info = context.t('checkEmailConfirm');
            _isSignUp = false;
          });
        }
      } else {
        await AuthService.signInWithEmail(
          email: _email,
          password: _passwordController.text,
        );
      }
    });
  }

  void _forgotPassword() {
    if (!_emailLooksValid) {
      setState(() => _error = context.t('forgotPasswordNeedsEmail'));
      return;
    }
    _run(() async {
      await AuthService.sendPasswordReset(_email);
      if (mounted) setState(() => _info = context.t('resetEmailSent'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: tealGradient),
        child: SafeArea(
          bottom: false,
          child: Center(
            // Keeps the layout phone-shaped on wide windows (web/desktop).
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: LanguageDropdown(
                        textColor: Colors.white,
                        dropdownColor: tealDark,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.t(
                            _isSignUp ? 'createAccountTitle' : 'loginTitle',
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.t('loginSubtitle'),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _buildCard(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: mintCard,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(48),
          topRight: Radius.circular(12),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [..._emailFields(context)],
        ),
      ),
    );
  }

  List<Widget> _emailFields(BuildContext context) {
    return [
      if (_isSignUp) ...[
        _UnderlineField(
          label: context.t('fullNameLabel'),
          hint: context.t('fullNameHint'),
          controller: _nameController,
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 24),
      ],
      _UnderlineField(
        label: context.t('emailLabel'),
        hint: context.t('emailHint'),
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 24),
      _UnderlineField(
        label: context.t('passwordLabel'),
        hint: context.t('passwordHint'),
        controller: _passwordController,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submitEmail(),
        suffix: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            size: 20,
            color: Colors.black45,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      if (!_isSignUp)
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _busy ? null : _forgotPassword,
            style: TextButton.styleFrom(foregroundColor: Colors.black87),
            child: Text(
              context.t('forgotPassword'),
              style: const TextStyle(fontSize: 13),
            ),
          ),
        )
      else
        const SizedBox(height: 16),
      const SizedBox(height: 8),
      _PrimaryButton(
        label: context.t(_isSignUp ? 'createAccountButton' : 'signIn'),
        busy: _busy,
        onPressed: _submitEmail,
      ),
      if (_error != null) _Message(text: _error!, isError: true),
      if (_info != null) _Message(text: _info!, isError: false),
      const SizedBox(height: 12),
      Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            context.t(_isSignUp ? 'haveAccountPrompt' : 'noAccountPrompt'),
            style: const TextStyle(fontSize: 13),
          ),
          TextButton(
            onPressed: _busy
                ? null
                : () => setState(() {
                    _isSignUp = !_isSignUp;
                    _error = null;
                    _info = null;
                  }),
            style: TextButton.styleFrom(foregroundColor: tealDark),
            child: Text(
              context.t(_isSignUp ? 'signInLink' : 'createAccountLink'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ];
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool busy;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: tealDark,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(label),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  final bool isError;

  const _Message({required this.text, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          color: isError ? Colors.red.shade700 : tealDark,
        ),
      ),
    );
  }
}

class _UnderlineField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;

  const _UnderlineField({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
            suffixIcon: suffix,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: tealDark, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
