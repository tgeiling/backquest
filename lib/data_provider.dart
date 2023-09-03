import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity/connectivity.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class FirebaseService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user = FirebaseAuth.instance.currentUser;

  FirebaseService() {
    _initDatabase();

    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
      //syncData();
    });
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<String?> getToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      final tokenResult = await user.getIdTokenResult();
      final token = tokenResult.token;
      return token;
    }
    return null;
  }

  Future<void> syncData() async {
    final isConnected =
        await checkConnectivity(); // Implement connectivity handling

    if (isConnected) {
      final token = await getToken();
      if (token != null) {
        final userDataSnapshot = await FirebaseFirestore.instance
            .collection('Userdata')
            .doc(user!.uid)
            .get();

        final levelDataSnapshot = await FirebaseFirestore.instance
            .collection('Leveldata')
            .doc(user!.uid)
            .get();

        final userData = userDataSnapshot.data() as Map<String, dynamic>;
        final levelData = levelDataSnapshot.data() as Map<String, dynamic>;
        saveDataLocally(userData, levelData);
      }
    }
  }

  Future<void> refreshData() async {
    await syncData();
    notifyListeners();
  }

  Future<bool> checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  late Database _database;
  late StoreRef<String, dynamic> _store;

  Future<void> _initDatabase() async {
    final dbFactory = databaseFactoryIo;
    final databaseName = 'database.db';

    // Get the application documents directory
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final dbPath = '${appDocumentDir.path}/$databaseName';

    // Check if the database file exists in the documents directory
    final dbFile = File(dbPath);
    final dbExists = await dbFile.exists();

    if (!dbExists) {
      // Copy the database file from assets to the documents directory
      final data = await rootBundle.load('assets/database/$databaseName');
      final bytes = data.buffer.asUint8List();
      await dbFile.writeAsBytes(bytes);
    }

    // Open the database
    _database = await dbFactory.openDatabase(dbPath);
    _store = stringMapStoreFactory.store('my_data');
  }

  Future<void> saveDataLocally(
      Map<String, dynamic> userData, Map<String, dynamic> levelData) async {
    final data = {
      'user_data': userData,
      'level_data': levelData,
    };
    await _store.record('data').put(_database, data);
  }

  Future<Map<String, dynamic>> getLocalData() async {
    final snapshot = await _store.record('data').getSnapshot(_database);
    if (snapshot != null && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value);
      final userData = data['user_data'] ?? {};
      final levelData = data['level_data'] ?? {};
      return {
        'user_data': userData,
        'level_data': levelData,
      };
    }
    return {
      'user_data': {},
      'level_data': {},
    };
  }

  Stream<Map<String, dynamic>> getUserDataStream() {
    return FirebaseFirestore.instance
        .collection('Userdata')
        .doc(user!.uid)
        .snapshots()
        .map((doc) => doc.data() as Map<String, dynamic>);
  }

  Stream<Map<String, dynamic>> getLevelDataStream() {
    return FirebaseFirestore.instance
        .collection('Leveldata')
        .doc(user!.uid)
        .snapshots()
        .map((doc) => doc.data() as Map<String, dynamic>);
  }

  Stream<Map<String, dynamic>> getCharacterDataStream() {
    return FirebaseFirestore.instance
        .collection('Characterdata')
        .doc(user!.uid)
        .snapshots()
        .map((doc) => doc.data() as Map<String, dynamic>);
  }
}
