class Routes {
  Routes._();

  static const home = '/';
  static const preGame = '/new-game';
  static const game = '/game';
  static const gameWin = '/game/win';
  static const settings = '/settings';
  static const history = '/history';

  static String historyDetail(String gameId) => '/history/$gameId';
}
