class PlantLog {
  final int id;
  final int plantId;
  final double height;
  final double healthScore;
  final DateTime createdAt;

  PlantLog({
    required this.id,
    required this.plantId,
    required this.height,
    required this.healthScore,
    required this.createdAt,
  });

  factory PlantLog.fromJson(Map<String, dynamic> json) {
    return PlantLog(
      id: json['id'],
      plantId: json['plant_id'] ?? 0, // Handle missing plant_id
      height: (json['height'] as num).toDouble(),
      healthScore: (json['health_score'] as num).toDouble(),
      createdAt: DateTime.parse(json['recorded_at'] ?? json['created_at'] ?? DateTime.now().toIso8601String()), // Handle key mismatch
    );
  }
}
