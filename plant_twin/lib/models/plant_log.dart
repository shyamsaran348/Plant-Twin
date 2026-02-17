class PlantLog {
  final int id;
  final int plantId;
  final double height;
  final double healthScore;
  final String? imagePath;
  final DateTime createdAt;

  PlantLog({
    required this.id,
    required this.plantId,
    required this.height,
    required this.healthScore,
    this.imagePath,
    required this.createdAt,
  });

  factory PlantLog.fromJson(Map<String, dynamic> json) {
    return PlantLog(
      id: json['id'],
      plantId: json['plant_id'] ?? 0, 
      height: (json['height'] as num).toDouble(),
      healthScore: (json['health_score'] as num).toDouble(),
      imagePath: json['image_path'],
      createdAt: DateTime.parse(json['recorded_at'] ?? json['created_at'] ?? DateTime.now().toIso8601String()), 
    );
  }
}
