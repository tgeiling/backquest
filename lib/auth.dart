import 'dart:async';

import 'package:backquest/elements.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'services.dart';
import 'stats.dart';
import 'main.dart';

class AuthService {
  final String baseUrl = 'http://34.116.240.55:3000';
  final storage = const FlutterSecureStorage();

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['accessToken'];
      await storage.write(key: 'authToken', value: token);

      return true;
    } else {
      print('Login failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return false;
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'authToken');
    await setGuestToken();
  }

  Future<bool> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 400) {}
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    return false;
  }

  Future<void> setGuestToken() async {
    final token = await getGuestToken();
    if (token != null) {
      await storage.write(key: 'authToken', value: token);
    } else {
      print('No token received, unable to store.');
    }
  }

  Future<String?> getGuestToken() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/guestnode'));
      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['accessToken'];
        return token;
      } else {
        print(
            'Failed to obtain guest token with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error occurred: $e');
      return null;
    }
  }

  Future<bool> isGuestToken() async {
    final token = await storage.read(key: 'authToken');

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/validateToken'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': token}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return !result['isValid'];
      } else {
        print('Failed to validate token: ${response.body}');
        return true;
      }
    } catch (e) {
      print("Error sending token validation request: $e");
      return true; // Assume guest token on error
    }
  }

  Future<bool> isTokenExpired() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) return true;

    final expiration = getTokenExpiration(token);
    if (expiration == null) return true;

    return expiration.isBefore(DateTime.now()
        .subtract(const Duration(days: 120))
        .add(const Duration(minutes: 1)));
  }

  DateTime? getTokenExpiration(String token) {
    try {
      final payload = token.split('.')[1];
      final decoded = utf8.decode(base64.decode(base64.normalize(payload)));
      final payloadMap = json.decode(decoded);
      if (payloadMap is Map<String, dynamic>) {
        final exp = payloadMap['exp'];
        if (exp is int) {
          return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        }
      }
    } catch (e) {
      print("Error decoding token: $e");
    }
    return null;
  }
}

class LoginScreen extends StatefulWidget {
  final Function(bool) setAuthenticated;
  final VoidCallback setQuestionnairDone;

  const LoginScreen({
    Key? key,
    required this.setAuthenticated,
    required this.setQuestionnairDone,
  }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  void _attemptLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool success = await _authService.login(
      _usernameController.text,
      _passwordController.text,
    );
    final profilProvider = Provider.of<ProfilProvider>(context, listen: false);
    final levelProvider = Provider.of<LevelNotifier>(context, listen: false);

    if (success) {
      final token = await getAuthToken();

      if (token != null) {
        final profileData = await fetchProfile(token);

        if (profileData != null && profileData.containsKey('completedLevels')) {
          String? lastResetDate = prefs.getString("lastResetDate");

          await prefs.clear();
          widget.setQuestionnairDone();

          prefs.setString("lastResetDate", lastResetDate!);

          if (profileData.containsKey('birthdate')) {
            profilProvider
                .setBirthdate(DateTime.parse(profileData['birthdate']));
          }
          if (profileData.containsKey('gender')) {
            profilProvider.setGender(profileData['gender']);
          }
          if (profileData.containsKey('weight')) {
            profilProvider.setWeight(profileData['weight']);
          }
          if (profileData.containsKey('height')) {
            profilProvider.setHeight(profileData['height']);
          }
          if (profileData.containsKey('weeklyGoal')) {
            profilProvider.setWeeklyGoal(profileData['weeklyGoal']);
          }

          if (profileData.containsKey('weeklyDone')) {
            profilProvider.setWeeklyDone(profileData['weeklyDone']);
          }

          if (profileData.containsKey('weeklyStreak')) {
            profilProvider.setWeeklyStreak(profileData['weeklyStreak']);
          }

          if (profileData.containsKey('lastUpdateString')) {
            profilProvider.setLastUpdateString(profileData['lastUpdateString']);
          }

          if (profileData.containsKey('painAreas')) {
            List<dynamic> painAreasDynamic = profileData['painAreas'];
            List<int> painAreas = painAreasDynamic
                .map((dynamic item) => int.tryParse(item.toString()) ?? 0)
                .toList();
            profilProvider.setHasPain(painAreas);
          }
          if (profileData.containsKey('workplaceEnvironment')) {
            profilProvider
                .setWorkplaceEnvironment(profileData['workplaceEnvironment']);
          }
          if (profileData.containsKey('fitnessLevel')) {
            profilProvider.setFitnessLevel(profileData['fitnessLevel']);
          }

          if (profileData.containsKey('personalGoal')) {
            List<dynamic> goalsDynamic = profileData['personalGoal'];
            List<int> goals = goalsDynamic
                .map((dynamic item) => int.tryParse(item.toString()) ?? 0)
                .toList();
            profilProvider.setGoals(goals);
          }

          profilProvider.setQuestionnaireDone(true);

          if (profileData.containsKey('payedSubscription')) {
            profilProvider
                .setPayedSubscription(profileData['payedSubscription']);
          }

          if (profileData.containsKey('subType')) {
            profilProvider.setSubType(profileData['subType']);
          }

          if (profileData.containsKey('subStarted')) {
            profilProvider.setSubStarted(profileData['subStarted']);
          }

          if (profileData.containsKey('receiptData')) {
            profilProvider.setReceiptData(profileData['receiptData']);
          }

          if (profileData.containsKey('lastResetDate')) {
            profilProvider.setLastResetDate(profileData['lastResetDate']);
          }

          if (profileData.containsKey('feedback')) {
            List<ExerciseFeedback> feedbackList =
                (profileData['feedback'] as List)
                    .map((item) => ExerciseFeedback.fromJson(item))
                    .toList();
            profilProvider.setFeedback(feedbackList);
          }

          if (profileData.containsKey('completedLevels')) {
            int completedLevels = profileData['completedLevels'];
            profilProvider.setCompletedLevels(completedLevels);

            if (completedLevels >= 1) {
              await prefs.setInt('completedLevels', completedLevels);

              for (int levelId = 1; levelId <= completedLevels; levelId++) {
                levelProvider.updateLevelStatusSync(levelId);
              }
            } else {
              print('Invalid completedLevels value: $completedLevels');
            }
          }

          if (profileData.containsKey('completedLevelsTotal')) {
            profilProvider
                .setCompletedLevelsTotal(profileData['completedLevelsTotal']);
          }

          levelProvider.loadLevelsAfterStart();
          profilProvider.loadInitialData();

          widget.setAuthenticated(true);
          Navigator.popUntil(context, (route) => route.isFirst);
        } else {
          getAuthToken().then((token) {
            if (token != null) {
              updateProfile(
                token: token,
                birthdate: profilProvider.birthdate,
                gender: profilProvider.gender,
                weight: profilProvider.weight,
                height: profilProvider.height,
                weeklyGoal: profilProvider.weeklyGoal,
                weeklyDone: profilProvider.weeklyDone,
                weeklyStreak: profilProvider.weeklyStreak,
                lastUpdateString: profilProvider.lastUpdateString,
                painAreas: profilProvider.hasPain,
                workplaceEnvironment: profilProvider.workplaceEnvironment,
                fitnessLevel: profilProvider.fitnessLevel,
                personalGoal: profilProvider.goals,
                payedSubscription: profilProvider.payedSubscription,
                subType: profilProvider.subType,
                subStarted: profilProvider.subStarted,
                receiptData: profilProvider.receiptData,
                lastResetDate: profilProvider.lastResetDate,
                feedback: profilProvider.feedback,
                completedLevels: profilProvider.completedLevels,
                completedLevelsTotal: profilProvider.completedLevelsTotal,
              ).then((success) {
                if (success) {
                  print("Profile updated successfully.");
                } else {
                  print("Failed to update profile.");
                }
              });
            } else {
              print("No auth token available.");
            }
          });

          levelProvider.loadLevelsAfterStart();
          profilProvider.loadInitialData();

          widget.setAuthenticated(true);
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } else {
        print("No token found after successful login");
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor:
                const Color.fromRGBO(97, 184, 115, 1), // Green background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(
              AppLocalizations.of(context)!.loginFailedTitle,
              style: const TextStyle(
                color: Colors.white, // White text
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              AppLocalizations.of(context)!.loginFailedMessage,
              style: const TextStyle(
                color: Colors.white, // White text
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.closeButton,
                  style: const TextStyle(
                    color: Colors.white, // White text
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.loginTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: GreyContainer(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                child: Image.asset('assets/logo.png',
                    width: MediaQuery.of(context).size.width * 0.15),
              ),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.usernameLabel,
              ),
              style: const TextStyle(color: Colors.black),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.passwordLabel,
              ),
              obscureText: true,
              style: const TextStyle(color: Colors.black),
            ),
            const Spacer(),
            PressableButton(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              onPressed: _attemptLogin,
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.loginButton,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            PressableButton(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                );
              },
              child: SizedBox(
                width: double
                    .infinity, // Ensures the button stretches to fill the width
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.registerButton,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  void _attemptRegister() async {
    bool success = await _authService.register(
      _usernameController.text,
      _passwordController.text,
    );

    if (success) {
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.registerFailedTitle),
            content: Text(AppLocalizations.of(context)!.registerFailedContent),
            actions: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context)!.closeButton),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.registerTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: GreyContainer(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                child: Image.asset(
                  'assets/logo.png',
                  scale: 2,
                ),
              ),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.usernameLabel,
              ),
              style: const TextStyle(color: Colors.black),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.passwordLabel,
              ),
              style: const TextStyle(color: Colors.black),
              obscureText: true,
            ),
            const Spacer(),
            PressableButton(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              onPressed: _attemptRegister,
              child: SizedBox(
                width: double
                    .infinity, // Ensures the button stretches to fill the width
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.registerButton,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
