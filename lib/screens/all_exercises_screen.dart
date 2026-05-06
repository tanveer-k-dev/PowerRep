import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_provider.dart';
import '../models/exercise.dart';
import '../widgets/app_image.dart';
import 'exercise_detail_screen.dart';

class AllExercisesScreen extends ConsumerStatefulWidget {
  const AllExercisesScreen({super.key});

  @override
  ConsumerState<AllExercisesScreen> createState() => _AllExercisesScreenState();
}

class _AllExercisesScreenState extends ConsumerState<AllExercisesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';
  String _sortBy = 'Name (A-Z)';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dataProvider);
    final allExercises = state.exercises;
    final categories = ['All', ...state.categories.map((c) => c.name)];
    final difficulties = ['All', 'Beginner', 'Intermediate', 'Hard'];

    // 1. Filter
    List<Exercise> filtered = allExercises.where((ex) {
      final matchesSearch = ex.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final categoryName = state.categories.firstWhere((c) => c.id == ex.categoryId, orElse: () => state.categories[0]).name;
      final matchesCategory = _selectedCategory == 'All' || categoryName == _selectedCategory;
      final matchesDifficulty = _selectedDifficulty == 'All' || ex.difficulty == _selectedDifficulty;
      return matchesSearch && matchesCategory && matchesDifficulty;
    }).toList();

    // 2. Sort
    if (_sortBy == 'Name (A-Z)') {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    } else if (_sortBy == 'Difficulty') {
      final diffMap = {'Beginner': 0, 'Intermediate': 1, 'Hard': 2};
      filtered.sort((a, b) => (diffMap[a.difficulty] ?? 0).compareTo(diffMap[b.difficulty] ?? 0));
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('All Exercises'),
            Text("${filtered.length} of ${allExercises.length} Exercises", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.redAccent.withOpacity(0.1),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(categories, difficulties),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No exercises found matching filters.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final exercise = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ExerciseDetailScreen(exercise: exercise)),
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AppImage(imageUrl: exercise.gifUrl, width: 60, height: 60),
                          ),
                          title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("${exercise.targetMuscle} • ${exercise.difficulty}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy, size: 20, color: Colors.grey),
                                tooltip: 'Copy Details',
                                onPressed: () {
                                  final text = "Exercise: ${exercise.name}\nDescription: ${exercise.description}";
                                  Clipboard.setData(ClipboardData(text: text));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Details copied to clipboard!'), duration: Duration(seconds: 1)),
                                  );
                                },
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 14),
                            ],
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

  Widget _buildFilterBar(List<String> categories, List<String> difficulties) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildDropdownFilter("Category", categories, _selectedCategory, (v) => setState(() => _selectedCategory = v!)),
          const SizedBox(width: 8),
          _buildDropdownFilter("Difficulty", difficulties, _selectedDifficulty, (v) => setState(() => _selectedDifficulty = v!)),
          const SizedBox(width: 8),
          _buildDropdownFilter("Sort By", ['Name (A-Z)', 'Difficulty'], _sortBy, (v) => setState(() => _sortBy = v!)),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(String label, List<String> options, String current, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
      ),
      child: DropdownButton<String>(
        value: current,
        underline: const SizedBox(),
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 12)))).toList(),
        onChanged: onChanged,
        style: const TextStyle(color: Colors.redAccent),
        icon: const Icon(Icons.arrow_drop_down, size: 18, color: Colors.redAccent),
      ),
    );
  }
}
