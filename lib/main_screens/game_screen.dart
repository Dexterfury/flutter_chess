import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chess/constants.dart';
import 'package:flutter_chess/helper/helper_methods.dart';
import 'package:flutter_chess/helper/uci_commands.dart';
import 'package:flutter_chess/models/user_model.dart';
import 'package:flutter_chess/providers/authentication_provider.dart';
import 'package:flutter_chess/providers/game_provider.dart';
import 'package:flutter_chess/service/assets_manager.dart';
import 'package:provider/provider.dart';

import 'package:squares/squares.dart';
import 'package:stockfish/stockfish.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Stockfish stockfish;

  @override
  void initState() {
    //stockfish = Stockfish();
    final gameProvider = context.read<GameProvider>();
    gameProvider.resetGame(newGame: false);

    if (mounted) {
      //letOtherPlayerPlayFirst();
    }
    super.initState();
  }

  @override
  void dispose() {
    stockfish.dispose();
    super.dispose();
  }

  void letOtherPlayerPlayFirst() {
    // wait for widget to rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gameProvider = context.read<GameProvider>();

      if (gameProvider.vsComputer) {
        if (gameProvider.state.state == PlayState.theirTurn &&
            !gameProvider.aiThinking) {
          gameProvider.setAiThinking(true);

          // wait auntil stockfish is ready
          await waitUntilReady();

          // get the current position of the board and sent to stockfish
          stockfish.stdin =
              '${UCICommands.position} ${gameProvider.getPositionFen()}';

          // set stockfish level
          stockfish.stdin =
              '${UCICommands.goMoveTime} ${gameProvider.gameLevel * 1000}';

          stockfish.stdout.listen((event) {
            if (event.contains(UCICommands.bestMove)) {
              final bestMove = event.split(' ')[1];
              gameProvider.makeStringMove(bestMove);
              gameProvider.setAiThinking(false);
              gameProvider.setSquaresState().whenComplete(() {
                if (gameProvider.player == Squares.white) {
                  // check if we can play whitesTimer
                  if (gameProvider.playWhitesTimer) {
                    // pause timer for black
                    gameProvider.pauseBlacksTimer();

                    startTimer(
                      isWhiteTimer: true,
                      onNewGame: () {},
                    );

                    gameProvider.setPlayWhitesTimer(value: false);
                  }
                } else {
                  if (gameProvider.playBlacksTimer) {
                    // pause timer for white
                    gameProvider.pauseWhitesTimer();

                    startTimer(
                      isWhiteTimer: false,
                      onNewGame: () {},
                    );

                    gameProvider.setPlayBlactsTimer(value: false);
                  }
                }
              });
            }
          });
        }
      } else {
        final userModel = context.read<AuthenticationProvider>().userModel;
        // listen for game changes in fireStore
        gameProvider.listenForGameChanges(
            context: context, userModel: userModel!);
      }
    });
  }

  void _onMove(Move move) async {
    log('move: ${move.toString()}');
    log('String move: ${move.algebraic()}');
    final gameProvider = context.read<GameProvider>();
    bool result = gameProvider.makeSquaresMove(move);
    if (result) {
      gameProvider.setSquaresState().whenComplete(() async {
        if (gameProvider.player == Squares.white) {
          // check if we are playing vs computer
          if (gameProvider.vsComputer) {
            // pause timer for white
            gameProvider.pauseWhitesTimer();

            startTimer(
              isWhiteTimer: false,
              onNewGame: () {},
            );
            // set whites bool flag to true so that we dont run this code agin until true
            gameProvider.setPlayWhitesTimer(value: true);
          } else {
            // play and save white's move to fireStore
            await gameProvider.playMoveAndSaveToFireStore(
              context: context,
              move: move,
              isWhitesMove: true,
            );
          }
        } else {
          if (gameProvider.vsComputer) {
            // pause timer for black
            gameProvider.pauseBlacksTimer();

            startTimer(
              isWhiteTimer: true,
              onNewGame: () {},
            );
            // set blacks bool flag to true so that we dont run this code agin until true
            gameProvider.setPlayBlactsTimer(value: true);
          } else {
            // play and save black's move to fireStore
            await gameProvider.playMoveAndSaveToFireStore(
              context: context,
              move: move,
              isWhitesMove: false,
            );
          }
        }
      });
    }

    if (gameProvider.vsComputer) {
      if (gameProvider.state.state == PlayState.theirTurn &&
          !gameProvider.aiThinking) {
        gameProvider.setAiThinking(true);

        // wait auntil stockfish is ready
        await waitUntilReady();

        // get the current position of the board and sent to stockfish
        stockfish.stdin =
            '${UCICommands.position} ${gameProvider.getPositionFen()}';

        // set stockfish level
        stockfish.stdin =
            '${UCICommands.goMoveTime} ${gameProvider.gameLevel * 1000}';

        stockfish.stdout.listen((event) {
          if (event.contains(UCICommands.bestMove)) {
            final bestMove = event.split(' ')[1];
            gameProvider.makeStringMove(bestMove);
            gameProvider.setAiThinking(false);
            gameProvider.setSquaresState().whenComplete(() {
              if (gameProvider.player == Squares.white) {
                // check if we can play whitesTimer
                if (gameProvider.playWhitesTimer) {
                  // pause timer for black
                  gameProvider.pauseBlacksTimer();

                  startTimer(
                    isWhiteTimer: true,
                    onNewGame: () {},
                  );

                  gameProvider.setPlayWhitesTimer(value: false);
                }
              } else {
                if (gameProvider.playBlacksTimer) {
                  // pause timer for white
                  gameProvider.pauseWhitesTimer();

                  startTimer(
                    isWhiteTimer: false,
                    onNewGame: () {},
                  );

                  gameProvider.setPlayBlactsTimer(value: false);
                }
              }
            });
          }
        });

        // await Future.delayed(
        //     Duration(milliseconds: Random().nextInt(4750) + 250));
        // gameProvider.game.makeRandomMove();
        // gameProvider.setAiThinking(false);
        // gameProvider.setSquaresState().whenComplete(() {
        //   if (gameProvider.player == Squares.white) {
        //     // pause timer for black
        //     gameProvider.pauseBlacksTimer();

        //     startTimer(
        //       isWhiteTimer: true,
        //       onNewGame: () {},
        //     );
        //   } else {
        //     // pause timer for white
        //     gameProvider.pauseWhitesTimer();

        //     startTimer(
        //       isWhiteTimer: false,
        //       onNewGame: () {},
        //     );
        //   }
        // });
      }
    }

    await Future.delayed(const Duration(seconds: 1));
    // listen if its game over
    checkGameOverListener();
  }

  Future<void> waitUntilReady() async {
    while (stockfish.state.value != StockfishState.ready) {
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void checkGameOverListener() {
    final gameProvider = context.read<GameProvider>();

    gameProvider.gameOverListerner(
      context: context,
      stockfish: stockfish,
      onNewGame: () {
        // start new game
      },
    );
  }

  void startTimer({
    required bool isWhiteTimer,
    required Function onNewGame,
  }) {
    final gameProvider = context.read<GameProvider>();
    if (isWhiteTimer) {
      // start timer for White
      gameProvider.startWhitesTimer(
        context: context,
        stockfish: stockfish,
        onNewGame: onNewGame,
      );
    } else {
      // start timer for black
      gameProvider.startBlacksTimer(
        context: context,
        stockfish: stockfish,
        onNewGame: onNewGame,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    final userModel = context.read<AuthenticationProvider>().userModel;
    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) async {
        if (didpop) return;
        bool? leave = await _showExitConfirmDialog(context);
        if (leave != null && leave) {
          stockfish.stdin = UCICommands.stop;
          await Future.delayed(const Duration(milliseconds: 200))
              .whenComplete(() {
            // if the user confirms, navigate to home screen
            Navigator.pushNamedAndRemoveUntil(
                context, Constants.homeScreen, (route) => false);
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // leading: IconButton(
          //   icon: const Icon(
          //     Icons.arrow_back,
          //     color: Colors.white,
          //   ),
          //   onPressed: () {
          //     // TODO show dialog if sure
          //     Navigator.pop(context);
          //   },
          // ),
          backgroundColor: Colors.blue,
          title: const Text(
            'Flutter Chess',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () {
                gameProvider.resetGame(newGame: false);
              },
              icon: const Icon(Icons.start, color: Colors.white),
            ),
            IconButton(
              onPressed: () {
                gameProvider.flipTheBoard();
              },
              icon: const Icon(Icons.rotate_left, color: Colors.white),
            ),
          ],
        ),
        body: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            String whitesTimer = getTimerToDisplay(
              gameProvider: gameProvider,
              isUser: true,
            );
            String blacksTimer = getTimerToDisplay(
              gameProvider: gameProvider,
              isUser: false,
            );
            return Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // opponents data
                showOpponentsData(
                  gameProvider: gameProvider,
                  userModel: userModel!,
                  timeToShow: blacksTimer,
                ),

                gameProvider.vsComputer
                    ? Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: BoardController(
                          state: gameProvider.flipBoard
                              ? gameProvider.state.board.flipped()
                              : gameProvider.state.board,
                          playState: gameProvider.state.state,
                          pieceSet: PieceSet.merida(),
                          theme: BoardTheme.brown,
                          moves: gameProvider.state.moves,
                          onMove: _onMove,
                          onPremove: _onMove,
                          markerTheme: MarkerTheme(
                            empty: MarkerTheme.dot,
                            piece: MarkerTheme.corners(),
                          ),
                          promotionBehaviour: PromotionBehaviour.autoPremove,
                        ),
                      )
                    : buildChessBoard(
                        gameProvider: gameProvider,
                        userModel: userModel,
                      ),

                // our data
                ListTile(
                  leading: userModel.image == ''
                      ? CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage(AssetsManager.userIcon),
                        )
                      : CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(userModel.image),
                        ),
                  title: Text(userModel.name),
                  subtitle: Text('Rating: ${userModel.playerRating}'),
                  trailing: Text(
                    whitesTimer,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildChessBoard({
    required GameProvider gameProvider,
    required UserModel userModel,
  }) {
    bool isOurTurn = gameProvider.isWhitesTurn ==
        (gameProvider.gameCreatorUid == userModel.uid);

    log('CHESS UID: ${gameProvider.player}');

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: BoardController(
        state: gameProvider.flipBoard
            ? gameProvider.state.board.flipped()
            : gameProvider.state.board,
        playState: isOurTurn ? PlayState.ourTurn : PlayState.theirTurn,
        pieceSet: PieceSet.merida(),
        theme: BoardTheme.brown,
        moves: gameProvider.state.moves,
        onMove: _onMove,
        onPremove: _onMove,
        markerTheme: MarkerTheme(
          empty: MarkerTheme.dot,
          piece: MarkerTheme.corners(),
        ),
        promotionBehaviour: PromotionBehaviour.autoPremove,
      ),
    );
  }

  getState({required GameProvider gameProvider}) {
    if (gameProvider.flipBoard) {
      return gameProvider.state.board.flipped();
    } else {
      gameProvider.state.board;
    }
  }

  Widget showOpponentsData({
    required GameProvider gameProvider,
    required UserModel userModel,
    required String timeToShow,
  }) {
    if (gameProvider.vsComputer) {
      return ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage(AssetsManager.stockfishIcon),
        ),
        title: const Text('Stockfish'),
        subtitle: Text('Rating: ${gameProvider.gameLevel * 1000}'),
        trailing: Text(
          timeToShow,
          style: const TextStyle(fontSize: 16),
        ),
      );
    } else {
      // check is we are the creator of this game
      if (gameProvider.gameCreatorUid == userModel.uid) {
        return ListTile(
          leading: gameProvider.userPhoto == ''
              ? CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage(AssetsManager.userIcon),
                )
              : CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(gameProvider.userPhoto),
                ),
          title: Text(gameProvider.userName),
          subtitle: Text('Rating: ${gameProvider.userRating}'),
          trailing: Text(
            timeToShow,
            style: const TextStyle(fontSize: 16),
          ),
        );
      } else {
        return ListTile(
          leading: gameProvider.gameCreatorPhoto == ''
              ? CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage(AssetsManager.userIcon),
                )
              : CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(gameProvider.gameCreatorPhoto),
                ),
          title: Text(gameProvider.gameCreatorName),
          subtitle: Text('Rating: ${gameProvider.gameCreatorRating}'),
          trailing: Text(
            timeToShow,
            style: const TextStyle(fontSize: 16),
          ),
        );
      }
    }
  }

  Future<bool?> _showExitConfirmDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Leave Game?',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Are you sure to leave this game?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
