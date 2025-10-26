class MealLogDTO {
  final int id;
  final int foodItemId;
  final String foodName;
  final double quantityGrams;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String consumedAtIso;

  MealLogDTO({
    required this.id,
    required this.foodItemId,
    required this.foodName,
    required this.quantityGrams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.consumedAtIso,
  });

  factory MealLogDTO.fromJson(Map<String, dynamic> json) {
    return MealLogDTO(
      id: (json['id'] ?? 0).toInt(),
      foodItemId: (json['foodItemId'] ?? 0).toInt(),
      foodName: json['foodName'] ?? '',
      quantityGrams: (json['quantityGrams'] ?? 0).toDouble(),
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      consumedAtIso: json['consumedAtIso'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodItemId': foodItemId,
      'foodName': foodName,
      'quantityGrams': quantityGrams,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'consumedAtIso': consumedAtIso,
    };
  }
}
