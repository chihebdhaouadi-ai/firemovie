import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/login_repo.dart';
import 'login_event.dart';
import 'login_state.dart';

const _invalidCredentials = 'Incorrect email or password. Please try again.';
const _registerFailed = 'Could not create your account. Please try again.';
const _networkError = 'Could not reach the server. Check your connection and try again.';

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
        emit(const LoginFailed(_invalidCredentials));
      } else {
        emit(LoginSucceeded(token: result.token, isNewAccount: false));
      }
    } catch (_) {
      emit(const LoginFailed(_networkError));
    }
  }

  Future<void> _onRegister(RegisterSubmitted event, Emitter<LoginState> emit) async {
    emit(const LoginInProgress());
    try {
      final result = await _repo.register(event.entity);
      if (result.status == 200 && result.token.isNotEmpty) {
        emit(LoginSucceeded(token: result.token, isNewAccount: true));
      } else {
        emit(LoginFailed(result.message.isEmpty ? _registerFailed : result.message));
      }
    } catch (_) {
      emit(const LoginFailed(_networkError));
    }
  }
}
