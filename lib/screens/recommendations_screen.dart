import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  bool isLoading = true;
  Map<String, dynamic>? recommendations;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      final username = await ApiService.getLoggedInUsername();
      if (username == null) throw Exception("No logged-in user found");

      final data = await ApiService.getRecommendations(username);
      setState(() {
        recommendations = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading recommendations: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.lightGreen.shade600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Health Recommendations 🥗'),
        backgroundColor: themeColor,
      ),
      backgroundColor: Colors.lightGreen.shade50,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recommendations == null
              ? const Center(child: Text("No recommendations found"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(),
                      const SizedBox(height: 20),

                      _buildInfoCard(
                        title: "Basal Metabolic Rate (BMR)",
                        value: recommendations!['bmr'],
                        description:
                            "BMR is the number of calories your body burns while resting. "
                            "It helps estimate how much energy you need daily.",
                        icon: Icons.local_fire_department,
                        color: Colors.orange.shade100,
                      ),
                      _buildInfoCard(
                        title: "Daily Calorie Target",
                        value: recommendations!['dailyCalories'],
                        description:
                            "This is your suggested daily calorie intake based on your goal "
                            "and activity level.",
                        icon: Icons.fastfood,
                        color: Colors.lightGreen.shade100,
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "Macronutrient Breakdown 🍳",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Macronutrients (‘macros’) are nutrients that provide your body with energy — "
                        "they include proteins, fats, and carbohydrates. "
                        "These amounts are calculated based on your BMR (Basal Metabolic Rate) "
                        "and daily calorie needs, making them personalized for your body type and goal.",
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      ),

                      const SizedBox(height: 10),

                      _buildMacroCard(
                        "Protein",
                        (recommendations!['macros']['protein'] as num?)?.toStringAsFixed(2) ?? "0.00",
                        "Helps build and repair muscles. Important for recovery and strength.",
                        Icons.fitness_center,
                        Colors.blue.shade100,
                        suffix: "g",
                      ),
                      _buildMacroCard(
                        "Fat",
                        (recommendations!['macros']['fat'] as num?)?.toStringAsFixed(2) ?? "0.00",
                        "Provides long-term energy and supports brain and hormone health.",
                        Icons.opacity,
                        Colors.pink.shade100,
                        suffix: "g",
                      ),
                      _buildMacroCard(
                        "Carbohydrates",
                        (recommendations!['macros']['carbs'] as num?)?.toStringAsFixed(2) ?? "0.00",
                        "Your main energy source for daily activities and workouts.",
                        Icons.local_dining,
                        Colors.yellow.shade100,
                        suffix: "g",
                      ),

                      const SizedBox(height: 24),
                      _buildPersonalizedAdvice(),
                    ],
                  ),
                ),
    );
  }

  /// 🧭 Personalized advice based on the user’s goal
  Widget _buildPersonalizedAdvice() {
    final goal = (recommendations!['goal'] ?? 'Maintain Weight').toLowerCase();
    String advice;
    IconData icon;
    Color color;

    if (goal.contains("lose")) {
      advice =
          "To lose weight, aim for a calorie deficit. Eat lean proteins, fiber-rich foods, and avoid sugary snacks.";
      icon = Icons.trending_down;
      color = Colors.redAccent.shade100;
    } else if (goal.contains("gain")) {
      advice =
          "To gain muscle, eat a slight calorie surplus with high protein and strength training.";
      icon = Icons.trending_up;
      color = Colors.greenAccent.shade100;
    } else {
      advice =
          "To maintain weight, balance your calories and include a mix of all nutrients daily.";
      icon = Icons.balance;
      color = Colors.lightBlueAccent.shade100;
    }

    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                advice,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🌿 Intro header
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Your Personalized Health Report 🌱",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 6),
        Text(
          "Based on your profile (age, height, weight, and activity level), here’s what we recommend for a healthier lifestyle.",
          style: TextStyle(fontSize: 15, color: Colors.black54),
        ),
      ],
    );
  }

  /// 🧾 Info card with descriptions
  Widget _buildInfoCard({
    required String title,
    required dynamic value,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      color: color,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.black54),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description,
                      style: const TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
            Text(
              "$value",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  /// 🧮 Macro cards with clear explanation
  Widget _buildMacroCard(
    String label,
    dynamic value,
    String explanation,
    IconData icon,
    Color color, {
    String suffix = "",
  }) {
    return Card(
      color: color,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, size: 30, color: Colors.black54),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(explanation),
        trailing: Text(
          "$value $suffix",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
