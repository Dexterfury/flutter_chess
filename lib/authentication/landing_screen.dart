import 'package:flutter/material.dart';
import 'package:flutter_chess/constants.dart';
import 'package:flutter_chess/providers/authentication_provider.dart';
import 'package:flutter_chess/service/assets_manager.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  // check authenticationState - if isSignedIn or not
  void checkAuthenticationState() async {
    final authProvider = context.read<AuthenticationProvider>();

    if (await authProvider.checkIsSignedIn()) {
      // 1. get user data from firestore
      await authProvider.getUserDataFromFireStore();

      // 2. save user data to shared preferences
      await authProvider.saveUserDataToSharedPref();

      // 3. navigate to home screen
      navigate(isSignedIn: true);
    } else {
      // navigate to the sign screen
      navigate(isSignedIn: false);
    }
  }

  @override
  void initState() {
    checkAuthenticationState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(AssetsManager.chessIcon),
        ),
      ),
    );
  }

  void navigate({required bool isSignedIn}) {
    if (isSignedIn) {
      Navigator.pushReplacementNamed(context, Constants.homeScreen);
    } else {
      Navigator.pushReplacementNamed(context, Constants.loginScreen);
    }
  }
}
