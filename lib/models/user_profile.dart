class UserProfile {
  final int? age;
  final double? height;
  final double? weight;
  final String? gender;
  final String? goal;
  final String? dietType;
  final String? allergies;

  UserProfile({
    this.age,
    this.height,
    this.weight,
    this.gender,
    this.goal,
    this.dietType,
    this.allergies,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      age: json['age'],
      height: (json['heightCm'] as num?)?.toDouble(),
      weight: (json['weightKg'] as num?)?.toDouble(),
      gender: json['gender'],
      goal: json['goal'],
      dietType: json['dietType'],
      allergies: json['allergies'],
    );
  }

  Map<String, dynamic> toJson() => {
        'age': age,
        'heightCm': height,   // changed
        'weightKg': weight,
        'gender':gender,
        'goal': goal,
        'dietType': dietType,
        'allergies': allergies,
      };
}
