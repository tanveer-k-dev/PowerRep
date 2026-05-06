import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/data_provider.dart';
import '../widgets/logo.dart';
import 'exercise_list_screen.dart';
import 'weekly_plan_screen.dart';
import 'favorites_screen.dart';
import 'exercise_detail_screen.dart';
import 'search_screen.dart';
import 'login_screen.dart';
import 'admin_panel_screen.dart';
import 'all_exercises_screen.dart';
import '../widgets/app_image.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkBackendAccess();
  }

  Future<void> _checkBackendAccess() async {
    final prefs = await SharedPreferences.getInstance();
    final hasAsked = prefs.getBool('has_asked_be') ?? false;

    if (!hasAsked) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Backend Access'),
          content: const Text('Have you added BE so I can go and add some exercise?'),
          actions: [
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                await prefs.setBool('has_asked_be', true);
                navigator.pop();
              },
              child: const Text('No, continue offline'),
            ),
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                await prefs.setBool('has_asked_be', true);
                navigator.pop();
              },
              child: const Text('Yes, it is ready'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataState = ref.watch(dataProvider);

    if (dataState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('PowerRep'),
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: PowerRepLogo(size: 30),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Admin',
            onPressed: () {
              final authState = ref.read(authStateProvider);
              authState.when(
                data: (user) {
                  if (user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
                },
                loading: () {},
                error: (_, __) {},
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.redAccent),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, 'Weekly Plan', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WeeklyPlanScreen()),
                );
              }),
              const SizedBox(height: 10),
              _buildWeeklyOverview(dataState),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Categories', null),
              const SizedBox(height: 10),
              _buildCategoriesGrid(context, dataState),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'All Exercises', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AllExercisesScreen()),
                );
              }),
              const SizedBox(height: 10),
              _buildFeaturedExercises(context, dataState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, VoidCallback? onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (onTap != null)
          TextButton(
            onPressed: onTap,
            child: const Text('See All', style: TextStyle(color: Colors.redAccent)),
          ),
      ],
    );
  }

  Widget _buildWeeklyOverview(DataState state) {
    if (state.plans.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text("No plans available. Login as admin to migrate data."),
      );
    }

    final today = DateTime.now().weekday;
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final currentDayName = dayNames[today - 1];
    
    // Find today's plan or default to the first available plan
    final todayPlan = state.plans.firstWhere(
      (p) => p.day == currentDayName, 
      orElse: () => state.plans[0]
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Goal: ${todayPlan.targetMuscle}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            "${todayPlan.exerciseIds.length} Exercises Scheduled",
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context, DataState state) {
    if (state.categories.isEmpty) {
      return const Center(child: Text("No categories found."));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemCount: state.categories.length,
      itemBuilder: (context, index) {
        final category = state.categories[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseListScreen(category: category),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AppImage(
                      imageUrl: category.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedExercises(BuildContext context, DataState state) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.exercises.length > 3 ? 3 : state.exercises.length,
      itemBuilder: (context, index) {
        final exercise = state.exercises[index];
        return ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseDetailScreen(exercise: exercise),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppImage(imageUrl: exercise.gifUrl, fit: BoxFit.cover),
            ),
          ),
          title: Text(exercise.name),
          subtitle: Text("${exercise.targetMuscle} • ${exercise.difficulty}"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        );
      },
    );
  }
}
