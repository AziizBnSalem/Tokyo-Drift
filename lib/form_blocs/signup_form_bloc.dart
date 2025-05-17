import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupFormBloc extends FormBloc<String, String> {
  final name = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final phone = TextFieldBloc(validators: [FieldBlocValidators.required]);
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
  final confirmPassword = TextFieldBloc(
    validators: [FieldBlocValidators.required],
  );

  SignupFormBloc() {
    addFieldBlocs(fieldBlocs: [name, phone, email, password, confirmPassword]);
    confirmPassword.addValidators([
      (value) => value == password.value ? null : 'Passwords do not match',
    ]);
  }

  @override
  Future<void> onSubmitting() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> users = prefs.getStringList('users') ?? [];
    bool exists = users.any((u) => u.split('|')[1] == email.value);
    if (!exists) {
      users.add(
        '${name.value}|${email.value}|${phone.value}|${password.value}',
      );
      await prefs.setStringList('users', users);
    }
    await prefs.setString('user_name', name.value);
    await prefs.setString('user_email', email.value);
    await prefs.setString('user_phone', phone.value);
    emitSuccess();
  }
}
