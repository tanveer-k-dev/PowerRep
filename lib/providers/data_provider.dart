import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';
import '../models/category.dart';
import '../models/workout_plan.dart';
import '../services/firebase_service.dart';
import '../services/mock_data_service.dart';

final firebaseServiceProvider = Provider((ref) => FirebaseService());
final mockDataServiceProvider = Provider((ref) => MockDataService());

final authStateProvider = StreamProvider((ref) {
  return ref.watch(firebaseServiceProvider).authStateChanges;
});

class DataState {
  final List<Exercise> exercises;
  final List<Category> categories;
  final List<WorkoutPlan> plans;
  final List<String> favorites;
  final List<String> recentlyViewed;
  final Map<String, int> progress; // exerciseId -> totalRepsDone
  final bool isLoading;

  DataState({
    this.exercises = const [],
    this.categories = const [],
    this.plans = const [],
    this.favorites = const [],
    this.recentlyViewed = const [],
    this.progress = const {},
    this.isLoading = false,
  });

  DataState copyWith({
    List<Exercise>? exercises,
    List<Category>? categories,
    List<WorkoutPlan>? plans,
    List<String>? favorites,
    List<String>? recentlyViewed,
    Map<String, int>? progress,
    bool? isLoading,
  }) {
    return DataState(
      exercises: exercises ?? this.exercises,
      categories: categories ?? this.categories,
      plans: plans ?? this.plans,
      favorites: favorites ?? this.favorites,
      recentlyViewed: recentlyViewed ?? this.recentlyViewed,
      progress: progress ?? this.progress,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DataNotifier extends Notifier<DataState> {
  static const String _favKey = 'favorite_exercises';
  static const String _recentKey = 'recently_viewed';

  @override
  DataState build() {
    Future.microtask(() => loadInitialData());
    return DataState(isLoading: true);
  }

  Future<void> loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favKey) ?? [];
    final recent = prefs.getStringList(_recentKey) ?? [];
    
    final service = ref.read(firebaseServiceProvider);
    try {
      final data = await service.fetchAllData();
      
      state = state.copyWith(
        exercises: (data['exercises'] as List).map((e) => Exercise.fromJson(e)).toList(),
        categories: (data['categories'] as List).map((e) => Category.fromJson(e)).toList(),
        plans: (data['plans'] as List).map((e) => WorkoutPlan.fromJson(e)).toList(),
        favorites: favorites,
        recentlyViewed: recent,
        isLoading: false,
      );
    } catch (e) {
      print('Firestore empty or error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> syncData() async {
    state = state.copyWith(isLoading: true);
    await loadInitialData();
  }

  Future<void> addToRecentlyViewed(String exerciseId) async {
    final newRecent = List<String>.from(state.recentlyViewed);
    newRecent.remove(exerciseId);
    newRecent.insert(0, exerciseId);
    if (newRecent.length > 10) newRecent.removeLast();
    
    state = state.copyWith(recentlyViewed: newRecent);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentKey, newRecent);
  }

  Future<void> trackProgress(String exerciseId, int reps) async {
    final newProgress = Map<String, int>.from(state.progress);
    newProgress[exerciseId] = (newProgress[exerciseId] ?? 0) + reps;
    state = state.copyWith(progress: newProgress);
  }

  // --- MIGRATION TOOL ---
  Future<void> migrateToFirebase({bool overwrite = false}) async {
    try {
      state = state.copyWith(isLoading: true);
      final mockService = ref.read(mockDataServiceProvider);
      final firebaseService = ref.read(firebaseServiceProvider);
      
      final data = await mockService.fetchAllData();
      
      final categories = (data['categories'] as List).map((e) => Category.fromJson(e)).toList();
      final exercises = (data['exercises'] as List).map((e) => Exercise.fromJson(e)).toList();
      final plans = List<Map<String, dynamic>>.from(data['plans']);

      // Upload using Smart Merge by default (only add missing)
      await firebaseService.uploadDataBatch(categories, exercises, plans, overwrite: overwrite);
      
      await loadInitialData();
    } catch (e) {
      print('Migration failed: $e');
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  // Exercise Management
  Future<void> addExercise(Exercise exercise) async {
    state = state.copyWith(isLoading: true);
    await ref.read(firebaseServiceProvider).addExercise(exercise);
    await loadInitialData();
  }

  Future<void> updateExercise(Exercise exercise) async {
    state = state.copyWith(isLoading: true);
    await ref.read(firebaseServiceProvider).updateExercise(exercise);
    await loadInitialData();
  }

  Future<void> deleteExercise(String id) async {
    state = state.copyWith(isLoading: true);
    await ref.read(firebaseServiceProvider).deleteExercise(id);
    await loadInitialData();
  }

  // Category Management
  Future<void> addCategory(Category category) async {
    state = state.copyWith(isLoading: true);
    await ref.read(firebaseServiceProvider).addCategory(category);
    await loadInitialData();
  }

  Future<void> updateCategory(Category category) async {
    state = state.copyWith(isLoading: true);
    await ref.read(firebaseServiceProvider).updateCategory(category);
    await loadInitialData();
  }

  Future<void> deleteCategory(String id) async {
    state = state.copyWith(isLoading: true);
    await ref.read(firebaseServiceProvider).deleteCategory(id);
    await loadInitialData();
  }

  Future<void> toggleFavorite(String exerciseId) async {
    final newFavorites = List<String>.from(state.favorites);
    if (newFavorites.contains(exerciseId)) {
      newFavorites.remove(exerciseId);
    } else {
      newFavorites.add(exerciseId);
    }
    
    state = state.copyWith(favorites: newFavorites);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favKey, newFavorites);
  }
}

final dataProvider = NotifierProvider<DataNotifier, DataState>(() {
  return DataNotifier();
});
