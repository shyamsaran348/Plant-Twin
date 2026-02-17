import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/plant.dart';
import '../widgets/plant_card.dart';
import 'plant_detail_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Plant>> _plantsFuture;

  // Mock user data (later load from Profile/User API if available)
  final String userName = "Gardener"; 
  final String gardenType = "Indoor"; 

  @override
  void initState() {
    super.initState();
    _refreshPlants();
  }

  void _refreshPlants() {
    setState(() {
      _plantsFuture = _apiService.getPlants();
    });
  }

  void _logout() async {
    await _apiService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  String _getBackgroundForGarden(String type) {
    // Keep existing logic
    return "https://images.unsplash.com/photo-1506744038136-46273834b3fb";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                image: const DecorationImage(
                  image: NetworkImage("https://images.unsplash.com/photo-1466692476868-aef1dfb1e735?q=80&w=2070&auto=format&fit=crop"),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.person, size: 30, color: Colors.green),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Welcome Back,",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    userName,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const ListTile(leading: Icon(Icons.person), title: Text("Profile")),
            const ListTile(leading: Icon(Icons.settings), title: Text("Settings")),
            ListTile(
              leading: const Icon(Icons.logout), 
              title: const Text("Logout"),
              onTap: _logout,
            ),
          ],
        ),
      ),

      body: CustomScrollView(
        slivers: [
          // 1. Sliver AppBar with Weather
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("My Garden"),
              background: Stack(
                fit: StackFit.expand,
                children: [
                   Image.network(
                    "https://images.unsplash.com/photo-1558293842-c0fd3db8415e?q=80&w=2070&auto=format&fit=crop",
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                  // Weather Mockup
                  Positioned(
                    bottom: 60,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.wb_sunny, color: Colors.orangeAccent, size: 24),
                            SizedBox(width: 8),
                            Text("26°C  Sunny", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text("Humidity: 45% • Wind: 5km/h", style: TextStyle(color: Colors.white.withOpacity(0.9))),
                      ],
                    ),
                  )
                ],
              ),
            ),
            actions: [
               IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {},
              ),
            ],
          ),

          // 2. Tip of the Day
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1), // Amber/Cream
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.amber, size: 30),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Gardener's Tip", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                          SizedBox(height: 4),
                          Text("Morning sun is best for most plants. Check soil moisture daily!", style: TextStyle(fontSize: 13, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Plant List
          FutureBuilder<List<Plant>>(
            future: _plantsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              } else if (snapshot.hasError) {
                 return SliverFillRemaining(child: Center(child: Text("Error: ${snapshot.error}")));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text("No plants yet. Tap '+' to add one!"),
                  ),
                );
              }

              final plants = snapshot.data!;
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final plant = plants[index];
                    final imageUrl = plant.imagePath != null 
                        ? _apiService.getImageUrl(plant.imagePath!) 
                        : null;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlantDetailScreen(
                                plantId: plant.id,
                                plantName: plant.name,
                              ),
                            ),
                          );
                          _refreshPlants(); 
                        },
                        child: PlantCard(
                          plant: plant,
                          imageUrl: imageUrl, 
                        ),
                      ),
                    );
                  },
                  childCount: plants.length,
                ),
              );
            },
          ),
          
          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

// Ensure Environment Items are kept if used (omitted for brevity if not used in updated design, but good to keep)
class _EnvItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;

  const _EnvItem({
    required this.icon,
    required this.label,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(sub, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
