class LearningProgress {
  final int currentStage; // 1, 2 или 3
  final int trainerChatsCompleted;
  final bool styleAnalyzed;

  LearningProgress({
    this.currentStage = 1,
    this.trainerChatsCompleted = 0,
    this.styleAnalyzed = false,
  });

  // Из JSON
  factory LearningProgress.fromJson(Map<String, dynamic> json) {
    return LearningProgress(
      // Явное приведение с учётом возможного null
      currentStage: json['currentStage'] as int? ?? 1,
      trainerChatsCompleted: json['trainerChatsCompleted'] as int? ?? 0,
      styleAnalyzed: json['styleAnalyzed'] as bool? ?? false,
    );
  }

  // В JSON
  Map<String, dynamic> toJson() {
    return {
      'currentStage': currentStage,
      'trainerChatsCompleted': trainerChatsCompleted,
      'styleAnalyzed': styleAnalyzed,
    };
  }

  // Копия с обновлёнными полями (для удобства)
  LearningProgress copyWith({
    int? currentStage,
    int? trainerChatsCompleted,
    bool? styleAnalyzed,
  }) {
    return LearningProgress(
      currentStage: currentStage ?? this.currentStage,
      trainerChatsCompleted:
          trainerChatsCompleted ?? this.trainerChatsCompleted,
      styleAnalyzed: styleAnalyzed ?? this.styleAnalyzed,
    );
  }
}
