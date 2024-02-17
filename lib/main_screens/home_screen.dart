import 'package:flutter/material.dart';
import 'package:flutter_chess/helper/helper_methods.dart';
import 'package:flutter_chess/main_screens/about_screen.dart';
import 'package:flutter_chess/main_screens/game_time_screen.dart';
import 'package:flutter_chess/main_screens/settings_screen.dart';
import 'package:flutter_chess/providers/game_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Flutter Chess',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          children: [
            buildGameType(
              lable: 'Play vs Computer',
              icon: Icons.computer,
              onTap: () {
                gameProvider.setVsComputer(value: true);
                // navigate to setup game time screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GameTimeScreen(),
                  ),
                );
              },
            ),
            buildGameType(
              lable: 'Play vs Friend',
              icon: Icons.person,
              onTap: () {
                gameProvider.setVsComputer(value: false);
                // navigate to setup game time screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GameTimeScreen(),
                  ),
                );
              },
            ),
            buildGameType(
              lable: 'Settings',
              icon: Icons.settings,
              onTap: () {
                // navigate to settings screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            buildGameType(
              lable: 'About',
              icon: Icons.info,
              onTap: () {
                // navigate to about screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
