import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/plants_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/add_plant_screen.dart';
import 'screens/login_screen.dart';

import 'package:plant_twin/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getString('access_token') != null;

  runApp(PlantTwinApp(isLoggedIn: isLoggedIn));
}

class PlantTwinApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const PlantTwinApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GreenTwin',
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: const Color(0xFFF2F5F0), // Soft mint-grey
      ),
      home: isLoggedIn ? const MainNav() : const LoginScreen(),
    );
  }
}

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _index = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    InsightsScreen(),
    AddPlantScreen(), 
    PlantsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Crucial for floating navbar effect
      body: _screens[_index],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: NavigationBar(
            height: 70,
            backgroundColor: Colors.white.withOpacity(0.9),
            elevation: 0,
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            indicatorColor: AppTheme.primaryGreen.withOpacity(0.2),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined), 
                selectedIcon: Icon(Icons.home, color: AppTheme.primaryGreen),
                label: "Home"
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined), 
                selectedIcon: Icon(Icons.insights, color: AppTheme.primaryGreen),
                label: "Insights"
              ),
              NavigationDestination(
                icon: Icon(Icons.add_circle_outline, size: 30), 
                selectedIcon: Icon(Icons.add_circle, color: AppTheme.primaryGreen, size: 30),
                label: "Add"
              ),
              NavigationDestination(
                icon: Icon(Icons.local_florist_outlined), 
                selectedIcon: Icon(Icons.local_florist, color: AppTheme.primaryGreen),
                label: "Plants"
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline), 
                selectedIcon: Icon(Icons.person, color: AppTheme.primaryGreen),
                label: "Profile"
              ),
            ],
          ),
        ),
      ),
    );
  }
}
