import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
      final token = jsonDecode(response.body)[
          'accessToken']; // Assuming the token is returned in this manner
      await storage.write(key: 'authToken', value: token);

      return true;
    } else {
      print('Login failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return false;
    }
  }

  Future<bool> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 201) {
      // Assuming 201 Created status for successful registration
      return true;
    } else if (response.statusCode == 400) {
      // Handle specific cases, like username already taken, based on your API's response
    }
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    return false;
  }

  Future<bool> isTokenExpired() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) return true;

    final expiration = getTokenExpiration(token);
    if (expiration == null) return true;

    // Check if the token expires within the next minute
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

  LoginScreen({Key? key, required this.setAuthenticated}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  void _attemptLogin() async {
    bool success = await _authService.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (success) {
      widget.setAuthenticated(true);
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
                  Navigator.of(context).pop(); // Dismiss the dialog
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
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _attemptLogin,
              child: Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to the RegisterScreen when the button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text('Register'),
            ),
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
  final _authService =
      AuthService(); // Assuming AuthService has a register method

  void _attemptRegister() async {
    bool success = await _authService.register(
      _usernameController.text,
      _passwordController.text,
    );

    if (success) {
      Navigator.pop(
          context); // Return to the previous screen on successful registration
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Register Failed'),
            content: Text('Invalid username or password. Please try again.'),
            actions: <Widget>[
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
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
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _attemptRegister,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}