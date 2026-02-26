import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mindease/domain/usecases/register_usecase.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUseCase _registerUseCase;

  RegisterCubit(this._registerUseCase) : super(RegisterInitial());

  Future<void> register(String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      emit(const RegisterFailure('Preencha todos os campos'));
      return;
    }

    try {
      emit(RegisterLoading());
      await _registerUseCase(name, email, password);
      emit(RegisterSuccess());
    } catch (e) {
      emit(RegisterFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
