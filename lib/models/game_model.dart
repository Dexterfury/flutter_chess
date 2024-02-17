import 'package:flutter_chess/constants.dart';
import 'package:squares/squares.dart';

class GameModel {
  String gameId;
  String gameCreatorUid;
  String userId;
  String positonFen;
  String winnerId;
  String whitesTime;
  String blacksTime;
  String whitsCurrentMove;
  String blacksCurrentMove;
  String boardState;
  String playState;
  bool isWhitesTurn;
  bool isGameOver;
  int squareState;
  List<Move> moves;

  GameModel({
    required this.gameId,
    required this.gameCreatorUid,
    required this.userId,
    required this.positonFen,
    required this.winnerId,
    required this.whitesTime,
    required this.blacksTime,
    required this.whitsCurrentMove,
    required this.blacksCurrentMove,
    required this.boardState,
    required this.playState,
    required this.isWhitesTurn,
    required this.isGameOver,
    required this.squareState,
    required this.moves,
  });

  Map<String, dynamic> toMap() {
    return {
      Constants.gameId: gameId,
      Constants.gameCreatorUid: gameCreatorUid,
      Constants.userId: userId,
      Constants.positonFen: positonFen,
      Constants.winnerId: winnerId,
      Constants.whitesTime: whitesTime,
      Constants.blacksTime: blacksTime,
      Constants.whitsCurrentMove: whitsCurrentMove,
      Constants.blacksCurrentMove: blacksCurrentMove,
      Constants.boardState: boardState,
      Constants.playState: playState,
      Constants.isWhitesTurn: isWhitesTurn,
      Constants.isGameOver: isGameOver,
      Constants.squareState: squareState,
      Constants.moves: moves,
    };
  }

  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      gameId: map[Constants.gameId] ?? '',
      gameCreatorUid: map[Constants.gameCreatorUid] ?? '',
      userId: map[Constants.userId] ?? '',
      positonFen: map[Constants.positonFen] ?? '',
      winnerId: map[Constants.winnerId] ?? '',
      whitesTime: map[Constants.whitesTime] ?? '',
      blacksTime: map[Constants.blacksTime] ?? '',
      whitsCurrentMove: map[Constants.whitsCurrentMove] ?? '',
      blacksCurrentMove: map[Constants.blacksCurrentMove] ?? '',
      boardState: map[Constants.boardState] ?? '',
      playState: map[Constants.playState] ?? '',
      isWhitesTurn: map[Constants.isWhitesTurn] ?? false,
      isGameOver: map[Constants.isGameOver] ?? false,
      squareState: map[Constants.squareState] ?? 0,
      moves: List<Move>.from(map[Constants.moves] ?? []),
    );
  }
}
