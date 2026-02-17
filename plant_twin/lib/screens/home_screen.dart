import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/plant.dart';
import '../widgets/plant_card.dart';
import 'plant_detail_screen.dart';
import 'package:plant_twin/theme/app_theme.dart';
import 'dart:ui'; // For ImageFilter

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Plant>> _plantsFuture;
  String userName = "Green Thumb";
  
  @override
  void initState() {
    super.initState();
    _refreshPlants();
    _fetchUserProfile();
  }

  void _fetchUserProfile() async {
    try {
      final profile = await _apiService.getUserProfile();
      setState(() => userName = profile.fullName ?? "Green Thumb");
    } catch (e) {
      // minimal error handling for user profile load
    }
  }

  void _refreshPlants() {
    setState(() {
      _plantsFuture = _apiService.getPlants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F0),
      body: CustomScrollView(
        slivers: [
          // 1. Premium Header (Replaces AppBar)
          SliverPersistentHeader(
            delegate: _HomeHeaderDelegate(userName: userName),
            pinned: true,
          ),

          // 2. Weather & Jungle Summary
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                   const SizedBox(height: 20),
                   _buildWeatherWidget(),
                   const SizedBox(height: 20),
                   _buildJungleSummary(),
                   const SizedBox(height: 20),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text("My Plants", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
                       TextButton(onPressed: (){}, child: const Text("View All"))
                     ],
                   ),
                ],
              ),
            ),
          ),

          // 3. Plant List (Enhanced)
          FutureBuilder<List<Plant>>(
            future: _plantsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text("Your jungle is empty. Add a plant! 🌱")),
                );
              }

              final plants = snapshot.data!;
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final plant = plants[index];
                    return _buildAnimatedPlantCard(plant, index);
                  },
                  childCount: plants.length,
                ),
              );
            },
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildAnimatedPlantCard(Plant plant, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlantDetailScreen(plantId: plant.id, plantName: plant.name),
            ),
          );
          _refreshPlants();
        },
        child: PlantCard(plant: plant, imageUrl: plant.imagePath != null ? _apiService.getImageUrl(plant.imagePath!) : null),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildWeatherWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Sunny", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Perfect gardening weather", style: TextStyle(color: Colors.white.withOpacity(0.9))),
            ],
          ),
          const Row(
            children: [
              Text("24°", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Icon(Icons.wb_sunny, color: Colors.amber, size: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJungleSummary() {
    return Row(
      children: [
        Expanded(child: _summaryCard("Attention", "2 Plants", Icons.warning_amber, Colors.orange)),
        const SizedBox(width: 15),
        Expanded(child: _summaryCard("Thriving", "8 Plants", Icons.check_circle_outline, Colors.green)),
      ],
    );
  }

  Widget _summaryCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subtitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String userName;
  const _HomeHeaderDelegate({required this.userName});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = shrinkOffset / maxExtent;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.network(
            "https://images.unsplash.com/photo-1466692476868-aef1dfb1e735?q=80&w=2070&auto=format&fit=crop",
            fit: BoxFit.cover,
          ),
          // Blur (Glassmorphism)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5 * progress, sigmaY: 5 * progress),
            child: Container(color: Colors.black.withOpacity(0.3 + (progress * 0.4))),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28 - (progress * 8),
                    backgroundColor: Colors.white,
                    child: Text(userName.substring(0,1).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Good Morning,", style: TextStyle(color: Colors.white70, fontSize: 14 - (progress * 2))),
                      Text(userName, style: TextStyle(color: Colors.white, fontSize: 24 - (progress * 6), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(onPressed: (){}, icon: const Icon(Icons.notifications, color: Colors.white)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  double get maxExtent => 180;
  @override
  double get minExtent => 110;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
