class TeamStats {
  final int wins;
  final int losses;
  final int draws;
  final int gamesScored; // Number of games where the team scored at least 1 goal
  final int gamesConceded; // Number of games where the team conceded at least 1 goal
  final int cleanSheets; // Number of games with 0 goals conceded
  final int failedToScore; // Number of games with 0 goals scored

  TeamStats({
    required this.wins,
    required this.losses,
    required this.draws,
    required this.gamesScored,
    required this.gamesConceded,
    required this.cleanSheets,
    required this.failedToScore,
  });

  // Factory to create stats ensuring they sum up correctly where applicable (wins+losses+draws = 10)
  factory TeamStats.create({
    required int wins,
    required int losses,
    required int draws,
    required int gamesScored,
    required int gamesConceded,
  }) {
    return TeamStats(
      wins: wins,
      losses: losses,
      draws: draws,
      gamesScored: gamesScored,
      gamesConceded: gamesConceded,
      cleanSheets: 10 - gamesConceded,
      failedToScore: 10 - gamesScored,
    );
  }
}

class MatchPrediction {
  final double homeWinPercent;
  final double awayWinPercent;
  final double bttsPercent;
  final String? winningTeam; // 'Home', 'Away', or null
  final bool isBttsPredicted;
  final bool isWinPredicted;
  final String predictionText;
  final double confidenceLevel;

  MatchPrediction({
    required this.homeWinPercent,
    required this.awayWinPercent,
    required this.bttsPercent,
    this.winningTeam,
    required this.isBttsPredicted,
    required this.isWinPredicted,
    required this.predictionText,
    required this.confidenceLevel,
  });
}

class MatchData {
  final String id;
  final DateTime date;
  final String homeTeam;
  final String awayTeam;
  final String leagueName;
  final TeamStats homeStats; // Last 10 Home Games
  final TeamStats awayStats; // Last 10 Away Games

  MatchData({
    required this.id,
    required this.date,
    required this.homeTeam,
    required this.awayTeam,
    required this.leagueName,
    required this.homeStats,
    required this.awayStats,
  });

  MatchPrediction calculatePrediction() {
    // BTTS Calculation
    // Match BTTS% = Average of ((Home scored % + Away conceded %) / 2 and (Away scored % + Home conceded %) / 2)
    
    double homeScoredPct = (homeStats.gamesScored / 10) * 100;
    double awayConcededPct = (awayStats.gamesConceded / 10) * 100;
    double part1 = (homeScoredPct + awayConcededPct) / 2;

    double awayScoredPct = (awayStats.gamesScored / 10) * 100;
    double homeConcededPct = (homeStats.gamesConceded / 10) * 100;
    double part2 = (awayScoredPct + homeConcededPct) / 2;

    double bttsPercent = (part1 + part2) / 2;

    // WIN % Calculation
    // Home WIN % = average ((Home wins / 10) * 100 and (Away loss / 10) * 100)
    double homeWinPct = ((homeStats.wins / 10) * 100 + (awayStats.losses / 10) * 100) / 2;

    // Away WIN % = Average of ((Away wins / 10) * 100 and (Home loss / 10) * 100)
    double awayWinPct = ((awayStats.wins / 10) * 100 + (homeStats.losses / 10) * 100) / 2;

    // Prediction Logic
    bool predictBtts = bttsPercent >= 70;
    
    String? winner;
    bool predictWin = false;
    double winConfidence = 0;

    if ((homeWinPct - awayWinPct) >= 29 && homeWinPct >= 70) {
      winner = 'Home';
      predictWin = true;
      winConfidence = homeWinPct;
    } else if ((awayWinPct - homeWinPct) >= 29 && awayWinPct >= 70) {
      winner = 'Away';
      predictWin = true;
      winConfidence = awayWinPct;
    }

    String predictionText = "No clear prediction";
    double finalConfidence = 0;

    List<String> predictions = [];
    if (predictWin && winner != null) {
      predictions.add("$winner Win");
      finalConfidence = winConfidence;
    }
    if (predictBtts) {
      predictions.add("BTTS");
      // If both, maybe take the higher confidence or average? 
      // Prompt says "Include Final prediction, Confidence level".
      // If both are present, we show both.
      if (finalConfidence == 0) finalConfidence = bttsPercent;
      else finalConfidence = (finalConfidence + bttsPercent) / 2; // Average if both
    }

    if (predictions.isNotEmpty) {
      predictionText = predictions.join(" & ");
    }

    return MatchPrediction(
      homeWinPercent: homeWinPct,
      awayWinPercent: awayWinPct,
      bttsPercent: bttsPercent,
      winningTeam: winner,
      isBttsPredicted: predictBtts,
      isWinPredicted: predictWin,
      predictionText: predictionText,
      confidenceLevel: finalConfidence,
    );
  }
}
