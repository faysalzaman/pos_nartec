import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/controller/auth/auth_controller.dart';
import 'package:pos/cubit/auth/auth_state.dart';

// Auth Cubit
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  login(String email, String password, String role) async {
    emit(AuthLoading());

    try {
      final response = await AuthController.login(email, password, role);
      emit(AuthSuccess(response: response));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll("Exception:", "")));
    }
  }
}
