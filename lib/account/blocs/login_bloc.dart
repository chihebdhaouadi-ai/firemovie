import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/login_repo.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBLoc extends Bloc<LoginEvent, LoginState> {
  LoginBLoc(this._repo) : super(const LoginIdle()) {
    on<LoginSubmitted>(_onLogin);
    on<RegisterSubmitted>(_onRegister);
  }

  final LoginRepo _repo;

  Future<void> _onLogin(LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(const LoginInProgress());
    try {
      final result = await _repo.login(event.entity);
      if (result.token.isEmpty) {
        emit(const LoginFailed(LoginErrorKind.invalidCredentials));
      } else {
        emit(LoginSucceeded(token: result.token, isNewAccount: false));
      }
    } catch (_) {
      emit(const LoginFailed(LoginErrorKind.network));
    }
  }

  Future<void> _onRegister(RegisterSubmitted event, Emitter<LoginState> emit) async {
    emit(const LoginInProgress());
    try {
      final result = await _repo.register(event.entity);
      if (result.status == 200 && result.token.isNotEmpty) {
        emit(LoginSucceeded(token: result.token, isNewAccount: true));
      } else {
        emit(LoginFailed(
          LoginErrorKind.registerFailed,
          serverMessage: result.message.isEmpty ? null : result.message,
        ));
      }
    } catch (_) {
      emit(const LoginFailed(LoginErrorKind.network));
    }
  }
}
