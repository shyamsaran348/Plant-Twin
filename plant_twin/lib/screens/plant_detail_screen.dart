import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/plant.dart';
import '../models/reminder.dart';
import '../models/plant_log.dart';
import 'package:plant_twin/theme/app_theme.dart';
import 'disease_analysis_screen.dart';

class PlantDetailScreen extends StatefulWidget {
  final int plantId;
  final String plantName;

  const PlantDetailScreen({
    super.key,
    required this.plantId,
    required this.plantName,
  });

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Plant> _plantFuture;
  List<Reminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _refreshPlant();
    _loadReminders();
  }

  void _refreshPlant() {
    setState(() {
      _plantFuture = _apiService.getPlantDetails(widget.plantId);
    });
  }

  void _loadReminders() async {
    try {
      final reminders = await _apiService.getReminders();
      if (mounted) {
        setState(() {
          _reminders = reminders.where((r) => r.plantId == widget.plantId).toList();
        });
      }
    } catch (e) {
      print("Error loading reminders: $e");
    }
  }

  // --- Features ---

  void _waterPlant() async {
    try {
      await _apiService.waterPlant(widget.plantId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Plant watered! Health updated.")));
      _refreshPlant();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Watering failed: $e")));
    }
  }

  void _analyzeDisease() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    
    if (pickedFile != null) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final result = await _apiService.analyzeDisease(widget.plantId, pickedFile);
        if (mounted) Navigator.pop(context);

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DiseaseAnalysisScreen(
                imageFile: pickedFile,
                analysisResult: result,
                onRetake: _analyzeDisease,
                onSave: _refreshPlant,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Analysis failed: $e")));
      }
    }
  }

  void _logGrowth() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Log Growth"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Height (cm)", suffixText: "cm"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              try {
                final height = double.parse(controller.text);
                await _apiService.addPlantLog(widget.plantId, height);
                Navigator.pop(context);
                _refreshPlant();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Growth logged!")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $e")));
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _updateEnvironment() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Update Environment"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Temperature (°C)", suffixText: "°C"),
        ),
        actions: [
           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
           ElevatedButton(
            onPressed: () async {
              try {
                final temp = double.parse(controller.text);
                await _apiService.updateEnvironment(widget.plantId, temp);
                Navigator.pop(context);
                _refreshPlant();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Environment updated! State recalculated.")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $e")));
              }
            },
            child: const Text("Update"),
           ),
        ],
      ),
    );
  }

  void _getAdvice(String species) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final advice = await _apiService.getAdvice(species, 25.0);
      if (mounted) Navigator.pop(context);

      if (mounted) {
        showModalBottomSheet(
          context: context,
          builder: (_) => Container(
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                  children: [
                    Icon(Icons.spa, color: AppTheme.primaryGreen),
                    const SizedBox(width: 8),
                    Text("Care Advice for $species", style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 16),
                Text(advice['care_advice'] ?? "No advice available.", style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Got it"),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  void _addReminder() {
    final typeController = TextEditingController();
    final freqController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Reminder"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: typeController, decoration: const InputDecoration(labelText: "Type (e.g., Water, Fertilizer)")),
            const SizedBox(height: 10),
            TextField(controller: freqController, decoration: const InputDecoration(labelText: "Frequency (e.g., Daily, Weekly)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.createReminder(
                  widget.plantId,
                  typeController.text,
                  DateTime.now().toIso8601String(), 
                  freqController.text,
                );
                Navigator.pop(context);
                _loadReminders();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $e")));
              }
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Plant>(
      future: _plantFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(appBar: AppBar(), body: Center(child: Text("Error: ${snapshot.error}")));
        } else if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text("Plant not found")));
        }

        final plant = snapshot.data!;
        final state = plant.plantState;
        final health = state?.healthScore ?? 100.0;
        final waterStress = state?.waterStress ?? 0.0;
        final logs = plant.logs ?? [];
        
        final imageUrl = plant.imagePath != null 
            ? _apiService.getImageUrl(plant.imagePath!) 
            : null;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(plant.name, style: const TextStyle(shadows: [Shadow(color: Colors.black, blurRadius: 10)])),
                  background: imageUrl != null 
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : Container(color: Colors.green.shade200, child: const Icon(Icons.local_florist, size: 80, color: Colors.white)),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _updateEnvironment, 
                    tooltip: "Simulate Environment",
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Vital Signs Grid
                      Text("Vital Signs", style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildVitalCard("Health", "${health.toInt()}%", Icons.favorite, health > 50 ? Colors.green : Colors.red)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildVitalCard("Water", waterStress > 0.5 ? "Low" : "Good", Icons.water_drop, waterStress > 0.5 ? Colors.red : Colors.blue)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildVitalCard("State", state?.growthStage ?? "N/A", Icons.park, Colors.purple)),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 2. Action Buttons
                      SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _waterPlant,
                              icon: const Icon(Icons.water_drop),
                              label: const Text("Water"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: _analyzeDisease,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text("Diagnose"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: () => _getAdvice(plant.species),
                              icon: const Icon(Icons.lightbulb),
                              label: const Text("Tips"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: _logGrowth,
                              icon: const Icon(Icons.bar_chart),
                              label: const Text("Log Growth"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 3. Growth Chart
                      Text("Growth Timeline", style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      Container(
                        height: 250,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                        ),
                        child: logs.isEmpty 
                          ? const Center(child: Text("No growth data yet. Tap 'Log Growth' to start!"))
                          : LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: true, drawVerticalLine: false),
                                titlesData: FlTitlesData(
                                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() >= 0 && value.toInt() < logs.length) {
                                           final date = logs[value.toInt()].createdAt;
                                           return Padding(
                                             padding: const EdgeInsets.only(top: 8.0),
                                             child: Text(DateFormat('MM/dd').format(date), style: const TextStyle(fontSize: 10)),
                                           );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: logs.asMap().entries.map((e) {
                                      return FlSpot(e.key.toDouble(), e.value.height);
                                    }).toList(),
                                    isCurved: true,
                                    color: AppTheme.primaryGreen,
                                    barWidth: 3,
                                    dotData: const FlDotData(show: true),
                                    belowBarData: BarAreaData(show: true, color: AppTheme.primaryGreen.withOpacity(0.1)),
                                  ),
                                ],
                              ),
                            ),
                      ),

                      const SizedBox(height: 30),

                      // 4. Disease History Gallery
                      if (plant.diseaseRecords != null && plant.diseaseRecords!.isNotEmpty) ...[
                        Text("Health History", style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 140,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: plant.diseaseRecords!.length,
                            itemBuilder: (context, index) {
                              final record = plant.diseaseRecords![index];
                              return Container(
                                width: 120,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                        child: Image.network(
                                          _apiService.getImageUrl(record.imagePath),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (c,e,s) => const Icon(Icons.broken_image),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(record.predictedClass, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          Text(DateFormat('MM/dd').format(DateTime.parse(record.timestamp)), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 30),

                      // 5. Reminders
                      _sectionHeader("Upcoming Reminders", Icons.alarm, () => _addReminder()),
                      if (_reminders.isEmpty)
                        const Padding(
                           padding: EdgeInsets.all(8),
                           child: Text("No reminders set. Tap + to add one."),
                        )
                      else
                        Column(
                          children: _reminders.map((r) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange.shade100,
                                child: Icon(Icons.notifications, color: Colors.orange.shade800),
                              ),
                              title: Text(r.type),
                              subtitle: Text("Every ${r.frequency}"),
                              trailing: Text(DateFormat('MMM dd').format(DateTime.parse(r.nextDueDate))),
                            ),
                          )).toList(),
                        ),
                          
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVitalCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        IconButton(onPressed: onAdd, icon: const Icon(Icons.add_circle, color: AppTheme.primaryGreen)),
      ],
    );
  }
}
