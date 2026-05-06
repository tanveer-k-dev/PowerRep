import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_provider.dart';
import 'edit_exercise_screen.dart';
import 'edit_category_screen.dart';
import '../widgets/app_image.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataState = ref.watch(dataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: 'Migrate Mock Data to Firebase',
            onPressed: () => _confirmMigration(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(firebaseServiceProvider).signOut();
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Exercises', icon: Icon(Icons.fitness_center)),
            Tab(text: 'Categories', icon: Icon(Icons.category)),
          ],
          indicatorColor: Colors.redAccent,
          labelColor: Colors.redAccent,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExercisesList(context, ref, dataState),
          _buildCategoriesList(context, ref, dataState),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditExerciseScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditCategoryScreen()),
            );
          }
        },
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExercisesList(BuildContext context, WidgetRef ref, DataState state) {
    return ListView.builder(
      itemCount: state.exercises.length,
      itemBuilder: (context, index) {
        final exercise = state.exercises[index];
        return ListTile(
          leading: SizedBox(
            width: 40,
            height: 40,
            child: ClipOval(
              child: AppImage(imageUrl: exercise.gifUrl, fit: BoxFit.cover),
            ),
          ),
          title: Text(exercise.name),
          subtitle: Text(exercise.targetMuscle),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditExerciseScreen(exercise: exercise)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context, () {
                  ref.read(dataProvider.notifier).deleteExercise(exercise.id);
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesList(BuildContext context, WidgetRef ref, DataState state) {
    return ListView.builder(
      itemCount: state.categories.length,
      itemBuilder: (context, index) {
        final category = state.categories[index];
        return ListTile(
          leading: SizedBox(
            width: 40,
            height: 40,
            child: ClipOval(
              child: AppImage(imageUrl: category.imageUrl, fit: BoxFit.cover),
            ),
          ),
          title: Text(category.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditCategoryScreen(category: category)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context, () {
                  ref.read(dataProvider.notifier).deleteCategory(category.id);
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              onDelete();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmMigration(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Migrate Data'),
        content: const Text('This will upload all 180+ mock exercises to your real Firebase project. This may take a minute and should only be done once. Proceed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Starting migration...')));
              await ref.read(dataProvider.notifier).migrateToFirebase();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Migration Complete!')));
            },
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }
}
