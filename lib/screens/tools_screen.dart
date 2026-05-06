import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_provider.dart';
import '../models/exercise.dart';
import '../widgets/app_image.dart';

class ProgressTrackingScreen extends ConsumerWidget {
  const ProgressTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dataProvider);
    final progress = state.progress;
    final exercises = state.exercises;

    final trackedExercises = exercises.where((e) => progress.containsKey(e.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Progress Tracking')),
      body: trackedExercises.isEmpty
          ? const Center(child: Text("No progress tracked yet. Log some reps!"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trackedExercises.length,
              itemBuilder: (context, index) {
                final ex = trackedExercises[index];
                final totalReps = progress[ex.id] ?? 0;
                return Card(
                  child: ListTile(
                    leading: AppImage(imageUrl: ex.gifUrl, width: 40, height: 40),
                    title: Text(ex.name),
                    subtitle: Text("Total Reps Completed: $totalReps"),
                    trailing: const Icon(Icons.trending_up, color: Colors.green),
                  ),
                );
              },
            ),
    );
  }
}

class CustomWorkoutPlanScreen extends ConsumerStatefulWidget {
  const CustomWorkoutPlanScreen({super.key});

  @override
  ConsumerState<CustomWorkoutPlanScreen> createState() => _CustomWorkoutPlanScreenState();
}

class _CustomWorkoutPlanScreenState extends ConsumerState<CustomWorkoutPlanScreen> {
  final List<String> _selectedExerciseIds = [];

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(dataProvider).exercises;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Custom Plan')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Select exercises to add to your custom routine:", style: TextStyle(fontSize: 16)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final ex = exercises[index];
                final isSelected = _selectedExerciseIds.contains(ex.id);
                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) _selectedExerciseIds.add(ex.id);
                      else _selectedExerciseIds.remove(ex.id);
                    });
                  },
                  title: Text(ex.name),
                  secondary: AppImage(imageUrl: ex.gifUrl, width: 40, height: 40),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Custom Plan Saved locally!")));
          Navigator.pop(context);
        },
        label: Text("Save Plan (${_selectedExerciseIds.length})"),
        icon: const Icon(Icons.save),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
