class MealSummary {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  MealSummary({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory MealSummary.fromJson(Map<String, dynamic> json) {
    return MealSummary(
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}
