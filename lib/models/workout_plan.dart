class WorkoutPlan {
  final String day;
  final String targetMuscle;
  final List<String> exerciseIds;

  WorkoutPlan({
    required this.day,
    required this.targetMuscle,
    required this.exerciseIds,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      day: json['day'],
      targetMuscle: json['targetMuscle'],
      exerciseIds: List<String>.from(json['exerciseIds']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'targetMuscle': targetMuscle,
      'exerciseIds': exerciseIds,
    };
  }
}
