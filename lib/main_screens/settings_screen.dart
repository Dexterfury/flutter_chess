import 'package:flutter/material.dart';
import 'package:flutter_chess/constants.dart';
import 'package:flutter_chess/providers/authentication_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          // logout button
          IconButton(
            onPressed: () {
              context
                  .read<AuthenticationProvider>()
                  .signOutUser()
                  .whenComplete(() {
                // navigate to the login screen
                Navigator.pushNamedAndRemoveUntil(
                    context, Constants.loginScreen, (route) => false);
              });
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(child: Text('Seetings Screen')),
    );
  }
}
