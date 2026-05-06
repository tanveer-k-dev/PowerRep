import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/exercise.dart';
import '../providers/data_provider.dart';
import '../utils/image_utils.dart';
import '../widgets/app_image.dart';

class EditExerciseScreen extends ConsumerStatefulWidget {
  final Exercise? exercise;
  const EditExerciseScreen({super.key, this.exercise});

  @override
  ConsumerState<EditExerciseScreen> createState() => _EditExerciseScreenState();
}

class _EditExerciseScreenState extends ConsumerState<EditExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _muscleController;
  late TextEditingController _gifUrlController;
  late TextEditingController _durationController;
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  String? _selectedCategoryId;
  String _difficulty = 'Beginner';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise?.name ?? '');
    _descController = TextEditingController(text: widget.exercise?.description ?? '');
    _muscleController = TextEditingController(text: widget.exercise?.targetMuscle ?? '');
    _gifUrlController = TextEditingController(text: widget.exercise?.gifUrl ?? 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExNHJndXp4OHRxcXp4NXp4NXp4NXp4NXp4NXp4NXp4NXp4NXp4NXp4JmVwPXYxX2ludGVybmFsX2dpZl9ieV9pZCZjdD1n/3o7TKVUn7iM8FMEU24/giphy.gif');
    _durationController = TextEditingController(text: widget.exercise?.duration ?? '60s');
    _setsController = TextEditingController(text: widget.exercise?.sets.toString() ?? '3');
    _repsController = TextEditingController(text: widget.exercise?.reps.toString() ?? '10');
    _selectedCategoryId = widget.exercise?.categoryId;
    _difficulty = widget.exercise?.difficulty ?? 'Beginner';
  }

  Future<void> _pickImage() async {
    final path = await ImageUtils.pickAndSaveImage();
    if (path != null) {
      setState(() {
        _gifUrlController.text = path; // Use controller to hold the path
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')),
        );
        return;
      }

      final exercise = Exercise(
        id: widget.exercise?.id ?? const Uuid().v4(),
        name: _nameController.text,
        description: _descController.text,
        targetMuscle: _muscleController.text,
        difficulty: _difficulty,
        gifUrl: _gifUrlController.text,
        steps: widget.exercise?.steps ?? ['Step 1', 'Step 2'],
        duration: _durationController.text,
        sets: int.parse(_setsController.text),
        reps: int.parse(_repsController.text),
        categoryId: _selectedCategoryId!,
      );

      if (widget.exercise == null) {
        ref.read(dataProvider.notifier).addExercise(exercise);
      } else {
        ref.read(dataProvider.notifier).updateExercise(exercise);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(dataProvider).categories;

    return Scaffold(
      appBar: AppBar(title: Text(widget.exercise == null ? 'Add Exercise' : 'Edit Exercise')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                  ),
                  child: _gifUrlController.text.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AppImage(imageUrl: _gifUrlController.text, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 50, color: Colors.redAccent),
                            SizedBox(height: 10),
                            Text('Tap to upload GIF/Image'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _gifUrlController,
                decoration: const InputDecoration(labelText: 'GIF URL or Local Path'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _muscleController,
                decoration: const InputDecoration(labelText: 'Target Muscle'),
              ),
              DropdownButtonFormField<String>(
                initialValue: _difficulty,
                decoration: const InputDecoration(labelText: 'Difficulty'),
                items: ['Beginner', 'Intermediate', 'Hard'].map((d) {
                  return DropdownMenuItem(value: d, child: Text(d));
                }).toList(),
                onChanged: (v) => setState(() => _difficulty = v!),
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories.map((c) {
                  return DropdownMenuItem(value: c.id, child: Text(c.name));
                }).toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v!),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _setsController,
                      decoration: const InputDecoration(labelText: 'Sets'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _repsController,
                      decoration: const InputDecoration(labelText: 'Reps'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                  child: const Text('Save Exercise'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
