import '../models/food_item.dart';
import '../models/meal_log_dto.dart';
import '../models/meal_summary.dart';

class RecommendationHelper {
  static List<FoodItem> recommendHighProtein(List<FoodItem> allFoods) {
    return allFoods.where((f) => f.protein > 15).toList();
  }

  static List<FoodItem> recommendLowCalorie(List<FoodItem> allFoods) {
    return allFoods.where((f) => f.calories < 150).toList();
  }

static List<FoodItem> recommendToMeetProteinGoal(
    List<FoodItem> allFoods, MealSummary todaySummary) {
  double remainingProtein = 100 - todaySummary.protein; // Assuming goal = 100g
  return allFoods
      .where((f) => f.protein <= remainingProtein && f.protein > 5)
      .toList();
}


  static List<FoodItem> recommendBalancedBreakfast(List<FoodItem> allFoods) {
    // Example breakfast set (modify based on your DB)
    List<String> breakfastNames = ['Oats', 'Milk', 'Almonds', 'Banana'];
    return allFoods.where((f) => breakfastNames.contains(f.name)).toList();
  }
}
