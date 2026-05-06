import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/data_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/logo.dart';
import 'weekly_plan_screen.dart';
import 'favorites_screen.dart';
import 'exercise_detail_screen.dart';
import 'search_screen.dart';
import 'login_screen.dart';
import 'admin_panel_screen.dart';
import 'all_exercises_screen.dart';
import 'advanced_exercise_list_screen.dart';
import 'tools_screen.dart';
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
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    if (dataState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModernTools(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Weekly Goal', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const WeeklyPlanScreen()));
                  }),
                  const SizedBox(height: 12),
                  _buildDailyHighlight(dataState),
                  const SizedBox(height: 32),
                  if (dataState.recentlyViewed.isNotEmpty) ...[
                    _buildSectionHeader('Jump Back In', null, subtitle: 'Recently viewed exercises'),
                    const SizedBox(height: 12),
                    _buildRecentScroll(dataState),
                    const SizedBox(height: 32),
                  ],
                  _buildSectionHeader('Categories', null, subtitle: '${dataState.categories.length} Training Styles'),
                  const SizedBox(height: 12),
                  _buildPremiumCategories(dataState),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Featured', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AllExercisesScreen()));
                  }, subtitle: 'Explore all ${dataState.exercises.length} exercises'),
                  const SizedBox(height: 12),
                  _buildFeaturedList(dataState),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        centerTitle: false,
        title: const PowerRepLogo(size: 28),
      ),
      actions: [
        IconButton(
          icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
        ),
        IconButton(
          icon: const Icon(Icons.admin_panel_settings_outlined),
          onPressed: () => _handleAdminNav(),
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => showSearch(context: context, delegate: ExerciseSearchDelegate(ref)),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Future<void> _handleAdminNav() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
    );
    final authState = ref.read(authStateProvider);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    Navigator.pop(context);
    authState.when(
      data: (user) {
        if (user != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPanelScreen()));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
        }
      },
      loading: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
      error: (err, stack) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Auth Error: $err'))),
    );
  }

  Widget _buildModernTools() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildToolBtn(Icons.add_task, "Custom", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomWorkoutPlanScreen()))),
          _buildToolBtn(Icons.analytics_outlined, "Progress", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProgressTrackingScreen()))),
          _buildToolBtn(Icons.favorite_outline, "Saved", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()))),
        ],
      ),
    );
  }

  Widget _buildToolBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.redAccent, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onTap, {String? subtitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500)),
            ],
          ],
        ),
        if (onTap != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: const Text('View All', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }

  Widget _buildDailyHighlight(DataState state) {
    if (state.plans.isEmpty) return const SizedBox();
    final today = DateTime.now().weekday;
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final currentDayName = dayNames[today - 1];
    final todayPlan = state.plans.firstWhere((p) => p.day == currentDayName, orElse: () => state.plans[0]);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                "TODAY: ${todayPlan.day.toUpperCase()}",
                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            todayPlan.targetMuscle,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            "${todayPlan.exerciseIds.length} Exercises ready for you",
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScroll(DataState state) {
    final recentEx = state.exercises.where((e) => state.recentlyViewed.contains(e.id)).toList();
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recentEx.length,
        clipBehavior: Clip.none,
        itemBuilder: (context, index) {
          final ex = recentEx[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ExerciseDetailScreen(exercise: ex))),
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Hero(tag: 'recent_${ex.id}', child: AppImage(imageUrl: ex.gifUrl, fit: BoxFit.cover)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumCategories(DataState state) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: state.categories.length,
      itemBuilder: (context, index) {
        final category = state.categories[index];
        final count = state.exercises.where((e) => e.categoryId == category.id).length;
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdvancedExerciseListScreen(title: category.name, exercises: state.exercises.where((e) => e.categoryId == category.id).toList()))),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AppImage(imageUrl: category.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                      Text("$count Exercises", style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedList(DataState state) {
    final list = state.exercises.take(5).toList();
    return Column(
      children: list.map((ex) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ExerciseDetailScreen(exercise: ex))),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppImage(imageUrl: ex.gifUrl, width: 64, height: 64),
            ),
            title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            subtitle: Text("${ex.targetMuscle} • ${ex.difficulty}", style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, color: Colors.redAccent),
          ),
        ),
      )).toList(),
    );
  }
}
