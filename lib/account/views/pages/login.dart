import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:film_wise_mobile/account/blocs/login_bloc.dart';
import 'package:film_wise_mobile/account/blocs/login_state.dart';
import 'package:film_wise_mobile/account/data/auth_entity.dart';
import 'package:film_wise_mobile/account/views/widgets/social_auth_button.dart';
import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

const _loginError = 'Incorrect email or password. Please try again.';
const _emailPattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
const _successColor = Color(0xFF31FC2A);
const _fieldTextStyle = TextStyle(color: AppColors.textPrimary, fontSize: 15);

double _unit(double value) => value < 0 ? 0 : (value > 1 ? 1 : value);

final _backdropBlur = ImageFilter.blur(sigmaX: 3, sigmaY: 3);

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  final _pageController = PageController();

  late final AnimationController _entranceController;
  late final Animation<double> _entrance;
  late final AnimationController _popupController;
  Timer? _popupTimer;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
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
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: context.motion(const Duration(milliseconds: 500)),
      curve: Curves.easeInOut,
    );
  }

  void _submitLogin() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    BlocProvider.of<LoginBLoc>(context).mapEventToState(
      LoginTrigerState(
        loginEntity: LoginEntity(
          email: _emailController.text.trim(),
          passowrd: _passwordController.text,
        ),
      ),
    );
  }

  void _submitRegister() {
    if (!(_registerFormKey.currentState?.validate() ?? false)) return;
    BlocProvider.of<LoginBLoc>(context).createaccount(
      RegisterTrigerState(
        registerEntity: RegisterEntity(
          username: _usernameController.text.trim(),
          email: _registerEmailController.text.trim(),
          passowrd: _registerPasswordController.text,
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email';
    if (!RegExp(_emailPattern).hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final imageHeight = size.height * 480 / 792;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<LoginBLoc, LoginState>(
        listenWhen: (_, state) => state is LoginErrorState,
        listener: (context, _) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text(_loginError)));
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: imageHeight,
              child: _backdrop(),
            ),
            Positioned.fill(
              child: PageView(
                controller: _pageController,
                children: [
                  _loginPage(context),
                  _registerPage(context),
                ],
              ),
            ),
            if (_showPopup)
              Positioned.fill(
                child: Center(
                  child: Lottie.network(
                    'https://lottie.host/2041a391-2eeb-4eac-bf8b-a9fc2a5d7b62/Ygg9wslNj9.json',
                    controller: _popupController,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _backdrop() {
    return ListenableBuilder(
      listenable: _pageController,
      builder: (context, _) {
        final page = _pageController.hasClients ? (_pageController.page ?? 0) : 0.0;
        return Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: _unit(1 - page),
              child: ImageFiltered(
                imageFilter: _backdropBlur,
                child: Image.asset(
                  'assets/loginbg.png',
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
            ),
            Opacity(
              opacity: _unit(page),
              child: ImageFiltered(
                imageFilter: _backdropBlur,
                child: Image.asset(
                  'assets/createbg.png',
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
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
        );
      },
    );
  }

  Widget _loginPage(BuildContext context) {
    return _authPage(
      context,
      title: 'Sign in',
      formKey: _formKey,
      children: [
        if (_accountCreated) ...[
          _successBanner(context),
          const SizedBox(height: 20),
        ],
        _socialButtons(),
        const SizedBox(height: 24),
        _divider(),
        const SizedBox(height: 24),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          validator: _validateEmail,
          cursorColor: AppColors.accentGlow,
          style: _fieldTextStyle,
          decoration: _fieldDecoration(
            context,
            label: 'Email',
            icon: Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 16),
        _passwordField(
          context,
          controller: _passwordController,
          label: 'Password',
          validator: _validatePassword,
          action: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          onFieldSubmitted: (_) => _submitLogin(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text('Forgot password?'),
          ),
        ),
        const SizedBox(height: 8),
        _submitButton(context, label: 'Sign in', onPressed: _submitLogin),
        const SizedBox(height: 24),
        _switchPrompt(
          context,
          prompt: "Don't have an account?",
          action: 'Sign up',
          onTap: () => _goToPage(1),
        ),
      ],
    );
  }

  Widget _registerPage(BuildContext context) {
    return _authPage(
      context,
      title: 'Create account',
      formKey: _registerFormKey,
      children: [
        _socialButtons(),
        const SizedBox(height: 24),
        _divider(),
        const SizedBox(height: 24),
        TextFormField(
          controller: _usernameController,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a username';
            }
            if (value.trim().length < 6) {
              return 'Username must be at least 6 characters';
            }
            return null;
          },
          cursorColor: AppColors.accentGlow,
          style: _fieldTextStyle,
          decoration: _fieldDecoration(
            context,
            label: 'Username',
            icon: Icons.person_outline_rounded,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _registerEmailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          validator: _validateEmail,
          cursorColor: AppColors.accentGlow,
          style: _fieldTextStyle,
          decoration: _fieldDecoration(
            context,
            label: 'Email',
            icon: Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 16),
        _passwordField(
          context,
          controller: _registerPasswordController,
          label: 'Password',
          validator: (value) {
            final error = _validatePassword(value);
            if (error != null) return error;
            if (value != _repeatPasswordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
          action: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
        ),
        const SizedBox(height: 16),
        _passwordField(
          context,
          controller: _repeatPasswordController,
          label: 'Repeat password',
          validator: (value) {
            final error = _validatePassword(value);
            if (error != null) return error;
            if (value != _registerPasswordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
          action: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          onFieldSubmitted: (_) => _submitRegister(),
        ),
        const SizedBox(height: 24),
        _submitButton(context, label: 'Create account', onPressed: _submitRegister),
        const SizedBox(height: 24),
        _switchPrompt(
          context,
          prompt: 'Already have an account?',
          action: 'Sign in',
          onTap: () => _goToPage(0),
        ),
      ],
    );
  }

  Widget _authPage(
    BuildContext context, {
    required String title,
    required GlobalKey<FormState> formKey,
    required List<Widget> children,
  }) {
    final size = MediaQuery.sizeOf(context);
    final tokens = context.tokens;
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(24, size.height * 0.12, 24, 24),
      child: FadeTransition(
        opacity: _entrance,
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
    );
  }

  Widget _successBanner(BuildContext context) {
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
          Icon(Icons.check_circle_outline, color: _successColor, size: tokens.iconSmall),
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

  Widget _passwordField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required FormFieldValidator<String> validator,
    required TextInputAction action,
    required Iterable<String> autofillHints,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !_isPasswordVisible,
      textInputAction: action,
      autofillHints: autofillHints,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      cursorColor: AppColors.accentGlow,
      style: _fieldTextStyle,
      decoration: _fieldDecoration(
        context,
        label: label,
        icon: Icons.lock_outline_rounded,
        suffixIcon: IconButton(
          tooltip: _isPasswordVisible ? 'Hide password' : 'Show password',
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textMuted,
          ),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
      ),
    );
  }

  Widget _submitButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
  }) {
    final radius = BorderRadius.circular(context.tokens.radiusMd);
    return BlocBuilder<LoginBLoc, LoginState>(
      buildWhen: (previous, current) =>
          (previous is LoginLoadingState) != (current is LoginLoadingState),
      builder: (context, state) {
        final loading = state is LoginLoadingState;
        return FilledButton(
          onPressed: loading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryButton,
            foregroundColor: AppColors.onPrimaryButton,
            disabledBackgroundColor: AppColors.surfaceRaised,
            disabledForegroundColor: AppColors.textMuted,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: radius),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _divider() {
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

  Widget _socialButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SocialAuthButton(provider: SocialProvider.google, onPressed: () {}),
        const SizedBox(height: 12),
        SocialAuthButton(provider: SocialProvider.apple, onPressed: () {}),
      ],
    );
  }

  Widget _switchPrompt(
    BuildContext context, {
    required String prompt,
    required String action,
    required VoidCallback onTap,
  }) {
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
