import 'dart:math';
import '../models/match_model.dart';

class MockService {
  static final Random _random = Random();

  static List<MatchData> getMatchesForDate(DateTime date) {
    // Generate 10-20 random matches
    int matchCount = 10 + _random.nextInt(10);
    List<MatchData> matches = [];

    List<String> leagues = [
      "Premier League", "La Liga", "Serie A", "Bundesliga", "Ligue 1", 
      "Eredivisie", "Primeira Liga", "Brasileirão", "MLS"
    ];

    List<String> teams = [
      "Arsenal", "Aston Villa", "Bournemouth", "Brentford", "Brighton", "Chelsea", 
      "Crystal Palace", "Everton", "Fulham", "Liverpool", "Man City", "Man Utd", 
      "Newcastle", "Nottm Forest", "Southampton", "Spurs", "West Ham", "Wolves",
      "Real Madrid", "Barcelona", "Juventus", "Milan", "Bayern", "Dortmund", "PSG"
    ];

    for (int i = 0; i < matchCount; i++) {
      String home = teams[_random.nextInt(teams.length)];
      String away = teams[_random.nextInt(teams.length)];
      while (home == away) {
        away = teams[_random.nextInt(teams.length)];
      }

      matches.add(MatchData(
        id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
        date: date,
        homeTeam: home,
        awayTeam: away,
        leagueName: leagues[_random.nextInt(leagues.length)],
        homeStats: _generateRandomStats(),
        awayStats: _generateRandomStats(),
      ));
    }
    return matches;
  }

  static TeamStats _generateRandomStats() {
    // Ensure wins + losses + draws = 10
    int wins = _random.nextInt(11); // 0-10
    int losses = _random.nextInt(11 - wins);
    int draws = 10 - wins - losses;

    // Games scored in (independent but somewhat correlated to wins)
    // If you win, you likely scored.
    int minScored = wins; 
    int extraScored = _random.nextInt(11 - minScored); 
    // Actually, it's possible to win without scoring? No.
    // But it's possible to score and lose.
    // Let's just pick a number between wins and 10.
    int gamesScored = wins + _random.nextInt(10 - wins + 1);
    if (gamesScored > 10) gamesScored = 10;

    // Games conceded in
    // If you lose, you likely conceded.
    int minConceded = losses;
    int gamesConceded = losses + _random.nextInt(10 - losses + 1);
    if (gamesConceded > 10) gamesConceded = 10;
    
    // Correction: Draws. 0-0 draw means no score, no concede. 1-1 means score and concede.
    // This simple generation is fine for mock data.

    return TeamStats.create(
      wins: wins,
      losses: losses,
      draws: draws,
      gamesScored: gamesScored,
      gamesConceded: gamesConceded,
    );
  }
}
