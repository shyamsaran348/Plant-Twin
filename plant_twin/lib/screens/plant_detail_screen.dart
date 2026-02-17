import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../models/plant.dart';
import '../models/plant_log.dart';
import '../models/reminder.dart';
import '../services/api_service.dart';
import 'package:plant_twin/theme/app_theme.dart';
import 'dart:ui'; // For ImageFilter

class PlantDetailScreen extends StatefulWidget {
  final int plantId;
  final String plantName;

  const PlantDetailScreen({super.key, required this.plantId, required this.plantName});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Plant> _plantFuture;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _refreshPlant();
  }

  void _refreshPlant() {
    setState(() {
      _plantFuture = _apiService.getPlantDetails(widget.plantId);
    });
  }

  void _waterPlant() async {
    try {
      final msg = await _apiService.waterPlant(widget.plantId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      _refreshPlant();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Watering failed: $e")));
    }
  }

  void _logGrowth() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    final TextEditingController heightController = TextEditingController();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Log Growth"),
        content: TextField(
          controller: heightController,
          decoration: const InputDecoration(labelText: "Height (cm)", border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final double? height = double.tryParse(heightController.text);
              if (height == null) return;
              
              Navigator.pop(context); // Close dialog
              try {
                await _apiService.addPlantLog(widget.plantId, height, image);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Growth Logged!")));
                _refreshPlant();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $e")));
              }
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void _updateGrowthStage(String currentStage) {
    final List<String> stages = ["Seedling", "Vegetative", "Flowering", "Fruiting", "HarvestReady"];
    String selectedStage = stages.contains(currentStage) ? currentStage : stages.first;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Update Stage"),
            content: DropdownButton<String>(
              value: selectedStage,
              isExpanded: true,
              items: stages.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => selectedStage = val!),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _apiService.updateGrowthStage(widget.plantId, selectedStage);
                    Navigator.pop(context);
                    _refreshPlant();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $e")));
                  }
                },
                child: const Text("Update"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F0),
      body: FutureBuilder<Plant>(
        future: _plantFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Plant not found"));
          }

          final plant = snapshot.data!;
          final state = plant.plantState;
          final List<PlantLog> logs = plant.logs ?? [];

          return CustomScrollView(
            slivers: [
              // 1. Premium Sliver Key Image
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                backgroundColor: AppTheme.primaryGreen,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(plant.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black45, blurRadius: 5)])),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      plant.imagePath != null
                          ? Image.network(_apiService.getImageUrl(plant.imagePath!), fit: BoxFit.cover)
                          : Container(color: Colors.green.shade200, child: const Icon(Icons.park, size: 80, color: Colors.white)),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: (){}),
                ],
              ),

              // 2. Vitals Cards (Floating overlap)
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -30),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildVitalsRow(state),
                        const SizedBox(height: 20),
                        
                        // 3. Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _actionButton("Water", Icons.water_drop, Colors.blue, _waterPlant),
                            _actionButton("Log", Icons.camera_alt, Colors.purple, _logGrowth),
                            _actionButton("Stage", Icons.timeline, Colors.orange, () => _updateGrowthStage(state?.growthStage ?? "Seedling")),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // 4. Growth Chart
                        _sectionTitle("Growth History"),
                        const SizedBox(height: 10),
                        _buildGrowthChart(logs),

                        const SizedBox(height: 30),

                        // 5. Recent Logs List
                        _sectionTitle("Recent Updates"),
                        const SizedBox(height: 10),
                        _buildLogsList(logs),
                        
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVitalsRow(PlantState? state) {
    if (state == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _vitalItem("Health", "${state.healthScore.toInt()}%", Icons.favorite, state.healthScore > 80 ? Colors.green : Colors.red),
          _verticalDivider(),
          _vitalItem("Water", state.waterStress < 0.3 ? "Good" : "Low", Icons.water_drop, Colors.blue),
          _verticalDivider(),
          _vitalItem("Stage", state.growthStage, Icons.eco, Colors.orange),
        ],
      ),
    );
  }

  Widget _vitalItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      ],
    );
  }

  Widget _verticalDivider() => Container(height: 40, width: 1, color: Colors.grey.shade200);

  Widget _actionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      ],
    );
  }

  Widget _buildGrowthChart(List<PlantLog> logs) {
    if (logs.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        alignment: Alignment.center,
        child: const Text("No growth data yet", style: TextStyle(color: Colors.grey)),
      );
    }
  
    // Sort logs by date just in case
    logs.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10)],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: logs.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.height)).toList(),
              isCurved: true,
              color: AppTheme.primaryGreen,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: AppTheme.primaryGreen.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsList(List<PlantLog> logs) {
    if (logs.isEmpty) return const SizedBox.shrink();

    return Column(
      children: logs.reversed.take(3).map((log) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: log.imagePath != null 
                    ? DecorationImage(image: NetworkImage(_apiService.getImageUrl(log.imagePath!)), fit: BoxFit.cover)
                    : null,
                  color: Colors.grey.shade100,
                ),
                child: log.imagePath == null ? const Icon(Icons.image_not_supported) : null,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Height: ${log.height} cm", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(DateFormat('MMM d, y').format(log.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)));
  }
}
