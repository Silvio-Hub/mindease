import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mindease/domain/usecases/login_usecase.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;

  LoginCubit(this._loginUseCase) : super(LoginInitial());

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      emit(const LoginFailure('Preencha todos os campos'));
      return;
    }

    try {
      emit(LoginLoading());
      await _loginUseCase(email, password);
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
