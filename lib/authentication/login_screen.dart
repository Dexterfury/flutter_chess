import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess/constants.dart';
import 'package:flutter_chess/helper/helper_methods.dart';
import 'package:flutter_chess/providers/authentication_provider.dart';
import 'package:flutter_chess/service/assets_manager.dart';
import 'package:flutter_chess/widgets/main_auth_button.dart';
import 'package:flutter_chess/widgets/social_button.dart';
import 'package:flutter_chess/widgets/widgets.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String email;
  late String password;
  bool obscureText = true;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // signIn user
  void signInUser() async {
    final authProvider = context.read<AuthenticationProvider>();
    if (formKey.currentState!.validate()) {
      // save the form
      formKey.currentState!.save();

      UserCredential? userCredential =
          await authProvider.signInUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential != null) {
        // 1. check if this user exist in firestore
        bool userExist = await authProvider.checkUserExist();

        if (userExist) {
          // 2. get user data from firestore
          await authProvider.getUserDataFromFireStore();

          // 3. save user data to shared preferenced - local storage
          await authProvider.saveUserDataToSharedPref();

          // 4. save this user as signed in
          await authProvider.setSignedIn();

          formKey.currentState!.reset();

          authProvider.setIsLoading(value: false);

          // 5. navigate to home screen
          navigate(isSignedIn: true);
        } else {
          // TODO navigate to user information
          navigate(isSignedIn: false);
        }
      }
    } else {
      showSnackBar(context: context, content: 'Please fill all fields');
    }
  }

  navigate({required bool isSignedIn}) {
    if (isSignedIn) {
      Navigator.pushNamedAndRemoveUntil(
          context, Constants.homeScreen, (route) => false);
    } else {
      // navigate to user information screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
      body: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 15,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(AssetsManager.chessIcon),
                ),
                const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  decoration: textFormDecoration.copyWith(
                      labelText: 'Enter your email',
                      hintText: 'Enter your email'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    } else if (!validateEmail(value)) {
                      return 'Please enter a valid email';
                    } else if (validateEmail(value)) {
                      return null;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    email = value.trim();
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: textFormDecoration.copyWith(
                    labelText: 'Enter your password',
                    hintText: 'Enter your password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                  obscureText: obscureText,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a password';
                    } else if (value.length < 8) {
                      return 'Password must be atleast 8 characters';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    password = value;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // forgot password methodd here
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : MainAuthButton(
                        lable: 'LOGIN',
                        onPressed: signInUser,
                        fontSize: 24.0,
                      ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  '- OR - \n Sign in With',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SocialButton(
                      label: 'Guest',
                      assetImage: AssetsManager.userIcon,
                      height: 55.0,
                      width: 55.0,
                      onTap: () {},
                    ),
                    SocialButton(
                      label: 'Google',
                      assetImage: AssetsManager.googleIcon,
                      height: 55.0,
                      width: 55.0,
                      onTap: () {},
                    ),
                    SocialButton(
                      label: 'Facebook',
                      assetImage: AssetsManager.facebookLogo,
                      height: 55.0,
                      width: 55.0,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                HaveAccountWidget(
                  label: 'Don\'t have an account?',
                  labelAction: 'Sign Up',
                  onPressed: () {
                    // navigate to sign up screen
                    Navigator.pushNamed(context, Constants.signUpScreen);
                  },
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
