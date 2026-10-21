import 'dart:async';

import 'package:film_wise_mobile/account/blocs/login_bloc.dart';
import 'package:film_wise_mobile/account/blocs/login_event.dart';
import 'package:film_wise_mobile/account/blocs/login_state.dart';
import 'package:film_wise_mobile/account/data/auth_entity.dart';
import 'package:film_wise_mobile/account/views/widgets/social_auth_button.dart';
import 'package:film_wise_mobile/core/session.dart';
import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

const _emailPattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
final _emailRegExp = RegExp(_emailPattern);
const _successColor = Color(0xFF31FC2A);
const _fieldTextStyle = TextStyle(color: AppColors.textPrimary, fontSize: 15);
const _backdropHeightRatio = 480 / 792;
const _popupUrl =
    'https://lottie.host/2041a391-2eeb-4eac-bf8b-a9fc2a5d7b62/Ygg9wslNj9.json';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  final _pageController = PageController();

  late final AnimationController _entranceController;
  late final Animation<double> _entrance;
  late final AnimationController _popupController;
  Timer? _popupTimer;

  bool _accountCreated = false;
  bool _showPopup = false;
  bool _popupShown = false;
  bool _imagesPrecached = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _entrance = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _popupController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      _imagesPrecached = true;
      precacheImage(const AssetImage('assets/loginbg.png'), context);
      precacheImage(const AssetImage('assets/createbg.png'), context);
    }
    if (_popupShown) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['come_from'] != null) {
      _popupShown = true;
      _accountCreated = true;
      _showPopup = true;
      _popupController.forward(from: 0);
      _popupTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) setState(() => _showPopup = false);
      });
    }
  }

  @override
  void dispose() {
    _popupTimer?.cancel();
    _entranceController.dispose();
    _popupController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: context.motion(const Duration(milliseconds: 500)),
      curve: Curves.easeInOut,
    );
  }

  void _handleAuthState(BuildContext context, LoginState state) {
    switch (state) {
      case LoginSucceeded(:final token, :final isNewAccount):
        Session.token = token;
        Navigator.of(context).pushReplacementNamed(
          isNewAccount ? '/onboarding' : '/home',
        );
      case LoginFailed(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      case LoginIdle() || LoginInProgress():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * _backdropHeightRatio;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<LoginBLoc, LoginState>(
        listener: _handleAuthState,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _AuthBackdrop(
                  pageController: _pageController, height: height),
            ),
            Positioned.fill(
              child: PageView(
                controller: _pageController,
                children: [
                  _SignInForm(
                    entrance: _entrance,
                    accountCreated: _accountCreated,
                    onSwitchToSignUp: () => _goToPage(1),
                  ),
                  _SignUpForm(
                    entrance: _entrance,
                    onSwitchToSignIn: () => _goToPage(0),
                  ),
                ],
              ),
            ),
            if (_showPopup)
              Positioned.fill(
                child: Center(
                  child: Lottie.network(
                    _popupUrl,
                    controller: _popupController,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop({required this.pageController, required this.height});

  final PageController pageController;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.tokens.maxContentWidth,
        ),
        child: SizedBox(
          height: height,
          child: RepaintBoundary(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _PageFade(
                  controller: pageController,
                  asset: 'assets/loginbg.png',
                  fadesOut: true,
                ),
                _PageFade(
                  controller: pageController,
                  asset: 'assets/createbg.png',
                  fadesOut: false,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.4, 1],
                      colors: [AppColors.transparent, AppColors.background],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageFade extends StatelessWidget {
  const _PageFade({
    required this.controller,
    required this.asset,
    required this.fadesOut,
  });

  final PageController controller;
  final String asset;
  final bool fadesOut;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        excludeFromSemantics: true,
      ),
      builder: (context, child) {
        final page = controller.hasClients ? (controller.page ?? 0) : 0.0;
        final opacity = (fadesOut ? 1 - page : page).clamp(0.0, 1.0);
        return Opacity(opacity: opacity, child: child);
      },
    );
  }
}

class _AuthLayout extends StatelessWidget {
  const _AuthLayout({
    required this.title,
    required this.entrance,
    required this.formKey,
    required this.children,
  });

  final String title;
  final Animation<double> entrance;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final size = MediaQuery.sizeOf(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            tokens.spaceXl,
            size.height * 0.12,
            tokens.spaceXl,
            tokens.spaceXl,
          ),
          child: FadeTransition(
            opacity: entrance,
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/LogoWise.png',
                      height: 28,
                      excludeFromSemantics: true,
                    ),
                  ),
                  SizedBox(height: tokens.spaceLg),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'UNLOCK YOUR INNER FILM BUFF',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInForm extends StatefulWidget {
  const _SignInForm({
    required this.entrance,
    required this.accountCreated,
    required this.onSwitchToSignUp,
  });

  final Animation<double> entrance;
  final bool accountCreated;
  final VoidCallback onSwitchToSignUp;

  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitted = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<LoginBLoc>().add(
          LoginSubmitted(
            LoginEntity(email: _email.text.trim(), password: _password.text),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final autovalidate = _autovalidateMode(_submitted);

    return _AuthLayout(
      title: 'Sign in',
      entrance: widget.entrance,
      formKey: _formKey,
      children: [
        if (widget.accountCreated) ...[
          const _SuccessBanner(),
          const SizedBox(height: 20),
        ],
        const _SocialButtons(),
        const SizedBox(height: 24),
        const _OrDivider(),
        const SizedBox(height: 24),
        _authField(
          context,
          controller: _email,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          validator: _validateEmail,
          autovalidateMode: autovalidate,
        ),
        SizedBox(height: tokens.spaceLg),
        _authField(
          context,
          controller: _password,
          label: 'Password',
          icon: Icons.lock_outline_rounded,
          obscure: !_passwordVisible,
          suffixIcon: _visibilityToggle(
            visible: _passwordVisible,
            onPressed: () =>
                setState(() => _passwordVisible = !_passwordVisible),
          ),
          action: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          validator: _validatePassword,
          autovalidateMode: autovalidate,
          onFieldSubmitted: (_) => _submit(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text('Forgot password?'),
          ),
        ),
        const SizedBox(height: 8),
        _SubmitButton(label: 'Sign in', onPressed: _submit),
        const SizedBox(height: 24),
        _SwitchPrompt(
          prompt: "Don't have an account?",
          action: 'Sign up',
          onTap: widget.onSwitchToSignUp,
        ),
      ],
    );
  }
}

class _SignUpForm extends StatefulWidget {
  const _SignUpForm({required this.entrance, required this.onSwitchToSignIn});

  final Animation<double> entrance;
  final VoidCallback onSwitchToSignIn;

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _repeatPassword = TextEditingController();
  bool _submitted = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _repeatPassword.dispose();
    super.dispose();
  }

  String? _validateRepeat(String? value) {
    final error = _validatePassword(value);
    if (error != null) return error;
    return value == _password.text ? null : 'Passwords do not match';
  }

  void _submit() {
    setState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<LoginBLoc>().add(
          RegisterSubmitted(
            RegisterEntity(
              username: _username.text.trim(),
              email: _email.text.trim(),
              password: _password.text,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final autovalidate = _autovalidateMode(_submitted);

    return _AuthLayout(
      title: 'Create account',
      entrance: widget.entrance,
      formKey: _formKey,
      children: [
        const _SocialButtons(),
        const SizedBox(height: 24),
        const _OrDivider(),
        const SizedBox(height: 24),
        _authField(
          context,
          controller: _username,
          label: 'Username',
          icon: Icons.person_outline_rounded,
          autofillHints: const [AutofillHints.username],
          validator: _validateUsername,
          autovalidateMode: autovalidate,
        ),
        SizedBox(height: tokens.spaceLg),
        _authField(
          context,
          controller: _email,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          validator: _validateEmail,
          autovalidateMode: autovalidate,
        ),
        SizedBox(height: tokens.spaceLg),
        _authField(
          context,
          controller: _password,
          label: 'Password',
          icon: Icons.lock_outline_rounded,
          obscure: !_passwordVisible,
          suffixIcon: _visibilityToggle(
            visible: _passwordVisible,
            onPressed: () =>
                setState(() => _passwordVisible = !_passwordVisible),
          ),
          autofillHints: const [AutofillHints.newPassword],
          validator: _validatePassword,
          autovalidateMode: autovalidate,
        ),
        SizedBox(height: tokens.spaceLg),
        _authField(
          context,
          controller: _repeatPassword,
          label: 'Repeat password',
          icon: Icons.lock_outline_rounded,
          obscure: !_passwordVisible,
          suffixIcon: _visibilityToggle(
            visible: _passwordVisible,
            onPressed: () =>
                setState(() => _passwordVisible = !_passwordVisible),
          ),
          action: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          validator: _validateRepeat,
          autovalidateMode: autovalidate,
          onFieldSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 24),
        _SubmitButton(label: 'Create account', onPressed: _submit),
        const SizedBox(height: 24),
        _SwitchPrompt(
          prompt: 'Already have an account?',
          action: 'Sign in',
          onTap: widget.onSwitchToSignIn,
        ),
      ],
    );
  }
}

AutovalidateMode _autovalidateMode(bool submitted) =>
    submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.onUnfocus;

String? _validateEmail(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return 'Please enter your email';
  if (!_emailRegExp.hasMatch(trimmed)) return 'Please enter a valid email';
  return null;
}

String? _validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Please enter your password';
  if (value.length < 6) return 'Password must be at least 6 characters';
  return null;
}

String? _validateUsername(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return 'Please enter a username';
  if (trimmed.length < 6) return 'Username must be at least 6 characters';
  return null;
}

Widget _authField(
  BuildContext context, {
  required TextEditingController controller,
  required String label,
  required IconData icon,
  required FormFieldValidator<String> validator,
  required AutovalidateMode autovalidateMode,
  TextInputType? keyboardType,
  TextInputAction action = TextInputAction.next,
  required Iterable<String> autofillHints,
  bool obscure = false,
  Widget? suffixIcon,
  ValueChanged<String>? onFieldSubmitted,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscure,
    textInputAction: action,
    autofillHints: autofillHints,
    validator: validator,
    autovalidateMode: autovalidateMode,
    onFieldSubmitted: onFieldSubmitted,
    cursorColor: AppColors.accentGlow,
    style: _fieldTextStyle,
    decoration: _fieldDecoration(
      context,
      label: label,
      icon: icon,
      suffixIcon: suffixIcon,
    ),
  );
}

InputDecoration _fieldDecoration(
  BuildContext context, {
  required String label,
  required IconData icon,
  Widget? suffixIcon,
}) {
  final tokens = context.tokens;
  OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: AppColors.surface,
    prefixIcon: Icon(icon, color: AppColors.textMuted),
    suffixIcon: suffixIcon,
    labelStyle: const TextStyle(color: AppColors.textSecondary),
    floatingLabelStyle: const TextStyle(color: AppColors.accentGlow),
    errorStyle: const TextStyle(color: AppColors.error),
    contentPadding: EdgeInsets.symmetric(
      horizontal: tokens.spaceLg,
      vertical: tokens.spaceLg,
    ),
    border: border(AppColors.outline, tokens.borderWidth),
    enabledBorder: border(AppColors.outline, tokens.borderWidth),
    focusedBorder: border(AppColors.accentGlow, 1.5),
    errorBorder: border(AppColors.error, tokens.borderWidth),
    focusedErrorBorder: border(AppColors.error, 1.5),
  );
}

Widget _visibilityToggle({
  required bool visible,
  required VoidCallback onPressed,
}) {
  return IconButton(
    tooltip: visible ? 'Hide password' : 'Show password',
    onPressed: onPressed,
    icon: Icon(
      visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      color: AppColors.textMuted,
    ),
  );
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.tokens.radiusMd);
    return BlocSelector<LoginBLoc, LoginState, bool>(
      selector: (state) => state is LoginInProgress,
      builder: (context, loading) {
        return FilledButton(
          onPressed: loading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryButton,
            foregroundColor: AppColors.onPrimaryButton,
            disabledBackgroundColor: AppColors.surfaceRaised,
            disabledForegroundColor: AppColors.textMuted,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: radius),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          child: loading
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.onPrimaryButton,
                  ),
                )
              : Text(label),
        );
      },
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.all(tokens.spaceMd),
      decoration: BoxDecoration(
        color: const Color(0x1A31FC2A),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(color: const Color(0x6631FC2A)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline,
              color: _successColor, size: tokens.iconSmall),
          SizedBox(width: tokens.spaceSm),
          const Expanded(
            child: Text(
              'Account created successfully. Sign in to continue.',
              style: TextStyle(color: _successColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.outline)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
        Expanded(child: Divider(color: AppColors.outline)),
      ],
    );
  }
}

class _SocialButtons extends StatelessWidget {
  const _SocialButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SocialAuthButton(provider: SocialProvider.google, onPressed: () {}),
        const SizedBox(height: 12),
        SocialAuthButton(provider: SocialProvider.apple, onPressed: () {}),
      ],
    );
  }
}

class _SwitchPrompt extends StatelessWidget {
  const _SwitchPrompt({
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          prompt,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(action),
        ),
      ],
    );
  }
}
