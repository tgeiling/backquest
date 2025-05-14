import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Replace with your actual server URL
const String apiUrl = 'http://34.116.240.55:3000';

// Get stored auth token
Future<String?> getAuthToken() async {
  try {
    final storage = const FlutterSecureStorage();
    return await storage
        .read(key: 'authToken')
        .timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            print("Secure storage read timed out");
            return null;
          },
        );
  } catch (e) {
    print("Error reading auth token: $e");
    return null;
  }
}

// Store auth token
Future<void> saveAuthToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
}

// Clear auth token (logout)
Future<void> clearAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');
}

// Register new user
Future<Map<String, dynamic>?> register({
  required String username,
  required String password,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$apiUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      print('Registration failed: ${data['message']}');
      return null;
    }
  } catch (e) {
    print('Error during registration: $e');
    return null;
  }
}

// Login user
Future<String?> login({
  required String username,
  required String password,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$apiUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Save token and return it
      final token = data['token'];
      await saveAuthToken(token);
      return token;
    } else {
      print('Login failed: ${data['message']}');
      return null;
    }
  } catch (e) {
    print('Error during login: $e');
    return null;
  }
}

// Get guest token
Future<String?> getGuestToken() async {
  try {
    final response = await http.post(
      Uri.parse('$apiUrl/guest'),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final token = data['token'];
      await saveAuthToken(token);
      return token;
    } else {
      print('Getting guest token failed: ${data['message']}');
      return null;
    }
  } catch (e) {
    print('Error getting guest token: $e');
    return null;
  }
}

// Validate token
Future<bool> validateToken(String token) async {
  try {
    final response = await http.post(
      Uri.parse('$apiUrl/validateToken'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );

    final data = jsonDecode(response.body);

    return data['isValid'] == true;
  } catch (e) {
    print('Error validating token: $e');
    return false;
  }
}

// Fetch user profile
Future<Map<String, dynamic>?> fetchProfile(String token) async {
  try {
    final response = await http.get(
      Uri.parse('$apiUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch profile: ${response.statusCode} ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error fetching profile: $e');
    return null;
  }
}

// Update user profile
Future<bool> updateProfile({
  required String token,
  int? age,
  int? fitnessLevel,
  double? height,
  double? weight,
  String? gender,
  bool? acceptedGdpr,
  bool? isExplained,
  Map<String, int>? painAreas,
  Map<String, String>? lastExerciseDate, // Serialized dates as ISO strings
  Map<String, int>? exerciseCount,
  int? consecutiveDays,
  int? weeklyGoalProgress,
  int? weeklyGoalTarget,
  int? duration,
  int? focus,
  int? goal,
  int? intensity,
  bool? payedSubscription,
  String? subType,
  String? subStarted,
  String? receiptData,
}) async {
  try {
    // Build request body with only provided fields
    final Map<String, dynamic> requestBody = {};
    if (age != null) requestBody['age'] = age;
    if (fitnessLevel != null) requestBody['fitnessLevel'] = fitnessLevel;
    if (height != null) requestBody['height'] = height;
    if (weight != null) requestBody['weight'] = weight;
    if (gender != null) requestBody['gender'] = gender;
    if (acceptedGdpr != null) requestBody['acceptedGdpr'] = acceptedGdpr;
    if (isExplained != null) requestBody['isExplained'] = isExplained;
    if (painAreas != null) requestBody['painAreas'] = painAreas;
    if (lastExerciseDate != null)
      requestBody['lastExerciseDate'] = lastExerciseDate;
    if (exerciseCount != null) requestBody['exerciseCount'] = exerciseCount;
    if (consecutiveDays != null)
      requestBody['consecutiveDays'] = consecutiveDays;
    if (weeklyGoalProgress != null)
      requestBody['weeklyGoalProgress'] = weeklyGoalProgress;
    if (weeklyGoalTarget != null)
      requestBody['weeklyGoalTarget'] = weeklyGoalTarget;
    if (duration != null) requestBody['duration'] = duration;
    if (focus != null) requestBody['focus'] = focus;
    if (goal != null) requestBody['goal'] = goal;
    if (intensity != null) requestBody['intensity'] = intensity;
    // Add subscription fields
    if (payedSubscription != null)
      requestBody['payedSubscription'] = payedSubscription;
    if (subType != null) requestBody['subType'] = subType;
    if (subStarted != null) requestBody['subStarted'] = subStarted;
    if (receiptData != null) requestBody['receiptData'] = receiptData;

    final response = await http.post(
      Uri.parse('$apiUrl/updateProfile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('Profile updated successfully');
      return true;
    } else {
      print(
        'Failed to update profile: ${response.statusCode} ${response.body}',
      );
      return false;
    }
  } catch (e) {
    print('Error updating profile: $e');
    return false;
  }
}

int getWeekNumber(DateTime date) {
  // The ISO week number calculation
  int dayOfYear = int.parse(DateFormat('D').format(date));
  int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
  if (woy < 1) {
    woy = numOfWeeks(date.year - 1);
  } else if (woy > numOfWeeks(date.year)) {
    woy = 1;
  }
  return woy;
}

// Helper method to get number of weeks in a year
int numOfWeeks(int year) {
  DateTime dec28 = DateTime(year, 12, 28);
  int dayOfDec28 = int.parse(DateFormat('D').format(dec28));
  return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
}
