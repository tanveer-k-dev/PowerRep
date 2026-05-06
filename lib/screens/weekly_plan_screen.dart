import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_provider.dart';
import 'exercise_detail_screen.dart';

class WeeklyPlanScreen extends ConsumerWidget {
  const WeeklyPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Workout Plan'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.plans.length,
        itemBuilder: (context, index) {
          final plan = state.plans[index];
          final exercises = state.exercises
              .where((e) => plan.exerciseIds.contains(e.id))
              .toList();

          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan.day,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                    Text(
                      plan.targetMuscle,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
                const Divider(color: Colors.grey, thickness: 0.5),
                if (exercises.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Rest Day 🛋️', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  )
                else
                  ...exercises.map((exercise) => ListTile(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExerciseDetailScreen(exercise: exercise),
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(exercise.gifUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(exercise.name),
                        subtitle: Text("${exercise.sets} Sets x ${exercise.reps} Reps"),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}
