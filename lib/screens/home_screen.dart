import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/meal_log_dto.dart';
import '../models/meal_summary.dart';
import 'add_meal_screen.dart';
import 'StaticAnalysisScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<MealLogDTO> todayMeals = [];
  MealSummary? todaySummary;
  bool loading = true;
  String? username;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    fetchTodayData();
    getUsername();
  }

  void getUsername() async {
    final user = await ApiService.getLoggedInUsername();
    setState(() {
      username = user;
    });
  }

  void fetchTodayData() async {
    final meals = await ApiService.getMealsForDate(DateTime.now());
    final summary = await ApiService.getMealSummary(DateTime.now());
    setState(() {
      todayMeals = meals;
      todaySummary = summary;
      loading = false;
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildSummaryCard(MealSummary summary) {
  return Card(
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white.withOpacity(0.9),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Nutrition Summary",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildNutrientTile(
              "Calories", "${summary.calories.toStringAsFixed(0)} kcal", Icons.local_fire_department, Colors.orange),
          _buildNutrientTile(
              "Protein", "${summary.protein.toStringAsFixed(1)} g", Icons.fitness_center, Colors.green),
          _buildNutrientTile(
              "Carbs", "${summary.carbs.toStringAsFixed(1)} g", Icons.cake, Colors.blue),
          _buildNutrientTile(
              "Fat", "${summary.fat.toStringAsFixed(1)} g", Icons.opacity, Colors.pink),
        ],
      ),
    ),
  );
}

// Helper widget for each nutrient
Widget _buildNutrientTile(String name, String value, IconData icon, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const Spacer(),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ],
    ),
  );
}


  Widget _buildMealCard(MealLogDTO meal) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.lightGreen,
          child: Icon(Icons.restaurant_menu, color: Colors.white),
        ),
        title: Text(meal.foodName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text("${meal.quantityGrams} g | ${meal.calories} kcal"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Colors.green)));
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("NutriFit Coach",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightGreen,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
                  colors: [
        Color(0xFFE8F5E9), // light green shade
        Color(0xFFF1F8E9), // slightly different tone for subtle gradient
          ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome, ${username?? 'User'}",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 12),
                Text("Track your meals and stay healthy!",
                    style: TextStyle(
                        fontSize: 16, color: Colors.green.shade700)),
                const SizedBox(height: 20),

                // Summary Card
                if (todaySummary != null) _buildSummaryCard(todaySummary!),

                const SizedBox(height: 20),
                const Text("Today's Meals",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 10),

                if (todayMeals.isEmpty)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("No meals logged for today.",
                        style: TextStyle(color: Colors.white70)),
                  ))
                else
                  ...todayMeals.map(_buildMealCard),

                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.bar_chart),
                    label: const Text("View 30-Day Calorie Analytics"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const StaticAnalysisScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text("Add Meal"),
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMealScreen()),
          );
          if (added == true) fetchTodayData();
        },
      ),
    );
  }
}
