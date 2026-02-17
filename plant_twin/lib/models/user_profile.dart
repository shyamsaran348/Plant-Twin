class GardenStats {
  final int totalPlants;
  final int flowering;
  final int vegetables;
  final int herbs;
  final int streakDays;
  final String gardenStatus;

  GardenStats({
    required this.totalPlants,
    required this.flowering,
    required this.vegetables,
    required this.herbs,
    required this.streakDays,
    required this.gardenStatus,
  });

  factory GardenStats.fromJson(Map<String, dynamic> json) {
    return GardenStats(
      totalPlants: json['total_plants'] ?? 0,
      flowering: json['flowering'] ?? 0,
      vegetables: json['vegetables'] ?? 0,
      herbs: json['herbs'] ?? 0,
      streakDays: json['streak_days'] ?? 0,
      gardenStatus: json['garden_status'] ?? "Unknown",
    );
  }
}

class UserProfile {
  final int id;
  final String email;
  final String? fullName;
  final String? gardenType;
  final GardenStats stats;

  UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.gardenType,
    required this.stats,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      gardenType: json['garden_type'],
      stats: GardenStats.fromJson(json['garden_stats']),
    );
  }
}
