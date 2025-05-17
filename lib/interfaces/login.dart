import 'package:carrents/screens/introduction_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import 'signup.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import '../form_blocs/login_form_bloc.dart';
import 'dart:ui';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginFormBloc(),
      child: Builder(
        builder: (context) {
          final formBloc = BlocProvider.of<LoginFormBloc>(context);
          return Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                    'lib/assets/images/background8.jpg',
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.6),
                  colorBlendMode: BlendMode.darken,
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 24,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                              child: Card(
                                color: Colors.white.withOpacity(0.95),
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: Container(
                                  width: 370,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 36,
                                    horizontal: 28,
                                  ),
                                  child: FormBlocListener<
                                    LoginFormBloc,
                                    String,
                                    String
                                  >(
                                    onSuccess: (context, state) {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const IntroductionScreen(),
                                        ),
                                      );
                                    },
                                    onFailure: (context, state) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            state.failureResponse ??
                                                'Login failed',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12.0,
                                          ),
                                          child: CircleAvatar(
                                            radius: 32,
                                            backgroundColor: kPrimaryColor
                                                .withOpacity(0.1),
                                             child: ClipOval(
                                              child: Image.asset(
                                                'lib/assets/images/logo.jpg',
                                                width: 64,
                                                height: 64,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Login',
                                          style: GoogleFonts.orbitron(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: kPrimaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Welcome back! Please sign in to continue.',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            color: const Color.fromARGB(255, 0, 0, 0),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 32),
                                        TextFieldBlocBuilder(
                                          textFieldBloc: formBloc.email,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          style: GoogleFonts.poppins(
                                            color: const Color.fromARGB(
                                              255,
                                              0,
                                              0,
                                              0,
                                            ),
                                          ),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            prefixIcon: Icon(
                                              Icons.email_outlined,
                                              color: kPrimaryColor,
                                            ),
                                            labelText: 'Email',
                                            labelStyle: const TextStyle(
                                              color: Color.fromARGB(
                                                255,
                                                0,
                                                0,
                                                0,
                                              ),
                                            ),
                                            floatingLabelStyle: const TextStyle(
                                              backgroundColor: Color.fromARGB(
                                                255,
                                                255,
                                                255,
                                                255,
                                              ),
                                              color: Color.fromARGB(
                                                255,
                                                0,
                                                0,
                                                0,
                                              ),
                                            ),
                                            hintStyle: const TextStyle(
                                              color: Color.fromARGB(
                                                179,
                                                60,
                                                60,
                                                60,
                                              ),
                                            ),
                                            errorStyle: const TextStyle(
                                              color: Color(0xFFD32F2F),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: Colors.black,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: Colors.black12,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: kPrimaryColor,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextFieldBlocBuilder(
                                          textFieldBloc: formBloc.password,
                                          obscureText: true,
                                          suffixButton:
                                              SuffixButton.obscureText,
                                          style: GoogleFonts.poppins(
                                            color: const Color.fromARGB(
                                              255,
                                              0,
                                              0,
                                              0,
                                            ),
                                          ),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            prefixIcon: Icon(
                                              Icons.lock_outline,
                                              color: kPrimaryColor,
                                            ),
                                            labelText: 'Password',
                                            labelStyle: const TextStyle(
                                              color: Color.fromARGB(
                                                255,
                                                0,
                                                0,
                                                0,
                                              ),
                                            ),
                                            floatingLabelStyle: const TextStyle(
                                              backgroundColor: Color.fromARGB(
                                                255,
                                                255,
                                                255,
                                                255,
                                              ),
                                              color: Color.fromARGB(
                                                255,
                                                0,
                                                0,
                                                0,
                                              ),
                                            ),
                                            hintStyle: const TextStyle(
                                              color: Color.fromARGB(
                                                179,
                                                60,
                                                60,
                                                60,
                                              ),
                                            ),
                                            errorStyle: const TextStyle(
                                              color: Color(0xFFD32F2F),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: Colors.black,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: Colors.black12,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: kPrimaryColor,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        SizedBox(
                                          width: double.infinity,
                                          child: BlocBuilder<
                                            LoginFormBloc,
                                            FormBlocState
                                          >(
                                            bloc: formBloc,
                                            builder: (context, state) {
                                              final isLoading =
                                                  state is FormBlocSubmitting;
                                              return ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      kPrimaryColor,
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 16,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                ),
                                                onPressed:
                                                    isLoading
                                                        ? null
                                                        : formBloc.submit,
                                                child:
                                                    isLoading
                                                        ? const SizedBox(
                                                          width: 24,
                                                          height: 24,
                                                          child:
                                                              CircularProgressIndicator(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                strokeWidth:
                                                                    2.5,
                                                              ),
                                                        )
                                                        : Text(
                                                          'Login',
                                                          style:
                                                              GoogleFonts.poppins(
                                                                fontSize: 18,
                                                              ),
                                                        ),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(
                                              context,
                                            ).pushReplacement(
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        const SignupScreen(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Don\'t have an account? Sign up',
                                            style: GoogleFonts.poppins(
                                              color: kAccentColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
