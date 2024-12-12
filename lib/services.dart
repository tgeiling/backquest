import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  final Uri apiUrl = Uri.parse('http://135.125.218.147:3000/profile');
  try {
    final response = await http.get(
      apiUrl,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> profileData = jsonDecode(response.body);
      return profileData;
    } else {
      print('Failed to fetch profile: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error fetching profile: $e');
    return null;
  }
}

Future<bool> updateProfile({
  required String token,
  DateTime? birthdate,
  String? gender,
  int? weight,
  int? height,
  int? weeklyGoal,
  int? weeklyDone,
  int? weeklyStreak,
  String? lastUpdateString,
  int? completedLevels,
  int? completedLevelsTotal,
  List<int>? painAreas,
  int? workplaceEnvironment,
  int? fitnessLevel,
  String? expectation,
  List<int>? personalGoal,
  bool? questionnaireDone,
  bool? payedSubscription,
  String? subType,
  DateTime? subStarted,
  String? receiptData,
  String? lastResetDate,
  List<ExerciseFeedback>? feedback,
}) async {
  final Uri apiUrl = Uri.parse('http://135.125.218.147:3000/updateProfile');

  Map<String, dynamic> body = {};
  if (birthdate != null) body['birthdate'] = birthdate.toIso8601String();
  if (gender != null) body['gender'] = gender;
  if (weight != null) body['weight'] = weight;
  if (height != null) body['height'] = height;
  if (weeklyGoal != null) body['weeklyGoal'] = weeklyGoal;
  if (weeklyDone != null) body['weeklyDone'] = weeklyDone;
  if (weeklyStreak != null) body['weeklyStreak'] = weeklyStreak;
  if (lastUpdateString != null) body['lastUpdateString'] = lastUpdateString;
  if (completedLevels != null) body['completedLevels'] = completedLevels;
  if (completedLevelsTotal != null)
    body['completedLevelsTotal'] = completedLevelsTotal;
  if (painAreas != null) body['painAreas'] = painAreas;
  if (workplaceEnvironment != null) {
    body['workplaceEnvironment'] = workplaceEnvironment;
  }
  if (fitnessLevel != null) body['fitnessLevel'] = fitnessLevel;
  if (expectation != null) body['expectation'] = expectation;
  if (personalGoal != null) body['personalGoal'] = personalGoal;
  if (questionnaireDone != null) body['questionnaireDone'] = questionnaireDone;
  if (payedSubscription != null) body['payedSubscription'] = payedSubscription;
  if (subType != null) body['subType'] = subType;
  if (subStarted != null) body['subStarted'] = subStarted;
  if (receiptData != null) body['receiptData'] = receiptData;
  if (lastResetDate != null) body['lastResetDate'] = lastResetDate;
  if (feedback != null) body['feedback'] = feedback;

  try {
    final response = await http.post(
      apiUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to update profile: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error updating profile: $e');
    return false;
  }
}

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

class ExerciseFeedback {
  final String videoId;
  String? difficulty;
  List<int> painAreas;

  ExerciseFeedback({
    required this.videoId,
    this.difficulty,
    this.painAreas = const [],
  });

  factory ExerciseFeedback.fromJson(Map<String, dynamic> json) {
    return ExerciseFeedback(
      videoId: json['videoId'],
      difficulty: json['difficulty'],
      painAreas: List<int>.from(json['painAreas'] ?? []),
    );
  }

  void update({String? newDifficulty, List<int>? newPainAreas}) {
    if (newDifficulty != null) {
      difficulty = newDifficulty;
    }
    if (newPainAreas != null && newPainAreas.isNotEmpty) {
      painAreas = newPainAreas;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'difficulty': difficulty,
      'painAreas': painAreas,
    };
  }
}


/* const String serverUrl = 'http://135.125.218.147:3000/validate-receipt';

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