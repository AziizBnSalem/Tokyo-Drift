import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginFormBloc extends FormBloc<String, String> {
  final email = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      (value) => value.contains('@') ? null : 'Enter a valid email',
    ],
  );
  final password = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      (value) =>
          value.length >= 6 ? null : 'Password must be at least 6 characters',
    ],
  );

  LoginFormBloc() {
    addFieldBlocs(fieldBlocs: [email, password]);
  }

  @override
  Future<void> onSubmitting() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> users = prefs.getStringList('users') ?? [];
    final user = users
        .map((u) => u.split('|'))
        .firstWhere(
          (parts) => parts[1] == email.value && parts[3] == password.value,
          orElse: () => [],
        );
    if (user.isNotEmpty) {
      await prefs.setString('user_name', user[0]);
      await prefs.setString('user_email', user[1]);
      await prefs.setString('user_phone', user[2]);
      emitSuccess();
    } else {
      emitFailure(failureResponse: 'Invalid email or password');
    }
  }
}
