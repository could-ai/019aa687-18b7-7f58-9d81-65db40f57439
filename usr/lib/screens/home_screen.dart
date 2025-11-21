import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../services/mock_service.dart';
import '../widgets/match_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _showHighProbabilityOnly = false;
  List<MatchData> _matches = [];

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  void _loadMatches() {
    setState(() {
      _matches = MockService.getMatchesForDate(_selectedDate);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadMatches();
    }
  }

  List<MatchData> get _filteredMatches {
    if (!_showHighProbabilityOnly) return _matches;
    return _matches.where((m) {
      final pred = m.calculatePrediction();
      return pred.isWinPredicted || pred.isBttsPredicted;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sportsdata"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Matches for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Text("High Prob. Only (>70%)"),
                        Switch(
                          value: _showHighProbabilityOnly,
                          onChanged: (val) {
                            setState(() {
                              _showHighProbabilityOnly = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Match List
          Expanded(
            child: _filteredMatches.isEmpty
                ? const Center(child: Text("No matches found matching criteria."))
                : ListView.builder(
                    itemCount: _filteredMatches.length,
                    itemBuilder: (context, index) {
                      return MatchCard(match: _filteredMatches[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
