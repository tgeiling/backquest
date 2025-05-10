import 'dart:convert';
import 'dart:async';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'elements.dart';
import 'provider.dart';
import 'services.dart';

class AuthService {
  final String baseUrl = 'http://34.116.240.55:3000';
  final storage = const FlutterSecureStorage();

  // Login function
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final token =
            jsonDecode(
              response.body,
            )['token']; // Key should match the server response
        if (token != null) {
          await storage.write(key: 'authToken', value: token);
          return true;
        } else {
          print('Token is null');
          return false;
        }
      } else {
        final errorResponse = jsonDecode(response.body);
        print(
          'Login failed: ${response.statusCode}, ${errorResponse['message']}',
        );
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<List<String>?> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 201) {
        return null; // Success, no errors
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('errors')) {
          return List<String>.from(responseData['errors']);
        } else {
          return ["An unknown error occurred."];
        }
      }
    } catch (e) {
      print('Registration error: $e');
      return ["Network error. Please try again."];
    }
  }

  // Guest access function
  Future<void> setGuestToken() async {
    try {
      final token = await getGuestToken().timeout(
        const Duration(seconds: 5), // 5 second timeout
        onTimeout: () => null,
      );
      if (token != null) {
        await storage.write(key: 'authToken', value: token);
      } else {
        print('Failed to obtain guest token.');
      }
    } catch (e) {
      print('Error setting guest token: $e');
    }
  }

  // Fetch guest token from the server
  Future<String?> getGuestToken() async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/guest'))
          .timeout(
            const Duration(seconds: 5), // 5 second timeout
          );
      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['token'];
        return token;
      } else {
        print('Failed to get guest token: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting guest token: $e');
      return null;
    }
  }

  // Validate token function
  Future<bool> validateToken() async {
    final token = await storage.read(key: 'authToken');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/validateToken'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['isValid'];
      } else {
        print('Token validation failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error validating token: $e');
      return false;
    }
  }

  // Logout function (removes token from storage)
  Future<void> logout() async {
    await storage.delete(key: 'authToken');
    await setGuestToken();
  }

  // Check if token is expired
  Future<bool> isTokenExpired() async {
    final token = await storage.read(key: 'authToken');
    if (token == null) return true;

    final expiration = getTokenExpiration(token);
    if (expiration == null) return true;

    bool test = expiration.isBefore(DateTime.now());
    print(test);

    return expiration.isBefore(DateTime.now());
  }

  // Decode the expiration date from the JWT token
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
      print('Error decoding token: $e');
    }
    return null;
  }

  Future<bool> isGuestToken() async {
    final token = await storage.read(key: 'authToken');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/validateToken'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['isGuest'] == true;
      } else {
        print('Failed to validate token: ${response.body}');
        return true;
      }
    } catch (e) {
      print("Error sending token validation request: $e");
      return true;
    }
  }
}

class LoginScreen extends StatefulWidget {
  final Function(bool) setAuthenticated;

  const LoginScreen({Key? key, required this.setAuthenticated})
    : super(key: key);

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
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    if (success) {
      final token = await getAuthToken();

      if (token != null) {
        // Attempt to sync the profile with the server
        bool syncSuccess = await profileProvider.syncProfile(token);

        if (syncSuccess) {
          // Profile synced successfully
          widget.setAuthenticated(true);
          Navigator.popUntil(context, (route) => route.isFirst);
        } else {
          // If sync fails, create initial profile
          print("Failed to sync profile. Creating initial profile.");

          // Ensure we have a username set at minimum
          profileProvider.setUsername(_usernameController.text);

          // Save the basic profile
          await profileProvider.savePreferences();

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
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(
              AppLocalizations.of(context)!.login_failed,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              AppLocalizations.of(context)!.invalid_credentials,
              style: TextStyle(color: Colors.white),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.close,
                  style: TextStyle(color: Colors.white),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Neumorphic(
              style: NeumorphicStyle(
                depth: 8,
                shape: NeumorphicShape.concave,
                boxShape: NeumorphicBoxShape.rect(),
              ),
              padding: const EdgeInsets.all(16),
              child: Image.asset(
                'assets/logo.png',
                width: MediaQuery.of(context).size.width * 0.3,
              ),
            ),
            const SizedBox(height: 40),

            // Username Field
            Neumorphic(
              style: NeumorphicStyle(depth: -4, color: Colors.grey[200]),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context)!.username,
                ),
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),

            // Password Field
            Neumorphic(
              style: NeumorphicStyle(depth: -4, color: Colors.grey[200]),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context)!.password,
                ),
                obscureText: true,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 40),

            // Login Button
            PressableButton(
              onPressed: _attemptLogin,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                AppLocalizations.of(context)!.login,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // Register Button
            PressableButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                );
              },
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                AppLocalizations.of(context)!.register,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showGdprConsentDialog();
    });
  }

  void _showGdprConsentDialog() {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    if (!profileProvider.acceptedGdpr) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.gdpr_consent_required),
            content: Text(AppLocalizations.of(context)!.gdpr_consent_text),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  profileProvider.setAcceptedGdpr(false);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context)!.decline),
              ),
              ElevatedButton(
                onPressed: () {
                  profileProvider.setAcceptedGdpr(true);
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context)!.accept),
              ),
            ],
          );
        },
      );
    }
  }

  void _attemptRegister() async {
    setState(() {
      _isLoading = true;
    });

    List<String>? errors = await _authService.register(
      _usernameController.text,
      _passwordController.text,
    );

    if (errors == null) {
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      profileProvider.setUsername(_usernameController.text);
      Navigator.pop(context); // Go back to login screen
    } else {
      _showErrorDialog(errors);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.registration_failed),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                errors
                    .map(
                      (error) => Text(
                        error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                    .toList(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.register,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Centers the title
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Neumorphic(
              style: NeumorphicStyle(
                depth: 8,
                shape: NeumorphicShape.concave,
                boxShape: NeumorphicBoxShape.rect(),
              ),
              padding: const EdgeInsets.all(16),
              child: Image.asset(
                'assets/logo.png',
                width: MediaQuery.of(context).size.width * 0.3,
              ),
            ),
            const SizedBox(height: 40),

            // Username Field
            Neumorphic(
              style: NeumorphicStyle(depth: -4, color: Colors.grey[200]),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context)!.username,
                ),
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),

            // Password Field
            Neumorphic(
              style: NeumorphicStyle(depth: -4, color: Colors.grey[200]),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context)!.password,
                ),
                obscureText: true,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 40),

            // Register Button
            _isLoading
                ? const CircularProgressIndicator()
                : PressableButton(
                  onPressed: _attemptRegister,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.register,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            const SizedBox(height: 20),

            // Back to Login Button
            PressableButton(
              onPressed: () => Navigator.pop(context),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                AppLocalizations.of(context)!.back_to_login,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
