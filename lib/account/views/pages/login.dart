import 'dart:async';
import 'dart:math' as math;

import 'package:film_wise_mobile/account/blocs/login_bloc.dart';
import 'package:film_wise_mobile/account/blocs/login_event.dart';
import 'package:film_wise_mobile/account/blocs/login_state.dart';
import 'package:film_wise_mobile/account/data/auth_entity.dart';
import 'package:film_wise_mobile/account/views/widgets/social_auth_button.dart';
import 'package:film_wise_mobile/core/auth/auth_cubit.dart';
import 'package:film_wise_mobile/core/auth/auth_gate.dart';
import 'package:film_wise_mobile/core/l10n_context.dart';
import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../core/widgets/game_button.dart';

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
  late final CurvedAnimation _entrance;
  late final AnimationController _popupController;
  Timer? _popupTimer;

  bool _accountCreated = false;
  bool _showPopup = false;
  bool _popupShown = false;
  bool _startOnSignUpApplied = false;
  bool _imagesPrecached = false;
  String? _reason;

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
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is LoginRouteArgs) {
      _reason = args.reason;
      if (args.startOnSignUp && !_startOnSignUpApplied) {
        _startOnSignUpApplied = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _pageController.hasClients) {
            _pageController.jumpToPage(1);
          }
        });
      }
    }
    if (_popupShown) return;
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
    _entrance.dispose();
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
        // Sets Session.token synchronously, then persists it.
        unawaited(context.read<AuthCubit>().signIn(token));
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          // Opened by a gate: hand the result back so the caller resumes.
          navigator.pop(LoginOutcome(isNewAccount: isNewAccount));
        } else {
          navigator.pushReplacementNamed(
            isNewAccount ? onboardingRouteName : '/',
          );
        }
      case LoginFailed(:final kind, :final serverMessage):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
                content: Text(serverMessage ?? _errorText(context.l10n, kind))),
          );
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
                    reason: _reason,
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
            if (Navigator.canPop(context))
              Positioned(
                top: 0,
                right: 0,
                child: SafeArea(
                  child: IconButton(
                    tooltip: context.l10n.authClose,
                    icon:
                        const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
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

class _AuthPage extends StatelessWidget {
  const _AuthPage({
    required this.title,
    required this.subtitle,
    required this.entrance,
    required this.formKey,
    required this.children,
  });

  final String title;
  final String subtitle;
  final Animation<double> entrance;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final topInset = math.max(
      MediaQuery.sizeOf(context).height * 0.09,
      MediaQuery.paddingOf(context).top + tokens.spaceMd,
    );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            tokens.spaceXl,
            topInset,
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
                      height: tokens.logoHeight,
                      excludeFromSemantics: true,
                    ),
                  ),
                  SizedBox(height: tokens.spaceLg),
                  Text(
                    context.l10n.authTagline,
                    style: const TextStyle(
                      color: AppColors.accentGlow,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.6,
                    ),
                  ),
                  SizedBox(height: tokens.spaceXs),
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: tokens.spaceXs),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: tokens.spaceLg),
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
    this.reason,
  });

  final Animation<double> entrance;
  final bool accountCreated;
  final VoidCallback onSwitchToSignUp;

  /// Context line from the gate that opened login, if any.
  final String? reason;

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
    if (_isBusy(context)) return;
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
    final l10n = context.l10n;
    final autovalidate = _autovalidateMode(_submitted);

    return _AuthPage(
      title: l10n.authWelcomeBack,
      subtitle: l10n.authSignInSubtitle,
      entrance: widget.entrance,
      formKey: _formKey,
      children: [
        if (widget.reason case final reason?) ...[
          _ReasonLine(text: reason),
          SizedBox(height: tokens.spaceLg),
        ],
        if (widget.accountCreated) ...[
          const _SuccessBanner(),
          SizedBox(height: tokens.spaceLg),
        ],
        const _SocialRow(),
        SizedBox(height: tokens.spaceLg),
        const _OrDivider(),
        SizedBox(height: tokens.spaceLg),
        _authField(
          context,
          controller: _email,
          label: l10n.authEmail,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          validator: (value) => _validateEmail(value, l10n),
          autovalidateMode: autovalidate,
        ),
        SizedBox(height: tokens.spaceLg),
        _authField(
          context,
          controller: _password,
          label: l10n.authPassword,
          icon: Icons.lock_outline_rounded,
          obscure: !_passwordVisible,
          suffixIcon: _visibilityToggle(
            context,
            visible: _passwordVisible,
            onPressed: () =>
                setState(() => _passwordVisible = !_passwordVisible),
          ),
          action: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          validator: (value) => _validatePassword(value, l10n),
          autovalidateMode: autovalidate,
          onFieldSubmitted: (_) => _submit(),
        ),
        SizedBox(height: tokens.spaceXl),
        _SubmitButton(label: l10n.authSignIn, onPressed: _submit),
        SizedBox(height: tokens.spaceLg),
        _SwitchPrompt(
          prompt: l10n.authNoAccountPrompt,
          action: l10n.authSignUp,
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
  bool _repeatVisible = false;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _repeatPassword.dispose();
    super.dispose();
  }

  String? _validateRepeat(String? value) {
    final l10n = context.l10n;
    final error = _validatePassword(value, l10n);
    if (error != null) return error;
    return value == _password.text ? null : l10n.authPasswordsMismatch;
  }

  void _submit() {
    if (_isBusy(context)) return;
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
    final l10n = context.l10n;
    final autovalidate = _autovalidateMode(_submitted);

    return _AuthPage(
      title: l10n.authCreateAccount,
      subtitle: l10n.authCreateAccountSubtitle,
      entrance: widget.entrance,
      formKey: _formKey,
      children: [
        const _SocialRow(),
        SizedBox(height: tokens.spaceLg),
        const _OrDivider(),
        SizedBox(height: tokens.spaceLg),
        _authField(
          context,
          controller: _username,
          label: l10n.authUsername,
          icon: Icons.person_outline_rounded,
          helperText: l10n.authMinLengthHint,
          autofillHints: const [AutofillHints.username],
          validator: (value) => _validateUsername(value, l10n),
          autovalidateMode: autovalidate,
        ),
        SizedBox(height: tokens.spaceLg),
        _authField(
          context,
          controller: _email,
          label: l10n.authEmail,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          validator: (value) => _validateEmail(value, l10n),
          autovalidateMode: autovalidate,
        ),
        SizedBox(height: tokens.spaceLg),
        _authField(
          context,
          controller: _password,
          label: l10n.authPassword,
          icon: Icons.lock_outline_rounded,
          helperText: l10n.authMinLengthHint,
          obscure: !_passwordVisible,
          suffixIcon: _visibilityToggle(
            context,
            visible: _passwordVisible,
            onPressed: () =>
                setState(() => _passwordVisible = !_passwordVisible),
          ),
          autofillHints: const [AutofillHints.newPassword],
          validator: (value) => _validatePassword(value, l10n),
          autovalidateMode: autovalidate,
        ),
        SizedBox(height: tokens.spaceLg),
        _authField(
          context,
          controller: _repeatPassword,
          label: l10n.authRepeatPassword,
          icon: Icons.lock_outline_rounded,
          obscure: !_repeatVisible,
          suffixIcon: _visibilityToggle(
            context,
            visible: _repeatVisible,
            onPressed: () => setState(() => _repeatVisible = !_repeatVisible),
          ),
          action: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          validator: _validateRepeat,
          autovalidateMode: autovalidate,
          onFieldSubmitted: (_) => _submit(),
        ),
        SizedBox(height: tokens.spaceXl),
        _SubmitButton(label: l10n.authCreateAccount, onPressed: _submit),
        SizedBox(height: tokens.spaceLg),
        _SwitchPrompt(
          prompt: l10n.authHaveAccountPrompt,
          action: l10n.authSignIn,
          onTap: widget.onSwitchToSignIn,
        ),
      ],
    );
  }
}

bool _isBusy(BuildContext context) =>
    context.read<LoginBLoc>().state is LoginInProgress;

String _errorText(AppLocalizations l10n, LoginErrorKind kind) => switch (kind) {
      LoginErrorKind.invalidCredentials => l10n.authErrorInvalidCredentials,
      LoginErrorKind.registerFailed => l10n.authErrorRegisterFailed,
      LoginErrorKind.network => l10n.authErrorNetwork,
    };

AutovalidateMode _autovalidateMode(bool submitted) =>
    submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.onUnfocus;

String? _validateEmail(String? value, AppLocalizations l10n) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return l10n.authEmailRequired;
  if (!_emailRegExp.hasMatch(trimmed)) return l10n.authEmailInvalid;
  return null;
}

String? _validatePassword(String? value, AppLocalizations l10n) {
  if (value == null || value.isEmpty) return l10n.authPasswordRequired;
  if (value.length < 6) return l10n.authPasswordTooShort;
  return null;
}

String? _validateUsername(String? value, AppLocalizations l10n) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return l10n.authUsernameRequired;
  if (trimmed.length < 6) return l10n.authUsernameTooShort;
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
  String? helperText,
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
    autocorrect: false,
    enableSuggestions: false,
    validator: validator,
    autovalidateMode: autovalidateMode,
    onFieldSubmitted: onFieldSubmitted,
    cursorColor: AppColors.accentGlow,
    style: _fieldTextStyle,
    decoration: _fieldDecoration(
      context,
      label: label,
      icon: icon,
      helperText: helperText,
      suffixIcon: suffixIcon,
    ),
  );
}

InputDecoration _fieldDecoration(
  BuildContext context, {
  required String label,
  required IconData icon,
  String? helperText,
  Widget? suffixIcon,
}) {
  final tokens = context.tokens;
  OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    labelText: label,
    helperText: helperText,
    helperStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
    filled: true,
    fillColor: AppColors.surface,
    prefixIcon: Icon(icon, color: AppColors.textMuted),
    suffixIcon: suffixIcon,
    labelStyle: const TextStyle(color: AppColors.textSecondary),
    floatingLabelStyle: const TextStyle(color: AppColors.accentGlow),
    errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
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

Widget _visibilityToggle(
  BuildContext context, {
  required bool visible,
  required VoidCallback onPressed,
}) {
  final l10n = context.l10n;
  return IconButton(
    tooltip: visible ? l10n.authHidePassword : l10n.authShowPassword,
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
    return BlocSelector<LoginBLoc, LoginState, bool>(
      selector: (state) => state is LoginInProgress,
      builder: (context, loading) {
        return SizedBox(
          width: double.infinity,
          child: GameButton(
            label: label,
            style: GameButtonStyle.blue,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            onPressed: loading ? null : onPressed,
            child: loading
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}

class _ReasonLine extends StatelessWidget {
  const _ReasonLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      children: [
        Icon(Icons.lock_outline_rounded,
            color: AppColors.accentGlow, size: tokens.iconSmall),
        SizedBox(width: tokens.spaceSm),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
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
          Expanded(
            child: Text(
              context.l10n.authAccountCreated,
              style: const TextStyle(color: _successColor, fontSize: 13),
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
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.outline)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.tokens.spaceMd),
          child: Text(
            context.l10n.authOr,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.outline)),
      ],
    );
  }
}

class _SocialRow extends StatelessWidget {
  const _SocialRow();

  @override
  Widget build(BuildContext context) {
    final gap = context.tokens.spaceLg;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SocialAuthButton(provider: SocialProvider.google, onPressed: () {}),
        SizedBox(width: gap),
        SocialAuthButton(provider: SocialProvider.apple, onPressed: () {}),
        SizedBox(width: gap),
        SocialAuthButton(provider: SocialProvider.reddit, onPressed: () {}),
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
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
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
