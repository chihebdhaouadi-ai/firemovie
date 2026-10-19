enum AchievementLevel { rookie, master, legend }

class ProfileAchievement {
  const ProfileAchievement({required this.level, required this.films});

  final AchievementLevel level;
  final int films;
}

/// Dummy values for profile fields the backend does not provide yet.
abstract final class ProfilePlaceholders {
  static const tag = '#54321';
  static const rewards = 0;

  static const achievements = [
    ProfileAchievement(level: AchievementLevel.rookie, films: 250),
    ProfileAchievement(level: AchievementLevel.master, films: 500),
    ProfileAchievement(level: AchievementLevel.legend, films: 1000),
  ];
}
