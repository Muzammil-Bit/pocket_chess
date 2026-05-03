enum AiDifficulty { easy, medium, hard }

extension AiDifficultyX on AiDifficulty {
  String get label {
    switch (this) {
      case AiDifficulty.easy:
        return 'Easy';
      case AiDifficulty.medium:
        return 'Medium';
      case AiDifficulty.hard:
        return 'Hard';
    }
  }

  int get minimaxDepth {
    switch (this) {
      case AiDifficulty.easy:
        return 1;
      case AiDifficulty.medium:
        return 2;
      case AiDifficulty.hard:
        return 3;
    }
  }

  int get stockfishSkillLevel {
    switch (this) {
      case AiDifficulty.easy:
        return 4;
      case AiDifficulty.medium:
        return 10;
      case AiDifficulty.hard:
        return 18;
    }
  }

  int get stockfishMoveTimeMs {
    switch (this) {
      case AiDifficulty.easy:
        return 250;
      case AiDifficulty.medium:
        return 500;
      case AiDifficulty.hard:
        return 900;
    }
  }

  String get storageValue => name;

  static AiDifficulty fromStorage(String? value) {
    return AiDifficulty.values.where((item) => item.name == value).firstOrNull ??
        AiDifficulty.medium;
  }
}
