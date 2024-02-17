import 'package:flutter/material.dart';
import 'package:flutter_chess/constants.dart';
import 'package:flutter_chess/providers/authentication_provider.dart';
import 'package:flutter_chess/providers/game_provider.dart';
import 'package:flutter_chess/widgets/widgets.dart';
import 'package:provider/provider.dart';

class GameStartUpScreen extends StatefulWidget {
  const GameStartUpScreen({
    super.key,
    required this.isCustomTime,
    required this.gameTime,
  });

  final bool isCustomTime;
  final String gameTime;

  @override
  State<GameStartUpScreen> createState() => _GameStartUpScreenState();
}

class _GameStartUpScreenState extends State<GameStartUpScreen> {
  PlayerColor playerColorGroup = PlayerColor.white;
  GameDifficulty gameLevelGroup = GameDifficulty.easy;

  int whiteTimeInMenutes = 0;
  int blackTimeInMenutes = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Setup Game',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // radioListTile
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            time: whiteTimeInMenutes.toString(),
                            onLeftArrowCricked: () {
                              setState(() {
                                whiteTimeInMenutes--;
                              });
                            },
                            onRightArrowCricked: () {
                              setState(() {
                                whiteTimeInMenutes++;
                              });
                            })
                        : Container(
                            height: 40,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.5, color: Colors.black),
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Center(
                                child: Text(
                                  widget.gameTime,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ),
                            ),
                          )
                  ],
                ),

                const SizedBox(
                  height: 10,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            time: blackTimeInMenutes.toString(),
                            onLeftArrowCricked: () {
                              setState(() {
                                blackTimeInMenutes--;
                              });
                            },
                            onRightArrowCricked: () {
                              setState(() {
                                blackTimeInMenutes++;
                              });
                            })
                        : Container(
                            height: 40,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.5, color: Colors.black),
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Center(
                                child: Text(
                                  widget.gameTime,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ),
                            ),
                          )
                  ],
                ),

                gameProvider.vsComputer
                    ? Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'Game Difficult',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              GameLevelRadioButton(
                                  title: GameDifficulty.easy.name,
                                  value: GameDifficulty.easy,
                                  groupValue: gameProvider.gameDifficulty,
                                  onChanged: (value) {
                                    gameProvider.setGameDifficulty(level: 1);
                                  }),
                              const SizedBox(
                                width: 10,
                              ),
                              GameLevelRadioButton(
                                  title: GameDifficulty.medium.name,
                                  value: GameDifficulty.medium,
                                  groupValue: gameProvider.gameDifficulty,
                                  onChanged: (value) {
                                    gameProvider.setGameDifficulty(level: 2);
                                  }),
                              const SizedBox(
                                width: 10,
                              ),
                              GameLevelRadioButton(
                                  title: GameDifficulty.hard.name,
                                  value: GameDifficulty.hard,
                                  groupValue: gameProvider.gameDifficulty,
                                  onChanged: (value) {
                                    gameProvider.setGameDifficulty(level: 3);
                                  }),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
                const SizedBox(
                  height: 20,
                ),

                gameProvider.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          // navigate to game screen
                          playGame(gameProvider: gameProvider);
                        },
                        child: Text('Play'),
                      ),

                const SizedBox(
                  height: 20,
                ),

                gameProvider.vsComputer
                    ? const SizedBox.shrink()
                    : Text(gameProvider.waitingText),
              ],
            ),
          );
        },
      ),
    );
  }

  void playGame({
    required GameProvider gameProvider,
  }) async {
    final userModel = context.read<AuthenticationProvider>().userModel;
    // check if is custome time
    if (widget.isCustomTime) {
      // check all timer are greater than 0
      if (whiteTimeInMenutes <= 0 || blackTimeInMenutes <= 0) {
        // show snackbar
        showSnackBar(context: context, content: 'Time cannot be 0');
        return;
      }

      // 1. start loading dialog
      gameProvider.setIsLoading(value: true);

      // 2. save time and player color for both players
      await gameProvider
          .setGameTime(
        newSavedWhitesTime: whiteTimeInMenutes.toString(),
        newSavedBlacksTime: blackTimeInMenutes.toString(),
      )
          .whenComplete(() {
        if (gameProvider.vsComputer) {
          gameProvider.setIsLoading(value: false);
          // 3. navigate to game screen
          Navigator.pushNamed(context, Constants.gameScreen);
        } else {
          // search for players
        }
      });
    } else {
      // not custom time
      // check if its incremental time
      // get the value after the + sign
      final String incrementalTime = widget.gameTime.split('+')[1];

      // get the value before the + sign
      final String gameTime = widget.gameTime.split('+')[0];

      // check if incremental is equal to 0
      if (incrementalTime != '0') {
        // save the incremental value
        gameProvider.setIncrementalValue(value: int.parse(incrementalTime));
      }

      gameProvider.setIsLoading(value: true);

      await gameProvider
          .setGameTime(
        newSavedWhitesTime: gameTime,
        newSavedBlacksTime: gameTime,
      )
          .whenComplete(() {
        if (gameProvider.vsComputer) {
          gameProvider.setIsLoading(value: false);
          // 3. navigate to game screen
          Navigator.pushNamed(context, Constants.gameScreen);
        } else {
          // search for players
          gameProvider.searchPlayer(
              userModel: userModel!,
              onSuccess: () {
                if (gameProvider.waitingText == Constants.searchingPlayerText) {
                  gameProvider.checkIfOpponentJoined(
                    userModel: userModel,
                    onSuccess: () {
                      gameProvider.setIsLoading(value: false);
                      Navigator.pushNamed(context, Constants.gameScreen);
                    },
                  );
                } else {
                  gameProvider.setIsLoading(value: false);
                  // navigate to gameScreen
                  Navigator.pushNamed(context, Constants.gameScreen);
                }
              },
              onFail: (error) {
                gameProvider.setIsLoading(value: false);
                showSnackBar(context: context, content: error);
              });
        }
      });
    }
  }
}
