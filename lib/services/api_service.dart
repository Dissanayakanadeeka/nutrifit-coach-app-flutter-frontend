import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_log_dto.dart';
import '../models/meal_summary.dart';
import '../models/food_item.dart';
import '../models/user_profile.dart';
import '../models/calorieData.dart';

class ApiService {
static const String baseUrl = "http://10.111.183.207:8080/api";
  static const String mealsUrl = "$baseUrl/meals";
  //signup
  static Future<bool> signup(String username, email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username,"email": email, "password": password}),
    );

    return response.statusCode == 200;
  }


  // Login
  static Future<bool> login(String username, String password) async {
      final url = Uri.parse('$baseUrl/auth/login');
    print('👉 Sending login request to: $url');
    print('👉 Username: $username');
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'username': username,
        "password": password,
      }),
    );
      if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String token = data["token"];
      print("✅ Token: $token");

      // Save token locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("jwt", token);
      await prefs.setString("username", username); 
      return true;
    }
    return false;

  }


  // Fetch logged-in user
  static Future<Map<String, dynamic>?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt");

    final response = await http.get(
      Uri.parse("$baseUrl/users/me"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

    // Update profile
  static Future<bool> updateProfile(String username, String email) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt");

    final response = await http.put(
      Uri.parse("$baseUrl/users/me"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "username": username,
        "email": email,
      }),
    );

    return response.statusCode == 200;
  }
  // Get JWT token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

    /// Get meals for a specific date
  static Future<List<MealLogDTO>> getMealsForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt");

    final dateStr = date.toIso8601String().split('T')[0];
    final url = Uri.parse("$mealsUrl?date=$dateStr");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MealLogDTO.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load meals: ${response.statusCode}");
    }
  }


  /// Get meal summary for a specific date
  static Future<MealSummary> getMealSummary(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt");

    final dateStr = date.toIso8601String().split('T')[0];
    final url = Uri.parse("$mealsUrl/summary?date=$dateStr");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return MealSummary.fromJson(data);
    } else {
      throw Exception("Failed to load summary: ${response.statusCode}");
    }
  }


  /// Add a meal log
  static Future<void> addMeal({
  required int foodItemId,
  required double quantityGrams,
  DateTime? consumedAt,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("jwt");

  final url = Uri.parse(mealsUrl);
  final body = {
    "foodItemId": foodItemId,
    "quantityGrams": quantityGrams,
    "consumedAtIso": consumedAt?.toIso8601String(),
  };

  final response = await http.post(
    url,
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode(body),
  );

  if (response.statusCode != 201) {
    throw Exception("Failed to add meal: ${response.statusCode}");
  }
}

static Future<List<FoodItem>> searchFoodItems(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/foods/search?query=$query'));
    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((json) => FoodItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load food items');
    }
  }

static Future<List<FoodItem>> getAllFoodItems() async {
  final response = await http.get(Uri.parse( '$baseUrl/foods/all'));  
  if (response.statusCode == 200){
    final List jsonList = jsonDecode( response.body);
    return jsonList.map((json) => FoodItem.fromJson(json)).toList();  

  }
  else {
    throw Exception('Failed to load food items');
  }
}

static Future<UserProfile> getUserProfile(String username) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("jwt");

  final response = await http.get(
    Uri.parse('$baseUrl/profile/$username'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  print('Status: ${response.statusCode}');
  print('Response: ${response.body}');

  if (response.statusCode == 200) {
    return UserProfile.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load user profile: ${response.body}');
  }
}


static Future<void> updateUserProfile(String username, UserProfile profile) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("jwt");

  final response = await http.post(
    Uri.parse('$baseUrl/profile/$username'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(profile.toJson()),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update user profile: ${response.statusCode}');
  }
}


static Future<String?> getLoggedInUsername() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("username");
}

static Future<Map<String, dynamic>> getRecommendations(String username) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("jwt"); // get the stored token

  final response = await http.get(
    Uri.parse('$baseUrl/recommendations/$username'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  print('Status: ${response.statusCode}');
  print('Body: ${response.body}, Token: $token');

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load recommendations: ${response.body}');
  }
}

Future<List<CalorieData>> fetchLast30DaysCalories(String username) async {
  final response = await ApiService.getLast30DaysCalories(username); 
  if (response == null) return [];

  return (response as List).map((item) {
    return CalorieData(
      date: DateTime.parse(item['date']),
      calories: (item['calories'] as num).toDouble(),
    );
  }).toList();
}

  static Future<List<Map<String, dynamic>>?> getLast30DaysCalories(String username) async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt"); // get the stored token

    final response = await http.get(
      Uri.parse('$baseUrl/calories/last30days/$username'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      print("Error fetching last 30 days calories: ${response.statusCode}");
      return null;
    }
  }


  

}
