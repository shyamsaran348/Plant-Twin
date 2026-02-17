import 'plant_log.dart';

class Plant {
  final int id;
  final String name;
  final String species;
  final int? userId;
  final String? imagePath;
  final PlantState? plantState;
  final List<DiseaseRecord>? diseaseRecords;
  final List<PlantLog>? logs;

  Plant({
    required this.id,
    required this.name,
    required this.species,
    this.userId,
    this.imagePath,
    this.plantState,
    this.diseaseRecords,
    this.logs,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'],
      name: json['name'],
      species: json['species'],
      userId: json['user_id'],
      imagePath: json['image_path'], // Assuming backend returns relative path
      plantState: json['plant_state'] != null
          ? PlantState.fromJson(json['plant_state'])
          : null,
      diseaseRecords: json['disease_records'] != null
          ? (json['disease_records'] as List)
              .map((i) => DiseaseRecord.fromJson(i))
              .toList()
          : [],
      logs: json['logs'] != null
          ? (json['logs'] as List)
              .map((i) => PlantLog.fromJson(i))
              .toList()
          : [],
    );
  }
}

class PlantState {
  final int id;
  final double healthScore;
  final String growthStage;
  final double waterStress;
  final double heatStress;
  final double diseaseRiskIndex;

  PlantState({
    required this.id,
    required this.healthScore,
    required this.growthStage,
    required this.waterStress,
    required this.heatStress,
    required this.diseaseRiskIndex,
  });

  factory PlantState.fromJson(Map<String, dynamic> json) {
    return PlantState(
      id: json['id'],
      healthScore: (json['health_score'] as num).toDouble(),
      growthStage: json['growth_stage'],
      waterStress: (json['water_stress'] as num).toDouble(),
      heatStress: (json['heat_stress'] as num).toDouble(),
      diseaseRiskIndex: (json['disease_risk_index'] as num).toDouble(),
    );
  }
}

class DiseaseRecord {
  final int id;
  final String predictedClass;
  final double confidence;
  final String imagePath;
  final String timestamp;

  DiseaseRecord({
    required this.id,
    required this.predictedClass,
    required this.confidence,
    required this.imagePath,
    required this.timestamp,
  });

  factory DiseaseRecord.fromJson(Map<String, dynamic> json) {
    return DiseaseRecord(
      id: json['id'],
      predictedClass: json['predicted_class'],
      confidence: (json['confidence'] as num).toDouble(),
      imagePath: json['image_path'],
      timestamp: json['timestamp'],
    );
  }
}
