import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider with ChangeNotifier {
  // User Profile Data
  String _username = "";
  int _age = 0;
  double _height = 0.0; // in cm
  double _weight = 0.0; // in kg
  String _gender = "";
  bool _acceptedGdpr = false;

  // Back Pain Management Data
  Map<String, int> _painAreas = {}; // Maps body area to pain level (1-10)
  Map<String, DateTime> _lastExerciseDate =
      {}; // Last time exercise was performed
  Map<String, int> _exerciseCount = {}; // Number of times exercise performed
  List<String> _videosWatched = []; // IDs of education videos watched
  List<String> _completedPrograms = []; // Completed therapy programs
  int _consecutiveDays = 0; // Streak of days using the app
  int _weeklyGoalProgress = 0; // Progress toward weekly exercise goal

  // Getters
  String get username => _username;
  int get age => _age;
  double get height => _height;
  double get weight => _weight;
  String get gender => _gender;
  bool get acceptedGdpr => _acceptedGdpr;

  Map<String, int> get painAreas => Map.unmodifiable(_painAreas);
  Map<String, DateTime> get lastExerciseDate =>
      Map.unmodifiable(_lastExerciseDate);
  Map<String, int> get exerciseCount => Map.unmodifiable(_exerciseCount);
  List<String> get videosWatched => List.unmodifiable(_videosWatched);
  List<String> get completedPrograms => List.unmodifiable(_completedPrograms);
  int get consecutiveDays => _consecutiveDays;
  int get weeklyGoalProgress => _weeklyGoalProgress;

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

    // Update weekly goal progress
    _weeklyGoalProgress += durationMinutes;

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

  void addVideoWatched(String videoId) {
    if (!_videosWatched.contains(videoId)) {
      _videosWatched.add(videoId);
      notifyListeners();
      savePreferences();
    }
  }

  void completeProgram(String programId) {
    if (!_completedPrograms.contains(programId)) {
      _completedPrograms.add(programId);
      notifyListeners();
      savePreferences();
    }
  }

  // Reset Weekly Data Method
  void resetWeeklyGoalProgress() {
    _weeklyGoalProgress = 0;
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
      await prefs.setDouble('height', _height);
      await prefs.setDouble('weight', _weight);
      await prefs.setString('gender', _gender);
      await prefs.setBool('acceptedGdpr', _acceptedGdpr);

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
      await prefs.setStringList('videosWatched', _videosWatched);
      await prefs.setStringList('completedPrograms', _completedPrograms);
      await prefs.setInt('consecutiveDays', _consecutiveDays);
      await prefs.setInt('weeklyGoalProgress', _weeklyGoalProgress);
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
      _height = prefs.getDouble('height') ?? 0.0;
      _weight = prefs.getDouble('weight') ?? 0.0;
      _gender = prefs.getString('gender') ?? "";
      _acceptedGdpr = prefs.getBool('acceptedGdpr') ?? false;

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

      _videosWatched = prefs.getStringList('videosWatched') ?? [];
      _completedPrograms = prefs.getStringList('completedPrograms') ?? [];
      _consecutiveDays = prefs.getInt('consecutiveDays') ?? 0;
      _weeklyGoalProgress = prefs.getInt('weeklyGoalProgress') ?? 0;

      notifyListeners();
    } catch (e) {
      print("Error loading preferences: $e");
      // Set defaults in case of error
      _painAreas = {};
      _lastExerciseDate = {};
      _exerciseCount = {};
      _videosWatched = [];
      _completedPrograms = [];
      notifyListeners();
    }
  }

  // Reset all data - useful for logout or testing
  Future<void> clearAllData() async {
    _username = "";
    _age = 0;
    _height = 0.0;
    _weight = 0.0;
    _gender = "";
    _acceptedGdpr = false;

    _painAreas = {};
    _lastExerciseDate = {};
    _exerciseCount = {};
    _videosWatched = [];
    _completedPrograms = [];
    _consecutiveDays = 0;
    _weeklyGoalProgress = 0;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
