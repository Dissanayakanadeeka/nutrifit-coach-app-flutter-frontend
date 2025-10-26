class CalorieData {
  final DateTime date;
  final double calories;

  CalorieData({required this.date, required this.calories});

  factory CalorieData.fromJson(Map<String, dynamic> json) {
    return CalorieData(
      date: DateTime.parse(json['date']),
      calories: (json['calories'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'calories': calories,
      };
}
