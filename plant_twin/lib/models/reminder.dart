class Reminder {
  final int id;
  final int plantId;
  final String type;
  final String nextDueDate;
  final String frequency;
  final bool isCompleted;

  Reminder({
    required this.id,
    required this.plantId,
    required this.type,
    required this.nextDueDate,
    required this.frequency,
    required this.isCompleted,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      plantId: json['plant_id'],
      type: json['reminder_type'], // Matches Pydantic schema
      nextDueDate: json['next_due_date'],
      frequency: json['frequency'],
      isCompleted: json['is_completed'],
    );
  }
}
