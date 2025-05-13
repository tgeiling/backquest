import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services.dart'; // Import the services.dart we created

class ProfileProvider with ChangeNotifier {
  // User Profile Data
  String _username = "";
  int _age = 0;
  int _fitnessLevel = 0;
  double _height = 0.0; // in cm
  double _weight = 0.0; // in kg
  String _gender = "";
  bool _acceptedGdpr = false;

  // Back Pain Management Data
  Map<String, int> _painAreas = {}; // Maps body area to pain level (1-10)
  Map<String, DateTime> _lastExerciseDate =
      {}; // Last time exercise was performed
  Map<String, int> _exerciseCount = {}; // Number of times exercise performed
  int _consecutiveDays = 0; // Streak of days using the app
  int _weeklyGoalTarget = 3;
  int _weeklyGoalProgress = 0; // Progress toward weekly exercise goal
  bool _isExplained = false;

  int? _duration;
  int? _focus;
  int? _goal;
  int? _intensity;

  // Subscription Data
  bool? _payedSubscription;
  String? _subType;
  String? _subStarted;
  String? _receiptData;

  // Getters
  String get username => _username;
  int get age => _age;
  int get fitnessLevel => _fitnessLevel;
  double get height => _height;
  double get weight => _weight;
  String get gender => _gender;
  bool get acceptedGdpr => _acceptedGdpr;

  Map<String, int> get painAreas => Map.unmodifiable(_painAreas);
  Map<String, DateTime> get lastExerciseDate =>
      Map.unmodifiable(_lastExerciseDate);
  Map<String, int> get exerciseCount => Map.unmodifiable(_exerciseCount);
  int get consecutiveDays => _consecutiveDays;
  int get weeklyGoalProgress => _weeklyGoalProgress;
  int get weeklyGoalTarget => _weeklyGoalTarget;
  bool get isExplained => _isExplained;

  int? get duration => _duration;
  int? get focus => _focus;
  int? get goal => _goal;
  int? get intensity => _intensity;

  // Subscription Getters
  bool? get payedSubscription => _payedSubscription;
  String? get subType => _subType;
  String? get subStarted => _subStarted;
  String? get receiptData => _receiptData;

  // Constructor
  ProfileProvider() {
    loadPreferences();
  }

  // User Profile Methods
  void setUsername(String username) {
    _username = username;
    notifyListeners();
    savePreferences();
  }

  void setAge(int age) {
    _age = age;
    notifyListeners();
    savePreferences();
  }

  void setFitnessLevel(int fitnessLevel) {
    _fitnessLevel = fitnessLevel;
    notifyListeners();
    savePreferences();
  }

  void setHeight(double height) {
    _height = height;
    notifyListeners();
    savePreferences();
  }

  void setWeight(double weight) {
    _weight = weight;
    notifyListeners();
    savePreferences();
  }

  void setGender(String gender) {
    _gender = gender;
    notifyListeners();
    savePreferences();
  }

  void setAcceptedGdpr(bool accepted) {
    _acceptedGdpr = accepted;
    notifyListeners();
    savePreferences();
  }

  void setIsExplained(bool explained) {
    _isExplained = explained;
    notifyListeners();
    savePreferences();
  }

  void setWeeklyGoalTarget(int target) {
    if (target > 0) {
      _weeklyGoalTarget = target;
      notifyListeners();
      savePreferences();
    }
  }

  // Subscription Methods
  void setSubscription({
    required bool isPaid,
    String? type,
    String? started,
    String? receipt,
  }) {
    _payedSubscription = isPaid;
    _subType = type;
    _subStarted = started;
    _receiptData = receipt;
    notifyListeners();
    savePreferences();
  }

  // Pain Management Methods
  void updatePainArea(String area, int painLevel) {
    _painAreas[area] = painLevel;
    notifyListeners();
    savePreferences();
  }

  void removePainArea(String area) {
    if (_painAreas.containsKey(area)) {
      _painAreas.remove(area);
      notifyListeners();
      savePreferences();
    }
  }

  // Exercise Tracking Methods
  void recordExercise(String exerciseId, int durationMinutes) {
    // Update last performed date
    _lastExerciseDate[exerciseId] = DateTime.now();

    // Increment exercise count
    _exerciseCount[exerciseId] = (_exerciseCount[exerciseId] ?? 0) + 1;

    // Increment weekly goal progress by 1 (not by minutes)
    _weeklyGoalProgress += 1;

    // Check and update consecutive days streak
    _updateConsecutiveDays();

    notifyListeners();
    savePreferences();
  }

  void _updateConsecutiveDays() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if any exercise was done yesterday
    bool exerciseDoneYesterday = false;
    final yesterday = today.subtract(const Duration(days: 1));

    for (final date in _lastExerciseDate.values) {
      final exerciseDate = DateTime(date.year, date.month, date.day);
      if (exerciseDate == yesterday) {
        exerciseDoneYesterday = true;
        break;
      }
    }

    if (exerciseDoneYesterday) {
      _consecutiveDays++; // Increment streak
    } else {
      // Check if already exercised today
      bool exerciseDoneToday = false;
      for (final date in _lastExerciseDate.values) {
        final exerciseDate = DateTime(date.year, date.month, date.day);
        if (exerciseDate == today) {
          exerciseDoneToday = true;
          break;
        }
      }

      // If this is the first exercise today and no exercise yesterday, reset streak to 1
      if (!exerciseDoneToday) {
        _consecutiveDays = 1;
      }
    }
  }

  // Reset Weekly Data Method
  void resetWeeklyGoalProgress() {
    _weeklyGoalProgress = 0;
    notifyListeners();
    savePreferences();
  }

  // Set Video Preferences
  void saveVideoPreferences({
    int? duration,
    int? focus,
    int? goal,
    int? intensity,
  }) {
    _duration = duration;
    _focus = focus;
    _goal = goal;
    _intensity = intensity;
    notifyListeners();
    savePreferences();
  }

  // Persistence Methods
  Future<void> savePreferences() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Save User Profile Data
      await prefs.setString('username', _username);
      await prefs.setInt('age', _age);
      await prefs.setInt('fitnessLevel', _fitnessLevel);
      await prefs.setDouble('height', _height);
      await prefs.setDouble('weight', _weight);
      await prefs.setString('gender', _gender);
      await prefs.setBool('acceptedGdpr', _acceptedGdpr);
      await prefs.setBool('isExplained', _isExplained);

      // Save Pain Data
      await prefs.setString('painAreas', json.encode(_painAreas));

      // Save Exercise Data
      final Map<String, String> lastExerciseDateMap = {};
      _lastExerciseDate.forEach((key, value) {
        lastExerciseDateMap[key] = value.toIso8601String();
      });
      await prefs.setString(
        'lastExerciseDate',
        json.encode(lastExerciseDateMap),
      );
      await prefs.setString('exerciseCount', json.encode(_exerciseCount));
      await prefs.setInt('consecutiveDays', _consecutiveDays);
      await prefs.setInt('weeklyGoalProgress', _weeklyGoalProgress);
      await prefs.setInt('weeklyGoalTarget', _weeklyGoalTarget);

      // Save video preferences
      final Map<String, dynamic> videoPrefs = {
        'duration': _duration,
        'focus': _focus,
        'goal': _goal,
        'intensity': _intensity,
      };
      await prefs.setString('videoPreferences', json.encode(videoPrefs));

      // Save subscription data
      final Map<String, dynamic> subscriptionData = {
        'payedSubscription': _payedSubscription,
        'subType': _subType,
        'subStarted': _subStarted,
        'receiptData': _receiptData,
      };
      await prefs.setString('subscriptionData', json.encode(subscriptionData));

      // Sync with server if we have a token
      String? token = await getAuthToken();
      if (token != null && _username.isNotEmpty) {
        await syncToServer(token);
      }
    } catch (e) {
      print("Error saving preferences: $e");
    }
  }

  Future<void> loadPreferences() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Load User Profile Data
      _username = prefs.getString('username') ?? "";
      _age = prefs.getInt('age') ?? 0;
      _fitnessLevel = prefs.getInt('fitnessLevel') ?? 0;
      _height = prefs.getDouble('height') ?? 0.0;
      _weight = prefs.getDouble('weight') ?? 0.0;
      _gender = prefs.getString('gender') ?? "";
      _acceptedGdpr = prefs.getBool('acceptedGdpr') ?? false;
      _isExplained = prefs.getBool('isExplained') ?? false;

      // Load Pain Data
      String? painAreasJson = prefs.getString('painAreas');
      if (painAreasJson != null && painAreasJson.isNotEmpty) {
        try {
          Map<String, dynamic> decoded = json.decode(painAreasJson);
          _painAreas = Map<String, int>.from(decoded);
        } catch (e) {
          print("Error parsing pain areas JSON: $e");
          _painAreas = {};
        }
      }

      // Load Exercise Data
      String? lastExerciseDateJson = prefs.getString('lastExerciseDate');
      if (lastExerciseDateJson != null && lastExerciseDateJson.isNotEmpty) {
        try {
          Map<String, dynamic> decoded = json.decode(lastExerciseDateJson);
          _lastExerciseDate = {};

          decoded.forEach((key, value) {
            _lastExerciseDate[key] = DateTime.parse(value as String);
          });
        } catch (e) {
          print("Error parsing last exercise date JSON: $e");
          _lastExerciseDate = {};
        }
      }

      String? exerciseCountJson = prefs.getString('exerciseCount');
      if (exerciseCountJson != null && exerciseCountJson.isNotEmpty) {
        try {
          Map<String, dynamic> decoded = json.decode(exerciseCountJson);
          _exerciseCount = Map<String, int>.from(decoded);
        } catch (e) {
          print("Error parsing exercise count JSON: $e");
          _exerciseCount = {};
        }
      }

      _consecutiveDays = prefs.getInt('consecutiveDays') ?? 0;
      _weeklyGoalProgress = prefs.getInt('weeklyGoalProgress') ?? 0;
      _weeklyGoalTarget = prefs.getInt('weeklyGoalTarget') ?? 3;

      // Load video preferences
      String? videoPrefsJson = prefs.getString('videoPreferences');
      if (videoPrefsJson != null && videoPrefsJson.isNotEmpty) {
        try {
          Map<String, dynamic> decoded = json.decode(videoPrefsJson);
          _duration = decoded['duration'];
          _focus = decoded['focus'];
          _goal = decoded['goal'];
          _intensity = decoded['intensity'];
        } catch (e) {
          print("Error parsing video preferences JSON: $e");
          // Keep default null values
        }
      }

      // Load subscription data
      String? subscriptionJson = prefs.getString('subscriptionData');
      if (subscriptionJson != null && subscriptionJson.isNotEmpty) {
        try {
          Map<String, dynamic> decoded = json.decode(subscriptionJson);
          _payedSubscription = decoded['payedSubscription'];
          _subType = decoded['subType'];
          _subStarted = decoded['subStarted'];
          _receiptData = decoded['receiptData'];
        } catch (e) {
          print("Error parsing subscription data JSON: $e");
          // Keep default null values
        }
      }

      notifyListeners();
    } catch (e) {
      print("Error loading preferences: $e");
      // Set defaults in case of error
      _painAreas = {};
      _lastExerciseDate = {};
      _exerciseCount = {};
      notifyListeners();
    }
  }

  // Sync profile with server
  Future<bool> syncProfile(String token) async {
    try {
      Map<String, dynamic>? profileData = await fetchProfile(token);

      if (profileData != null) {
        // Update user profile data
        _username = profileData['username'] ?? _username;
        _age = profileData['age'] ?? _age;
        _fitnessLevel = profileData['fitnessLevel'] ?? _fitnessLevel;

        // Handle numeric types properly (double vs int)
        if (profileData['height'] != null) {
          _height =
              (profileData['height'] is int)
                  ? (profileData['height'] as int).toDouble()
                  : profileData['height'];
        }

        if (profileData['weight'] != null) {
          _weight =
              (profileData['weight'] is int)
                  ? (profileData['weight'] as int).toDouble()
                  : profileData['weight'];
        }

        _gender = profileData['gender'] ?? _gender;
        _acceptedGdpr = profileData['acceptedGdpr'] ?? _acceptedGdpr;
        _isExplained = profileData['isExplained'] ?? _isExplained;

        // Handle pain areas
        if (profileData.containsKey('painAreas') &&
            profileData['painAreas'] is Map) {
          final painAreasData =
              profileData['painAreas'] as Map<String, dynamic>;
          _painAreas = {};
          painAreasData.forEach((key, value) {
            if (value is int) {
              _painAreas[key] = value;
            }
          });
        }

        // Handle lastExerciseDate - convert ISO strings to DateTime
        if (profileData.containsKey('lastExerciseDate') &&
            profileData['lastExerciseDate'] is Map) {
          final lastExerciseDateData =
              profileData['lastExerciseDate'] as Map<String, dynamic>;
          _lastExerciseDate = {};
          lastExerciseDateData.forEach((key, value) {
            if (value is String) {
              try {
                _lastExerciseDate[key] = DateTime.parse(value);
              } catch (e) {
                print("Error parsing date: $e");
              }
            }
          });
        }

        // Handle exerciseCount
        if (profileData.containsKey('exerciseCount') &&
            profileData['exerciseCount'] is Map) {
          final exerciseCountData =
              profileData['exerciseCount'] as Map<String, dynamic>;
          _exerciseCount = {};
          exerciseCountData.forEach((key, value) {
            if (value is int) {
              _exerciseCount[key] = value;
            }
          });
        }

        _consecutiveDays = profileData['consecutiveDays'] ?? _consecutiveDays;
        _weeklyGoalProgress =
            profileData['weeklyGoalProgress'] ?? _weeklyGoalProgress;
        _weeklyGoalTarget =
            profileData['weeklyGoalTarget'] ?? _weeklyGoalTarget;

        // Handle video preferences
        _duration = profileData['duration'];
        _focus = profileData['focus'];
        _goal = profileData['goal'];
        _intensity = profileData['intensity'];

        // Handle subscription data
        _payedSubscription = profileData['payedSubscription'];
        _subType = profileData['subType'];
        _subStarted = profileData['subStarted'];
        _receiptData = profileData['receiptData'];

        notifyListeners();
        await savePreferences(); // Save to local storage
        return true;
      }
      return false;
    } catch (e) {
      print("Error during profile sync: $e");
      return false;
    }
  }

  // Helper method to sync data to server
  Future<bool> syncToServer(String token) async {
    try {
      // Convert lastExerciseDate to ISO string format for API
      final Map<String, String> lastExerciseDateMap = {};
      _lastExerciseDate.forEach((key, value) {
        lastExerciseDateMap[key] = value.toIso8601String();
      });

      return await updateProfile(
        token: token,
        age: _age,
        fitnessLevel: _fitnessLevel,
        height: _height,
        weight: _weight,
        gender: _gender,
        acceptedGdpr: _acceptedGdpr,
        isExplained: _isExplained,
        painAreas: _painAreas,
        lastExerciseDate: lastExerciseDateMap,
        exerciseCount: _exerciseCount,
        consecutiveDays: _consecutiveDays,
        weeklyGoalProgress: _weeklyGoalProgress,
        weeklyGoalTarget: _weeklyGoalTarget,
        duration: _duration,
        focus: _focus,
        goal: _goal,
        intensity: _intensity,
        payedSubscription: _payedSubscription,
        subType: _subType,
        subStarted: _subStarted,
        receiptData: _receiptData,
      );
    } catch (e) {
      print("Error syncing to server: $e");
      return false;
    }
  }
}
