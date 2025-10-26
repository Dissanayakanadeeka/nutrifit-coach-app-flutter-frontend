import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../models/calorieData.dart';

class StaticAnalysisScreen extends StatefulWidget {
  const StaticAnalysisScreen({super.key});

  @override
  State<StaticAnalysisScreen> createState() => _StaticAnalysisScreenState();
}

class _StaticAnalysisScreenState extends State<StaticAnalysisScreen> {
  bool isLoading = true;
  List<CalorieData> last30Days = [];

  @override
  void initState() {
    super.initState();
    _loadLast30Days();
  }

  Future<void> _loadLast30Days() async {
    try {
      final username = await ApiService.getLoggedInUsername();
      if (username == null) throw Exception("No logged-in user found");

      final data = await ApiService.getLast30DaysCalories(username);
      if (data != null) {
        last30Days = data.map((item) => CalorieData.fromJson(item)).toList();
      }
    } catch (e) {
      print("Error loading last 30 days calories: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("30-Day Calorie Analysis 📊"),
        backgroundColor: Colors.lightGreen.shade600,
      ),
      backgroundColor: Colors.lightGreen.shade50,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : last30Days.isEmpty
              ? const Center(child: Text("No calorie data found"))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        "Calories consumed in the last 30 days",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Expanded(child: _buildBarChart()),
                    ],
                  ),
                ),
    );
  }

  Widget _buildBarChart() {
  // Sort by date
  last30Days.sort((a, b) => a.date.compareTo(b.date));

  List<BarChartGroupData> barGroups = [];
  for (int i = 0; i < last30Days.length; i++) {
    barGroups.add(
      BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: last30Days[i].calories,
            color: Colors.lightGreen.shade600,
            width: 10,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  return BarChart(
    BarChartData(
      alignment: BarChartAlignment.spaceEvenly,
      maxY: last30Days.map((e) => e.calories).reduce((a, b) => a > b ? a : b) * 1.2,
      barGroups: barGroups,

      // ✅ Titles customization
      titlesData: FlTitlesData(
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

        // ✅ Show Y-axis values only on the left
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 100,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),

        // ✅ Prevent overlapping X-axis labels by skipping some
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              // show every 3rd label to avoid clutter
              if (index % 3 != 0 || index < 0 || index >= last30Days.length) {
                return const SizedBox();
              }
              final date = last30Days[index].date;
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  "${date.day}/${date.month}",
                  style: const TextStyle(fontSize: 10),
                ),
              );
            },
          ),
        ),
      ),

      // ✅ Grid & border
      gridData: FlGridData(show: true, horizontalInterval: 100),
      borderData: FlBorderData(show: false),
    ),
  );
}

}
