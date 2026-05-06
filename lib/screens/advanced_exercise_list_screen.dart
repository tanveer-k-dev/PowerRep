import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_provider.dart';
import '../models/exercise.dart';
import '../widgets/app_image.dart';
import 'exercise_detail_screen.dart';

class ExerciseSearchDelegate extends SearchDelegate {
  final WidgetRef ref;
  ExerciseSearchDelegate(this.ref);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final exercises = ref.watch(dataProvider).exercises;
    final results = exercises.where((e) => e.name.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final ex = results[index];
        return ListTile(
          leading: SizedBox(
            width: 50,
            height: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppImage(imageUrl: ex.gifUrl),
            ),
          ),
          title: Text(ex.name),
          subtitle: Text("${ex.targetMuscle} • ${ex.difficulty}"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ExerciseDetailScreen(exercise: ex)),
            );
          },
        );
      },
    );
  }
}

class AdvancedExerciseListScreen extends ConsumerStatefulWidget {
  final String title;
  final List<Exercise> exercises;
  const AdvancedExerciseListScreen({super.key, required this.title, required this.exercises});

  @override
  ConsumerState<AdvancedExerciseListScreen> createState() => _AdvancedExerciseListScreenState();
}

class _AdvancedExerciseListScreenState extends ConsumerState<AdvancedExerciseListScreen> {
  String _selectedDifficulty = 'All';
  String _selectedMuscle = 'All';

  @override
  Widget build(BuildContext context) {
    final muscles = ['All', ...widget.exercises.map((e) => e.targetMuscle).toSet()];
    final difficulties = ['All', 'Beginner', 'Intermediate', 'Hard'];

    final filtered = widget.exercises.where((e) {
      final mMatch = _selectedMuscle == 'All' || e.targetMuscle == _selectedMuscle;
      final dMatch = _selectedDifficulty == 'All' || e.difficulty == _selectedDifficulty;
      return mMatch && dMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title),
            Text("${filtered.length} Exercises", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(context: context, delegate: ExerciseSearchDelegate(ref)),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip("Muscle", muscles, _selectedMuscle, (val) => setState(() => _selectedMuscle = val)),
                const SizedBox(width: 8),
                _buildFilterChip("Difficulty", difficulties, _selectedDifficulty, (val) => setState(() => _selectedDifficulty = val)),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text("No exercises match your filters."))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final ex = filtered[index];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: AppImage(imageUrl: ex.gifUrl, width: 60, height: 60),
                            ),
                            title: Text(ex.name),
                            subtitle: Text("${ex.targetMuscle} • ${ex.difficulty}"),
                            onTap: () {
                              ref.read(dataProvider.notifier).addToRecentlyViewed(ex.id);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ExerciseDetailScreen(exercise: ex)),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, List<String> options, String current, Function(String) onSelect) {
    return PopupMenuButton<String>(
      initialValue: current,
      onSelected: onSelect,
      child: Chip(
        label: Text("$label: $current"),
        deleteIcon: const Icon(Icons.arrow_drop_down, size: 18),
        onDeleted: () {}, // Handled by child
        backgroundColor: Colors.redAccent.withOpacity(0.1),
      ),
      itemBuilder: (context) => options.map((o) => PopupMenuItem(value: o, child: Text(o))).toList(),
    );
  }
}
