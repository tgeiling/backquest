import 'package:backquest/elements.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services.dart';
import 'stats.dart';
import 'main.dart';

class AuthService {
  final String baseUrl = 'http://135.125.218.147:3000';
  final storage = FlutterSecureStorage();

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

  Future<bool> isTokenExpired() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) return true;

    final expiration = getTokenExpiration(token);
    if (expiration == null) return true;

    return expiration.isBefore(DateTime.now().add(Duration(minutes: 1)));
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

  LoginScreen({
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

    if (success) {
      final token = await getAuthToken();

      if (token != null) {
        final profileData = await fetchProfile(token);
        await prefs.clear();

        widget.setQuestionnairDone();

        if (profileData != null) {
          final profilProvider =
              Provider.of<ProfilProvider>(context, listen: false);
          final levelProvider =
              Provider.of<LevelNotifier>(context, listen: false);

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
            List<String> painAreas = painAreasDynamic
                .map((dynamic item) => item.toString())
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
            List<String> goals =
                goalsDynamic.map((dynamic item) => item.toString()).toList();
            profilProvider.setGoals(goals);
          }

          if (profileData.containsKey('questionnaireDone')) {
            profilProvider
                .setQuestionnaireDone(profileData['questionnaireDone']);
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
          levelProvider.loadLevelsAfterStart();
          profilProvider.loadInitialData();

          widget.setAuthenticated(true);
        } else {
          print("Failed to fetch profile data after login");
        }
      } else {
        print("No token found after successful login");
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Login Failed'),
            content: Text('Invalid username or password. Please try again.'),
            actions: <Widget>[
              TextButton(
                child: Text('Close'),
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
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
                child: GreyContainer(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                    child: Image.asset(
                      'assets/logo.png',
                      scale: 2,
                    ))),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Benutzername'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Passwort'),
              obscureText: true,
            ),
            Spacer(),
            PressableButton(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                onPressed: _attemptLogin,
                child: Container(
                  width: double.infinity,
                  child: Center(
                      child: Text('Login', style: TextStyle(fontSize: 18))),
                )),
            SizedBox(
              height: 10,
            ),
            PressableButton(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Container(
                    width: double
                        .infinity, // Ensures the button stretches to fill the width
                    child: Center(
                      child:
                          Text('Registrieren', style: TextStyle(fontSize: 18)),
                    ))),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
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
            title: Text('Registrierung Fehlgeschlagen'),
            content: Text('Falscher Benutzername und Passwort'),
            actions: <Widget>[
              TextButton(
                child: Text('Schließen'),
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
      appBar: AppBar(title: Text('Registrierung')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
                child: GreyContainer(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                    child: Image.asset(
                      'assets/logo.png',
                      scale: 2,
                    ))),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Benutzername'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Passwort'),
              obscureText: true,
            ),
            Spacer(),
            PressableButton(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              onPressed: _attemptRegister,
              child: Container(
                  width: double
                      .infinity, // Ensures the button stretches to fill the width
                  child: Center(
                      child: Text('Registrieren',
                          style: TextStyle(fontSize: 18)))),
            ),
          ],
        ),
      ),
    );
  }
}
