import 'package:flutter/material.dart';
import '../models/match_model.dart';

class MatchCard extends StatefulWidget {
  final MatchData match;

  const MatchCard({super.key, required this.match});

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final prediction = widget.match.calculatePrediction();
    final bool isHighProbability = prediction.isWinPredicted || prediction.isBttsPredicted;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isHighProbability 
            ? const BorderSide(color: Colors.green, width: 2) 
            : BorderSide.none,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.match.leagueName,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                Text(
                  "${widget.match.date.day}/${widget.match.date.month}/${widget.match.date.year}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // Match Teams
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.match.homeTeam,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("VS", style: TextStyle(color: Colors.grey)),
                ),
                Expanded(
                  child: Text(
                    widget.match.awayTeam,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Predictions Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPredictionBadge("Home Win %", prediction.homeWinPercent),
                _buildPredictionBadge("Away Win %", prediction.awayWinPercent),
                _buildPredictionBadge("BTTS %", prediction.bttsPercent),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Final Prediction Result
          if (prediction.predictionText != "No clear prediction")
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    "PREDICTION: ${prediction.predictionText}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Confidence: ${prediction.confidenceLevel.toStringAsFixed(1)}%",
                    style: TextStyle(color: Colors.green.shade700, fontSize: 12),
                  ),
                ],
              ),
            ),

          // Expand Button
          TextButton.icon(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            icon: Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
            label: Text(_isExpanded ? "Hide Stats" : "Show Last 10 Stats"),
          ),

          // Expanded Stats Section
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Divider(),
                  const Text("Last 10 Matches Performance", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildStatRow("Wins", widget.match.homeStats.wins, widget.match.awayStats.wins),
                  _buildStatRow("Losses", widget.match.homeStats.losses, widget.match.awayStats.losses),
                  _buildStatRow("Draws", widget.match.homeStats.draws, widget.match.awayStats.draws),
                  _buildStatRow("Scored In", widget.match.homeStats.gamesScored, widget.match.awayStats.gamesScored),
                  _buildStatRow("Failed to Score", widget.match.homeStats.failedToScore, widget.match.awayStats.failedToScore),
                  _buildStatRow("Conceded In", widget.match.homeStats.gamesConceded, widget.match.awayStats.gamesConceded),
                  _buildStatRow("Clean Sheets", widget.match.homeStats.cleanSheets, widget.match.awayStats.cleanSheets),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPredictionBadge(String label, double percent) {
    bool isHigh = percent >= 70;
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isHigh ? Colors.green : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "${percent.toStringAsFixed(1)}%",
            style: TextStyle(
              color: isHigh ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, int homeValue, int awayValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text("$homeValue", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey))),
          SizedBox(width: 30, child: Text("$awayValue", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
