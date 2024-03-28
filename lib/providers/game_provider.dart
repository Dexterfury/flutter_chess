import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess/constants.dart';
import 'package:flutter_chess/helper/uci_commands.dart';
import 'package:flutter_chess/models/game_model.dart';
import 'package:flutter_chess/models/user_model.dart';
import 'package:squares/squares.dart';
import 'package:bishop/bishop.dart' as bishop;
import 'package:square_bishop/square_bishop.dart';
import 'package:stockfish/stockfish.dart';
import 'package:uuid/uuid.dart';

class GameProvider extends ChangeNotifier {
  late bishop.Game _game = bishop.Game(variant: bishop.Variant.standard());
  late SquaresState _state = SquaresState.initial(0);
  bool _aiThinking = false;
  bool _flipBoard = false;
  bool _vsComputer = false;
  bool _isLoading = false;
  bool _playWhitesTimer = true;
  bool _playBlacksTimer = true;
  int _gameLevel = 1;
  int _incrementalValue = 0;
  int _player = Squares.white;
  Timer? _whitesTimer;
  Timer? _blacksTimer;
  int _whitesScore = 0;
  int _blacksSCore = 0;
  PlayerColor _playerColor = PlayerColor.white;
  GameDifficulty _gameDifficulty = GameDifficulty.easy;
  String _gameId = '';

  String get gameId => _gameId;

  Duration _whitesTime = Duration.zero;
  Duration _blacksTime = Duration.zero;

  // saved time
  Duration _savedWhitesTime = Duration.zero;
  Duration _savedBlacksTime = Duration.zero;

  bool get playWhitesTimer => _playWhitesTimer;
  bool get playBlacksTimer => _playBlacksTimer;

  int get whitesScore => _whitesScore;
  int get blacksScore => _blacksSCore;

  Timer? get whitesTimer => _whitesTimer;
  Timer? get blacksTimer => _blacksTimer;

  bishop.Game get game => _game;
  SquaresState get state => _state;
  bool get aiThinking => _aiThinking;
  bool get flipBoard => _flipBoard;

  int get gameLevel => _gameLevel;
  GameDifficulty get gameDifficulty => _gameDifficulty;

  int get incrementalValue => _incrementalValue;
  int get player => _player;
  PlayerColor get playerColor => _playerColor;

  Duration get whitesTime => _whitesTime;
  Duration get blacksTime => _blacksTime;

  Duration get savedWhitesTime => _savedWhitesTime;
  Duration get savedBlacksTime => _savedBlacksTime;

  // get method
  bool get vsComputer => _vsComputer;
  bool get isLoading => _isLoading;

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  // set play whitesTimer
  Future<void> setPlayWhitesTimer({required bool value}) async {
    _playWhitesTimer = value;
    notifyListeners();
  }

  // set play blacksTimer
  Future<void> setPlayBlactsTimer({required bool value}) async {
    _playBlacksTimer = value;
    notifyListeners();
  }

  // get position fen
  getPositionFen() {
    return game.fen;
  }

  // reset game
  void resetGame({required bool newGame}) {
    if (newGame) {
      // check if the player was white in the previous game
      // change the player
      if (_player == Squares.white) {
        _player = Squares.black;
      } else {
        _player = Squares.white;
      }
      notifyListeners();
    }
    // reset game
    _game = bishop.Game(variant: bishop.Variant.standard());
    _state = game.squaresState(_player);
  }

  // make squre move
  bool makeSquaresMove(Move move) {
    bool result = game.makeSquaresMove(move);
    notifyListeners();
    return result;
  }

  // make squre move
  bool makeStringMove(String bestMove) {
    bool result = game.makeMoveString(bestMove);
    notifyListeners();
    return result;
  }

  // set sqaures state
  Future<void> setSquaresState() async {
    _state = game.squaresState(player);
    notifyListeners();
  }

  // make random move
  void makeRandomMove() {
    _game.makeRandomMove();
    notifyListeners();
  }

  void flipTheBoard() {
    _flipBoard = !_flipBoard;
    notifyListeners();
  }

  void setAiThinking(bool value) {
    _aiThinking = value;
    notifyListeners();
  }

  // set incremental value
  void setIncrementalValue({required int value}) {
    _incrementalValue = value;
    notifyListeners();
  }

  // set vs computer
  void setVsComputer({required bool value}) {
    _vsComputer = value;
    notifyListeners();
  }

  void setIsLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  // set game time
  Future<void> setGameTime({
    required String newSavedWhitesTime,
    required String newSavedBlacksTime,
  }) async {
    // save the times
    _savedWhitesTime = Duration(minutes: int.parse(newSavedWhitesTime));
    _savedBlacksTime = Duration(minutes: int.parse(newSavedBlacksTime));
    notifyListeners();
    // set times
    setWhitesTime(_savedWhitesTime);
    setBlacksTime(_savedBlacksTime);
  }

  void setWhitesTime(Duration time) {
    _whitesTime = time;
    notifyListeners();
  }

  void setBlacksTime(Duration time) {
    _blacksTime = time;
    notifyListeners();
  }

  // set playerColor
  void setPlayerColor({required int player}) {
    _player = player;
    _playerColor =
        player == Squares.white ? PlayerColor.white : PlayerColor.black;
    notifyListeners();
  }

  // set difficulty
  void setGameDifficulty({required int level}) {
    _gameLevel = level;
    _gameDifficulty = level == 1
        ? GameDifficulty.easy
        : level == 2
            ? GameDifficulty.medium
            : GameDifficulty.hard;
    notifyListeners();
  }

  // pause whites timer
  void pauseWhitesTimer() {
    if (_whitesTimer != null) {
      _whitesTime += Duration(seconds: _incrementalValue);
      _whitesTimer!.cancel();
      notifyListeners();
    }
  }

  // pause blacks timer
  void pauseBlacksTimer() {
    if (_blacksTimer != null) {
      _blacksTime += Duration(seconds: _incrementalValue);
      _blacksTimer!.cancel();
      notifyListeners();
    }
  }

  // start blacks timer
  void startBlacksTimer({
    required BuildContext context,
    Stockfish? stockfish,
    required Function onNewGame,
  }) {
    _blacksTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _blacksTime = _blacksTime - const Duration(seconds: 1);
      notifyListeners();

      if (_blacksTime <= Duration.zero) {
        // blacks timeout - black has lost the game
        _blacksTimer!.cancel();
        notifyListeners();

        // show game over dialog
        if (context.mounted) {
          gameOverDialog(
            context: context,
            stockfish: stockfish,
            timeOut: true,
            whiteWon: true,
            onNewGame: onNewGame,
          );
        }
      }
    });
  }

  // start blacks timer
  void startWhitesTimer({
    required BuildContext context,
    Stockfish? stockfish,
    required Function onNewGame,
  }) {
    _whitesTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _whitesTime = _whitesTime - const Duration(seconds: 1);
      notifyListeners();

      if (_whitesTime <= Duration.zero) {
        // whites timeout - white has lost the game
        _whitesTimer!.cancel();
        notifyListeners();

        // show game over dialog
        if (context.mounted) {
          gameOverDialog(
            context: context,
            stockfish: stockfish,
            timeOut: true,
            whiteWon: false,
            onNewGame: onNewGame,
          );
        }
      }
    });
  }

  void gameOverListerner({
    required BuildContext context,
    Stockfish? stockfish,
    required Function onNewGame,
  }) {
    if (game.gameOver) {
      // pause the timers
      pauseWhitesTimer();
      pauseBlacksTimer();

      // cancel the gameStreamsubscription if its not null
      if (gameStreamSubScreiption != null) {
        gameStreamSubScreiption!.cancel();
      }

      // show game over dialog
      if (context.mounted) {
        gameOverDialog(
          context: context,
          stockfish: stockfish,
          timeOut: false,
          whiteWon: false,
          onNewGame: onNewGame,
        );
      }
    }
  }

  // game over dialog
  void gameOverDialog({
    required BuildContext context,
    Stockfish? stockfish,
    required bool timeOut,
    required bool whiteWon,
    required Function onNewGame,
  }) {
    // stop stockfish engine
    if (stockfish != null) {
      stockfish.stdin = UCICommands.stop;
    }
    String resultsToShow = '';
    int whitesScoresToShow = 0;
    int blacksSCoresToShow = 0;

    // check if its a timeOut
    if (timeOut) {
      // check who has won and increment the results accordingly
      if (whiteWon) {
        resultsToShow = 'White won on time';
        whitesScoresToShow = _whitesScore + 1;
      } else {
        resultsToShow = 'Black won on time';
        blacksSCoresToShow = _blacksSCore + 1;
      }
    } else {
      // its not a timeOut
      resultsToShow = game.result!.readable;

      if (game.drawn) {
        // game is a draw
        String whitesResults = game.result!.scoreString.split('-').first;
        String blacksResults = game.result!.scoreString.split('-').last;
        whitesScoresToShow = _whitesScore += int.parse(whitesResults);
        blacksSCoresToShow = _blacksSCore += int.parse(blacksResults);
      } else if (game.winner == 0) {
        // meaning white is the winner
        String whitesResults = game.result!.scoreString.split('-').first;
        whitesScoresToShow = _whitesScore += int.parse(whitesResults);
      } else if (game.winner == 1) {
        // meaning black is the winner
        String blacksResults = game.result!.scoreString.split('-').last;
        blacksSCoresToShow = _blacksSCore += int.parse(blacksResults);
      } else if (game.stalemate) {
        whitesScoresToShow = whitesScore;
        blacksSCoresToShow = blacksScore;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Game Over\n $whitesScoresToShow - $blacksSCoresToShow',
          textAlign: TextAlign.center,
        ),
        content: Text(
          resultsToShow,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // navigate to home screen
              Navigator.pushNamedAndRemoveUntil(
                context,
                Constants.homeScreen,
                (route) => false,
              );
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // reset the game
            },
            child: const Text(
              'New Game',
            ),
          ),
        ],
      ),
    );
  }

  String _waitingText = '';

  String get waitingText => _waitingText;

  setWaitingText() {
    _waitingText = '';
    notifyListeners();
  }

  // search for player
  Future searchPlayer({
    required UserModel userModel,
    required Function() onSuccess,
    required Function(String) onFail,
  }) async {
    try {
      // get all available games
      final availableGames =
          await firebaseFirestore.collection(Constants.availableGames).get();

      //check if there are any available games
      if (availableGames.docs.isNotEmpty) {
        final List<DocumentSnapshot> gamesList = availableGames.docs
            .where((element) => element[Constants.isPlaying] == false)
            .toList();

        // check if there are no games where isPlaying == false
        if (gamesList.isEmpty) {
          _waitingText = Constants.searchingPlayerText;
          notifyListeners();
          // create a new game
          createNewGameInFireStore(
            userModel: userModel,
            onSuccess: onSuccess,
            onFail: onFail,
          );
        } else {
          _waitingText = Constants.joiningGameText;
          notifyListeners();
          // join a game
          joinGame(
            game: gamesList.first,
            userModel: userModel,
            onSuccess: onSuccess,
            onFail: onFail,
          );
        }
      } else {
        _waitingText = Constants.searchingPlayerText;
        notifyListeners();
        // we don not have any available games - create a game
        createNewGameInFireStore(
          userModel: userModel,
          onSuccess: onSuccess,
          onFail: onFail,
        );
      }
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      onFail(e.toString());
    }
  }

  // create a game
  void createNewGameInFireStore({
    required UserModel userModel,
    required Function onSuccess,
    required Function(String) onFail,
  }) async {
    // create a game id
    _gameId = const Uuid().v4();
    notifyListeners();

    try {
      await firebaseFirestore
          .collection(Constants.availableGames)
          .doc(userModel.uid)
          .set({
        Constants.uid: '',
        Constants.name: '',
        Constants.photoUrl: '',
        Constants.userRating: 1200,
        Constants.gameCreatorUid: userModel.uid,
        Constants.gameCreatorName: userModel.name,
        Constants.gameCreatorImage: userModel.image,
        Constants.gameCreatorRating: userModel.playerRating,
        Constants.isPlaying: false,
        Constants.gameId: gameId,
        Constants.dateCreated: DateTime.now().microsecondsSinceEpoch.toString(),
        Constants.whitesTime: _savedWhitesTime.toString(),
        Constants.blacksTime: _savedBlacksTime.toString(),
      });

      onSuccess();
    } on FirebaseException catch (e) {
      onFail(e.toString());
    }
  }

  String _gameCreatorUid = '';
  String _gameCreatorName = '';
  String _gameCreatorPhoto = '';
  int _gameCreatorRating = 1200;
  String _userId = '';
  String _userName = '';
  String _userPhoto = '';
  int _userRating = 1200;

  String get gameCreatorUid => _gameCreatorUid;
  String get gameCreatorName => _gameCreatorName;
  String get gameCreatorPhoto => _gameCreatorPhoto;
  int get gameCreatorRating => _gameCreatorRating;
  String get userId => _userId;
  String get userName => _userName;
  String get userPhoto => _userPhoto;
  int get userRating => _userRating;

  // join game
  void joinGame({
    required DocumentSnapshot<Object?> game,
    required UserModel userModel,
    required Function() onSuccess,
    required Function(String) onFail,
  }) async {
    try {
      // get our created game
      final myGame = await firebaseFirestore
          .collection(Constants.availableGames)
          .doc(userModel.uid)
          .get();

      // get data from the game we are joining
      _gameCreatorUid = game[Constants.gameCreatorUid];
      _gameCreatorName = game[Constants.gameCreatorName];
      _gameCreatorPhoto = game[Constants.gameCreatorImage];
      _gameCreatorRating = game[Constants.gameCreatorRating];
      _userId = userModel.uid;
      _userName = userModel.name;
      _userPhoto = userModel.image;
      _userRating = userModel.playerRating;
      _gameId = game[Constants.gameId];
      notifyListeners();

      if (myGame.exists) {
        // delete our created game since we are joing another game
        await myGame.reference.delete();
      }

      // initialize the gameModel
      final gameModel = GameModel(
        gameId: gameId,
        gameCreatorUid: _gameCreatorUid,
        userId: userId,
        positonFen: getPositionFen(),
        winnerId: '',
        whitesTime: game[Constants.whitesTime],
        blacksTime: game[Constants.blacksTime],
        whitsCurrentMove: '',
        blacksCurrentMove: '',
        boardState: state.board.flipped().toString(),
        playState: PlayState.ourTurn.name.toString(),
        isWhitesTurn: true,
        isGameOver: false,
        squareState: state.player,
        moves: state.moves.toList(),
      );

      // create a game controller directory in fireStore
      await firebaseFirestore
          .collection(Constants.runningGames)
          .doc(gameId)
          .collection(Constants.game)
          .doc(gameId)
          .set(gameModel.toMap());

      // create a new game directory in fireStore
      await firebaseFirestore
          .collection(Constants.runningGames)
          .doc(gameId)
          .set({
        Constants.gameCreatorUid: gameCreatorUid,
        Constants.gameCreatorName: gameCreatorName,
        Constants.gameCreatorImage: gameCreatorPhoto,
        Constants.gameCreatorRating: gameCreatorRating,
        Constants.userId: userId,
        Constants.userName: userName,
        Constants.userImage: userPhoto,
        Constants.userRating: userRating,
        Constants.isPlaying: true,
        Constants.dateCreated: DateTime.now().microsecondsSinceEpoch.toString(),
        Constants.gameScore: '0-0',
      });

      // update game settings depending on the data of the game we are joining
      await setGameDataAndSettings(game: game, userModel: userModel);

      onSuccess();
    } on FirebaseException catch (e) {
      onFail(e.toString());
    }
  }

  StreamSubscription? isPlayingStreamSubScription;

  // chech if the other player has joined
  void checkIfOpponentJoined({
    required UserModel userModel,
    required Function() onSuccess,
  }) async {
    // stream firestore if the player has joined
    isPlayingStreamSubScription = firebaseFirestore
        .collection(Constants.availableGames)
        .doc(userModel.uid)
        .snapshots()
        .listen((event) async {
      // chech if the game exist
      if (event.exists) {
        final DocumentSnapshot game = event;

        // chech if itsPlaying == true
        if (game[Constants.isPlaying]) {
          isPlayingStreamSubScription!.cancel();
          await Future.delayed(const Duration(milliseconds: 100));
          // get data from the game we are joining
          _gameCreatorUid = game[Constants.gameCreatorUid];
          _gameCreatorName = game[Constants.gameCreatorName];
          _gameCreatorPhoto = game[Constants.gameCreatorImage];
          _userId = game[Constants.uid];
          _userName = game[Constants.name];
          _userPhoto = game[Constants.photoUrl];

          setPlayerColor(player: 0);
          notifyListeners();

          onSuccess();
        }
      }
    });
  }

  // set game data and settings
  Future<void> setGameDataAndSettings({
    required DocumentSnapshot<Object?> game,
    required UserModel userModel,
  }) async {
    // get reference to the game we are joining
    final opponentsGame = firebaseFirestore
        .collection(Constants.availableGames)
        .doc(game[Constants.gameCreatorUid]);

    // time - 0:10:00.0000000
    List<String> whitesTimeParts = game[Constants.whitesTime].split(':');
    List<String> blacksTimeParts = game[Constants.blacksTime].split(':');

    int whitesGameTime =
        int.parse(whitesTimeParts[0]) * 60 + int.parse(whitesTimeParts[1]);
    int blacksGamesTime =
        int.parse(blacksTimeParts[0]) * 60 + int.parse(blacksTimeParts[1]);

    // set game time
    await setGameTime(
      newSavedWhitesTime: whitesGameTime.toString(),
      newSavedBlacksTime: blacksGamesTime.toString(),
    );

    // update the created game in fireStore
    await opponentsGame.update({
      Constants.isPlaying: true,
      Constants.uid: userModel.uid,
      Constants.name: userModel.name,
      Constants.photoUrl: userModel.image,
      Constants.userRating: userModel.playerRating,
    });

    // set the player state
    setPlayerColor(player: 1);
    notifyListeners();
  }

  bool _isWhitesTurn = true;
  String blacksMove = '';
  String whitesMove = '';

  bool get isWhitesTurn => _isWhitesTurn;

  StreamSubscription? gameStreamSubScreiption;

  // listen for game changes in fireStore
  Future<void> listenForGameChanges({
    required BuildContext context,
    required UserModel userModel,
  }) async {
    CollectionReference gameCollectionReference = firebaseFirestore
        .collection(Constants.runningGames)
        .doc(gameId)
        .collection(Constants.game);

    gameStreamSubScreiption =
        gameCollectionReference.snapshots().listen((event) {
      if (event.docs.isNotEmpty) {
        // get the game
        final DocumentSnapshot game = event.docs.first;

        // check if we are white - this means we are the game creator
        if (game[Constants.gameCreatorUid] == userModel.uid) {
          // check if is white's turn
          if (game[Constants.isWhitesTurn]) {
            _isWhitesTurn = true;

            // check if blacksCurrentMove is not empty or equal the old move - means black has played his move
            // this means its our tuen to play
            if (game[Constants.blacksCurrentMove] != blacksMove) {
              // update the whites UI

              Move convertedMove = convertMoveStringToMove(
                moveString: game[Constants.blacksCurrentMove],
              );

              bool result = makeSquaresMove(convertedMove);
              if (result) {
                setSquaresState().whenComplete(() {
                  pauseBlacksTimer();
                  startWhitesTimer(context: context, onNewGame: () {});

                  gameOverListerner(context: context, onNewGame: () {});
                });
              }
            }
            notifyListeners();
          }
        } else {
          // not the game creator
          _isWhitesTurn = false;

          // check is white played his move
          if (game[Constants.whitsCurrentMove] != whitesMove) {
            Move convertedMove = convertMoveStringToMove(
              moveString: game[Constants.whitsCurrentMove],
            );
            bool result = makeSquaresMove(convertedMove);

            if (result) {
              setSquaresState().whenComplete(() {
                pauseWhitesTimer();
                startBlacksTimer(context: context, onNewGame: () {});

                gameOverListerner(context: context, onNewGame: () {});
              });
            }
          }
          notifyListeners();
        }
      }
    });
  }

  // convert move string to move format
  Move convertMoveStringToMove({required String moveString}) {
    // Split the move string intp its components
    List<String> parts = moveString.split('-');

    // Extract 'from' and 'to'
    int from = int.parse(parts[0]);
    int to = int.parse(parts[1].split('[')[0]);

    // Extract 'promo' and 'piece' if available
    String? promo;
    String? piece;
    if (moveString.contains('[')) {
      String extras = moveString.split('[')[1].split(']')[0];
      List<String> extraList = extras.split(',');
      promo = extraList[0];
      if (extraList.length > 1) {
        piece = extraList[1];
      }
    }

    // Create and return a new Move object
    return Move(
      from: from,
      to: to,
      promo: promo,
      piece: piece,
    );
  }

  // play move and save to fireStore
  Future<void> playMoveAndSaveToFireStore({
    required BuildContext context,
    required Move move,
    required bool isWhitesMove,
  }) async {
    // check if its whites move
    if (isWhitesMove) {
      await firebaseFirestore
          .collection(Constants.runningGames)
          .doc(gameId)
          .collection(Constants.game)
          .doc(gameId)
          .update({
        Constants.positonFen: getPositionFen(),
        Constants.whitsCurrentMove: move.toString(),
        Constants.moves: FieldValue.arrayUnion([move.toString()]),
        Constants.isWhitesTurn: false,
        Constants.playState: PlayState.theirTurn.name.toString(),
      });

      // pause whites timer and start blacks timer
      pauseWhitesTimer();

      Future.delayed(const Duration(milliseconds: 100)).whenComplete(() {
        startBlacksTimer(
          context: context,
          onNewGame: () {},
        );
      });
    } else {
      await firebaseFirestore
          .collection(Constants.runningGames)
          .doc(gameId)
          .collection(Constants.game)
          .doc(gameId)
          .update({
        Constants.positonFen: getPositionFen(),
        Constants.blacksCurrentMove: move.toString(),
        Constants.moves: FieldValue.arrayUnion([move.toString()]),
        Constants.isWhitesTurn: true,
        Constants.playState: PlayState.ourTurn.name.toString(),
      });

      // pause blacks timer and start whites timer
      pauseBlacksTimer();

      Future.delayed(const Duration(milliseconds: 100)).whenComplete(() {
        startWhitesTimer(
          context: context,
          onNewGame: () {},
        );
      });
    }
  }
}
