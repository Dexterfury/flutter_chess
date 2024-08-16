import 'package:flutter/material.dart';
import 'package:flutter_chess/constants.dart';
import 'package:flutter_chess/providers/game_provider.dart';
import 'package:flutter_chess/widgets/widgets.dart';
import 'package:provider/provider.dart';

class GameStartUpScreen extends StatefulWidget {
  const GameStartUpScreen({
    Key? key,
    required this.isCustomTime,
    required this.gameTime,
  }) : super(key: key);

  final bool isCustomTime;
  final String gameTime;

  @override
  State<GameStartUpScreen> createState() => _GameStartUpScreenState();
}

class _GameStartUpScreenState extends State<GameStartUpScreen> {
  int whiteTimeInMinutes = 0;
  int blackTimeInMinutes = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 244, 225),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 244, 225),
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Game Setup',
                style: TextStyle(
                  fontSize: 24,
                  color: const Color.fromARGB(255, 76, 50, 35),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const SettingsScreen(),
                  //   ),
                  // );
                },
              ),
            ],
          ),
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: PlayerColorRadioButton(
                        title: 'Play as ${PlayerColor.white.name}',
                        value: PlayerColor.white,
                        groupValue: gameProvider.playerColor,
                        onChanged: (value) {
                          gameProvider.setPlayerColor(player: 0);
                        },
                      ),
                    ),
                    widget.isCustomTime
                        ? BuildCustomTime(
                            time: whiteTimeInMinutes.toString(),
                            onLeftArrowCricked: () {
                              setState(() {
                                whiteTimeInMinutes--;
                              });
                            },
                            onRightArrowCricked: () {
                              setState(() {
                                whiteTimeInMinutes++;
                              });
                            },
                          )
                        : Container(
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: const Color.fromARGB(255, 76, 50, 35),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Center(
                                child: Text(
                                  widget.gameTime,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Color.fromARGB(255, 76, 50, 35),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: PlayerColorRadioButton(
                        title: 'Play as ${PlayerColor.black.name}',
                        value: PlayerColor.black,
                        groupValue: gameProvider.playerColor,
                        onChanged: (value) {
                          gameProvider.setPlayerColor(player: 1);
                        },
                      ),
                    ),
                    widget.isCustomTime
                        ? BuildCustomTime(
                            time: blackTimeInMinutes.toString(),
                            onLeftArrowCricked: () {
                              setState(() {
                                blackTimeInMinutes--;
                              });
                            },
                            onRightArrowCricked: () {
                              setState(() {
                                blackTimeInMinutes++;
                              });
                            },
                          )
                        : Container(
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: const Color.fromARGB(255, 76, 50, 35),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Center(
                                child: Text(
                                  widget.gameTime,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Color.fromARGB(255, 76, 50, 35),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
                const SizedBox(height: 40),
                gameProvider.vsComputer
                    ? Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'Game Difficulty',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 28,
                                color: Color.fromARGB(255, 76, 50, 35),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: GameLevelRadioButton(
                                    title: GameDifficulty.easy.name,
                                    value: GameDifficulty.easy,
                                    groupValue: gameProvider.gameDifficulty,
                                    onChanged: (value) {
                                      gameProvider.setGameDifficulty(level: 1);
                                    }),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: GameLevelRadioButton(
                                    title: GameDifficulty.easy.name,
                                    value: GameDifficulty.easy,
                                    groupValue: gameProvider.gameDifficulty,
                                    onChanged: (value) {
                                      gameProvider.setGameDifficulty(level: 1);
                                    }),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: GameLevelRadioButton(
                                    title: GameDifficulty.easy.name,
                                    value: GameDifficulty.easy,
                                    groupValue: gameProvider.gameDifficulty,
                                    onChanged: (value) {
                                      gameProvider.setGameDifficulty(level: 1);
                                    }),
                              ),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 20),
                gameProvider.isLoading
                    ? const LinearProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          //playGame(gameProvider: gameProvider);
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 10,
                          backgroundColor:
                              const Color.fromARGB(255, 76, 50, 35),
                          textStyle: TextStyle(fontSize: 20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'Play',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 220, 204, 179),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                gameProvider.vsComputer
                    ? const SizedBox.shrink()
                    : Text(
                        gameProvider.waitingText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 76, 50, 35),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  // void playGame({required GameProvider gameProvider}) async {
  //   final userModel = context.read<AuthenticationProvider>().userModel;
  //   if (widget.isCustomTime) {
  //     if (whiteTimeInMinutes <= 0 || blackTimeInMinutes <= 0) {
  //       showSnackBar(context: context, content: 'Time cannot be 0');
  //       return;
  //     }

  //     gameProvider.setIsLoading(value: true);

  //     await gameProvider
  //         .setGameTime(
  //       newSavedWhitesTime: whiteTimeInMinutes.toString(),
  //       newSavedBlacksTime: blackTimeInMinutes.toString(),
  //     )
  //         .whenComplete(() {
  //       if (gameProvider.vsComputer) {
  //         gameProvider.setIsLoading(value: false);
  //         Navigator.pushNamed(context, Constants.gameScreen);
  //       } else {
  //         // search for players
  //       }
  //     });
  //   } else {
  //     final String incrementalTime = widget.gameTime.split('+')[1];
  //     final String gameTime = widget.gameTime.split('+')[0];

  //     if (incrementalTime != '0') {
  //       gameProvider.setIncrementalValue(value: int.parse(incrementalTime));
  //     }

  //     gameProvider.setIsLoading(value: true);

  //     await gameProvider
  //         .setGameTime(
  //       newSavedWhitesTime: gameTime,
  //       newSavedBlacksTime: gameTime,
  //     )
  //         .whenComplete(() {
  //       if (gameProvider.vsComputer) {
  //         gameProvider.setIsLoading(value: false);
  //         Navigator.pushNamed(context, Constants.gameScreen);
  //       } else {
  //         gameProvider.searchPlayer(
  //           userModel: userModel!,
  //           onSuccess: () {
  //             if (gameProvider.waitingText == Constants.searchingPlayerText) {
  //               gameProvider.checkIfOpponentJoined(
  //                 userModel: userModel,
  //                 onSuccess: () {
  //                   gameProvider.setIsLoading(value: false);
  //                   Navigator.pushNamed(context, Constants.gameScreen);
  //                 },
  //               );
  //             } else {
  //               gameProvider.setIsLoading(value: false);
  //               Navigator.pushNamed(context, Constants.gameScreen);
  //             }
  //           },
  //           onFail: (error) {
  //             gameProvider.setIsLoading(value: false);
  //             showSnackBar(context: context, content: error);
  //           },
  //         );
  //       }
  //     });
  //   }
  // }
}
