class Exercise {
  final String id;
  final String name;
  final String description;
  final String targetMuscle;
  final String difficulty;
  final String gifUrl;
  final List<String> steps;
  final String duration;
  final int sets;
  final int reps;
  final String categoryId;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.targetMuscle,
    required this.difficulty,
    required this.gifUrl,
    required this.steps,
    required this.duration,
    required this.sets,
    required this.reps,
    required this.categoryId,
  });

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    String? targetMuscle,
    String? difficulty,
    String? gifUrl,
    List<String>? steps,
    String? duration,
    int? sets,
    int? reps,
    String? categoryId,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetMuscle: targetMuscle ?? this.targetMuscle,
      difficulty: difficulty ?? this.difficulty,
      gifUrl: gifUrl ?? this.gifUrl,
      steps: steps ?? this.steps,
      duration: duration ?? this.duration,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      targetMuscle: json['targetMuscle'],
      difficulty: json['difficulty'],
      gifUrl: json['gifUrl'],
      steps: List<String>.from(json['steps']),
      duration: json['duration'],
      sets: json['sets'],
      reps: json['reps'],
      categoryId: json['categoryId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'targetMuscle': targetMuscle,
      'difficulty': difficulty,
      'gifUrl': gifUrl,
      'steps': steps,
      'duration': duration,
      'sets': sets,
      'reps': reps,
      'categoryId': categoryId,
    };
  }
}
