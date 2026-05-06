import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import '../models/exercise.dart';
import '../models/category.dart';
import '../models/workout_plan.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- Authentication ---
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Auth Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() => _auth.signOut();

  // --- Image Upload ---
  Future<String> uploadExerciseImage(String localPath) async {
    try {
      if (!localPath.startsWith('/') && !localPath.contains('Users')) {
        return localPath; // Already a URL
      }
      
      final file = File(localPath);
      final fileName = path.basename(localPath);
      final ref = _storage.ref().child('exercises/$fileName');
      
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Storage Error: $e');
      return localPath;
    }
  }

  // --- Firestore CRUD ---
  Future<Map<String, List>> fetchAllData() async {
    final categoriesSnap = await _db.collection('categories').get();
    final exercisesSnap = await _db.collection('exercises').get();
    final plansSnap = await _db.collection('plans').get();

    return {
      'categories': categoriesSnap.docs.map((doc) => doc.data()).toList(),
      'exercises': exercisesSnap.docs.map((doc) => doc.data()).toList(),
      'plans': plansSnap.docs.map((doc) => doc.data()).toList(),
    };
  }

  Future<void> addExercise(Exercise exercise) async {
    String imageUrl = exercise.gifUrl;
    if (File(exercise.gifUrl).existsSync()) {
      imageUrl = await uploadExerciseImage(exercise.gifUrl);
    }
    
    final data = exercise.copyWith(gifUrl: imageUrl).toJson();
    await _db.collection('exercises').doc(exercise.id).set(data);
  }

  Future<void> updateExercise(Exercise exercise) async {
    String imageUrl = exercise.gifUrl;
    if (File(exercise.gifUrl).existsSync()) {
      imageUrl = await uploadExerciseImage(exercise.gifUrl);
    }
    
    final data = exercise.copyWith(gifUrl: imageUrl).toJson();
    await _db.collection('exercises').doc(exercise.id).update(data);
  }

  Future<void> deleteExercise(String id) async {
    await _db.collection('exercises').doc(id).delete();
  }

  Future<void> addCategory(Category category) async {
    await _db.collection('categories').doc(category.id).set(category.toJson());
  }

  Future<void> updateCategory(Category category) async {
    await _db.collection('categories').doc(category.id).update(category.toJson());
  }

  Future<void> deleteCategory(String id) async {
    await _db.collection('categories').doc(id).delete();
  }
}
