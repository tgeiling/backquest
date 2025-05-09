import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//Profile Area
Future<String?> getAuthToken() async {
  const storage = FlutterSecureStorage();
  try {
    final String? token = await storage.read(key: 'authToken');
    return token;
  } catch (e) {
    print("Error reading token from secure storage: $e");
    return null;
  }
}

Future<Map<String, dynamic>?> fetchProfile(String token) async {
  try {
    final response = await http.get(
      Uri.parse('http://34.40.38.12:3000/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final profileData = jsonDecode(response.body);
      return profileData;
    } else {
      print(
        'Failed to fetch profile: ${response.statusCode}, ${response.body}',
      );
      return null;
    }
  } catch (e) {
    print('Error fetching profile: $e');
    return null;
  }
}

void fetchAndPrintProfile(String token) async {
  Map<String, dynamic>? profileData = await fetchProfile(token);

  if (profileData != null) {
    print('Profile Data: $profileData');
  } else {
    print('Failed to fetch profile or no data returned.');
  }
}

Future<bool> updateProfile({
  required String token,
  String? username,
  int? age,
  double? height,
  double? weight,
  String? gender,
  bool? acceptedGdpr,
  Map<String, int>? painAreas,
  Map<String, DateTime>? lastExerciseDate,
  Map<String, int>? exerciseCount,
  List<String>? videosWatched,
  List<String>? completedPrograms,
  int? consecutiveDays,
  int? weeklyGoalProgress,
  // Legacy parameters for backward compatibility - can be removed if not needed
  Map<String, List<String>>? decks,
  String? deckLanguage,
  int? winStreak,
  int? exp,
  int? coins,
  String? title,
  Map<String, int>? eloMap,
  int? skillLevel,
  List<String>? friends,
  String? completedLevels,
  String? completedCardLevels,
  String? nativeLanguage,
  List<String>? cardsCollected,
}) async {
  try {
    Map<String, dynamic> body = {};

    // Add back pain app profile data
    if (username != null) body['username'] = username;
    if (age != null) body['age'] = age;
    if (height != null) body['height'] = height;
    if (weight != null) body['weight'] = weight;
    if (gender != null) body['gender'] = gender;
    if (acceptedGdpr != null) body['acceptedGdpr'] = acceptedGdpr;

    // Add pain management data
    if (painAreas != null) body['painAreas'] = painAreas;

    // For the lastExerciseDate, convert DateTime objects to ISO strings
    if (lastExerciseDate != null) {
      Map<String, String> dateStringMap = {};
      lastExerciseDate.forEach((key, value) {
        dateStringMap[key] = value.toIso8601String();
      });
      body['lastExerciseDate'] = dateStringMap;
    }

    if (exerciseCount != null) body['exerciseCount'] = exerciseCount;
    if (videosWatched != null) body['videosWatched'] = videosWatched;
    if (completedPrograms != null)
      body['completedPrograms'] = completedPrograms;
    if (consecutiveDays != null) body['consecutiveDays'] = consecutiveDays;
    if (weeklyGoalProgress != null)
      body['weeklyGoalProgress'] = weeklyGoalProgress;

    // Legacy parameters - can be kept for backward compatibility
    if (decks != null) body['decks'] = decks;
    if (winStreak != null) body['winStreak'] = winStreak;
    if (exp != null) body['exp'] = exp;
    if (coins != null) body['coins'] = coins;
    if (title != null) body['title'] = title;
    if (eloMap != null) body['elo'] = eloMap;
    if (skillLevel != null) body['skillLevel'] = skillLevel;
    if (friends != null) body['friends'] = friends;
    if (completedLevels != null) body['completedLevels'] = completedLevels;
    if (completedCardLevels != null)
      body['completedCardLevels'] = completedCardLevels;
    if (nativeLanguage != null) body['nativeLanguage'] = nativeLanguage;
    if (cardsCollected != null) body['cardsCollected'] = cardsCollected;

    final response = await http.post(
      Uri.parse('http://34.40.38.12:3000/updateProfile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print(
        'Failed to update profile: ${response.statusCode}, ${response.body}',
      );
      return false;
    }
  } catch (e) {
    print('Error updating profile: $e');
    return false;
  }
}

//Game Helper Area

int weekNumber(DateTime date) {
  final startOfYear = DateTime(date.year, 1, 1, 0, 0);
  final firstMonday = startOfYear.weekday;
  final daysInFirstWeek = 8 - firstMonday;
  final diff = date.difference(startOfYear);
  var weeks = ((diff.inDays - daysInFirstWeek) / 7).ceil();
  if (daysInFirstWeek > 3) {
    weeks += 1;
  }
  return weeks;
}

bool isTablet(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final shortestSide = size.shortestSide;

  return shortestSide >= 600;
}

/* const String serverUrl = 'http://35.246.224.168/validate-receipt';

Future<bool> validateAppleReceipt(String receiptData) async {
  return await _validateReceipt(receiptData, platform: 'apple');
}

Future<bool> validateGoogleReceipt(String receiptData) async {
  return await _validateReceipt(receiptData, platform: 'google');
}

Future<bool> _validateReceipt(String receiptData, {required String platform}) async {
  try {
    final response = await http.post(
      Uri.parse(serverUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'platform': platform,
        'receiptData': receiptData,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData['valid'] == true;
    } else {
      print('Failed to validate receipt: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error validating receipt: $e');
    return false;
  }
}
 */
