import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../providers/data_provider.dart';
import 'exercise_detail_screen.dart';
import '../widgets/app_image.dart';

class ExerciseListScreen extends ConsumerWidget {
  final Category category;
  const ExerciseListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(dataProvider).exercises
        .where((e) => e.categoryId == category.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
      ),
      body: exercises.isEmpty
          ? const Center(child: Text('No exercises found in this category.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: const Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseDetailScreen(exercise: exercise),
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AppImage(imageUrl: exercise.gifUrl, fit: BoxFit.cover),
                      ),
                    ),
                    title: Text(
                      exercise.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(exercise.targetMuscle),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.redAccent),
                  ),
                );
              },
            ),
    );
  }
}
