// models/food_item.dart
class FoodItem {
  final int id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  // Factory constructor to create FoodItem from JSON
factory FoodItem.fromJson(Map<String, dynamic> json) {
  return FoodItem(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    calories: (json['caloriesPer100g'] ?? 0).toDouble(),
    protein: (json['proteinPer100g'] ?? 0).toDouble(),
    carbs: (json['carbsPer100g'] ?? 0).toDouble(),
    fat: (json['fatPer100g'] ?? 0).toDouble(),
  );
}


  // Optional: convert FoodItem to JSON (if needed)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  @override
  String toString() => name;
}
