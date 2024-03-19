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
  List<String>? painAreas,
  String? workplaceEnvironment,
  String? fitnessLevel,
  String? expectation,
  String? personalGoal,
}) async {
  final Uri apiUrl = Uri.parse('http://135.125.218.147:3000/updateProfile');

  Map<String, dynamic> body = {};
  if (birthdate != null) body['birthdate'] = birthdate.toIso8601String();
  if (gender != null) body['gender'] = gender;
  if (weight != null) body['weight'] = weight;
  if (height != null) body['height'] = height;
  if (painAreas != null) body['painAreas'] = painAreas;
  if (workplaceEnvironment != null)
    body['workplaceEnvironment'] = workplaceEnvironment;
  if (fitnessLevel != null) body['fitnessLevel'] = fitnessLevel;
  if (expectation != null) body['expectation'] = expectation;
  if (personalGoal != null) body['personalGoal'] = personalGoal;

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
