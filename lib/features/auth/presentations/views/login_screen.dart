import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/auth/presentations/views/widget/auth_functions.dart';
import 'package:attendance_app/features/auth/presentations/views/widget/custom_button.dart';
import 'package:attendance_app/features/auth/presentations/views/widget/custom_text_filed.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void handleSignIn() {
    if (_formKey.currentState!.validate()) {
      signIn(
          context: context,
          emailController: emailController,
          passwordController: passwordController);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Form(
      key: _formKey,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // const Center(
                  //   child: Text(
                  //     'Sign In',
                  //     style: TextStyle(
                  //       fontSize: 50,
                  //       color: Colors.black,
                  //     ),
                  //   ),
                  // ),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.4,
                      height: MediaQuery.sizeOf(context).height * 0.2,
                      child: const CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/images/splash_logo.jpg',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   'Email',
                        //   style: TextStyle(
                        //     fontSize: 22,
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.white,
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 10,
                        // ),
                      ],
                    ),
                  ),
                  CustomTextFiled(
                    hintText: 'Enter your Email',
                    controller: emailController,
                    validatorMessage: 'Email is required',
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  // const Padding(
                  //   padding: EdgeInsets.only(left: 20),
                  //   child: Text(
                  //     'Password',
                  //     style: TextStyle(
                  //         fontSize: 22,
                  //         fontWeight: FontWeight.bold,
                  //         color: Colors.white),
                  //   ),
                  // ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  CustomTextFiled(
                    hintText: 'Enter your Password',
                    validatorMessage: 'Password is required',
                    controller: passwordController,
                  ),
                  // CustomTextButton(
                  //   text: 'Forget Password?',
                  //   onPressed: () async {
                  //     if (emailController.text == '') {
                  //       CustomSnackBar.showErrorSnackBar(
                  //         context,
                  //         'الرجاء من كتابة بريدك الالكتروني',
                  //       );

                  //       return;
                  //     }
                  //     try {
                  //       await FirebaseAuth.instance
                  //           .sendPasswordResetEmail(email: emailController.text);

                  //       AwesomeDialog(
                  //         context: context,
                  //         dialogType: DialogType.success,
                  //         //animType: AnimType.rightSlide,
                  //         title: 'Error',
                  //         desc:
                  //             'لقد تم ارسال لينك لإعادة كلمة المرور إلي بريدك الالكتروني .. الرجاء التوجه الي بريدك الالكتروني والضغط علي اللينك',
                  //       ).show();
                  //     } catch (e) {
                  //       CustomSnackBar.showErrorSnackBar(context,
                  //           ' الرجاء التأكد من ان البريد الالكتروني الذي ادخلته صحيح ثم قم بإعادة المحاولة');
                  //     }
                  //   },
                  // ),
                  const SizedBox(height: 50),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        buttonText: 'Log In',
                        onPressed: handleSignIn,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  // widget.isAdmin == true
                  //     ? CustomTextAndTextbutton(
                  //         text1: "Don't have an account? ",
                  //         text2: 'Sign Up',
                  //         onTap: () {
                  //           Navigator.of(context)
                  //               .pushReplacementNamed("registerScreen");
                  //         },
                  //       )
                  //     : const Text('')
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
