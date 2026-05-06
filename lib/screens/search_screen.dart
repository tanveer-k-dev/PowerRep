import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_provider.dart';
import 'exercise_detail_screen.dart';
import '../widgets/app_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  String _selectedMuscle = 'All';

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(dataProvider);
        
        final muscleGroups = ['All', ...state.exercises.map((e) => e.targetMuscle).toSet()];
        
        final filteredExercises = state.exercises.where((e) {
          final matchesQuery = e.name.toLowerCase().contains(_query.toLowerCase());
          final matchesMuscle = _selectedMuscle == 'All' || e.targetMuscle == _selectedMuscle;
          return matchesQuery && matchesMuscle;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search exercises...',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
          ),
          body: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: muscleGroups.map((muscle) {
                    final isSelected = _selectedMuscle == muscle;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(muscle),
                        selected: isSelected,
                        selectedColor: Colors.redAccent.withOpacity(0.3),
                        checkmarkColor: Colors.redAccent,
                        onSelected: (selected) {
                          setState(() {
                            _selectedMuscle = muscle;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: filteredExercises.isEmpty
                    ? const Center(child: Text('No exercises found.'))
                    : ListView.builder(
                        itemCount: filteredExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = filteredExercises[index];
                          return ListTile(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExerciseDetailScreen(exercise: exercise),
                              ),
                            ),
                            leading: SizedBox(
                              width: 40,
                              height: 40,
                              child: ClipOval(
                                child: AppImage(imageUrl: exercise.gifUrl, fit: BoxFit.cover),
                              ),
                            ),
                            title: Text(exercise.name),
                            subtitle: Text(exercise.targetMuscle),
                            trailing: const Icon(Icons.chevron_right),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
