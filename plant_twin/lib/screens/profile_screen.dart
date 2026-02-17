import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_profile.dart';
import 'login_screen.dart';
import 'package:plant_twin/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  UserProfile? _profile;
  bool _isEditing = false;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    try {
      final profile = await _apiService.getUserProfile();
      setState(() {
        _profile = profile;
        _nameController.text = profile.fullName ?? "";
        _typeController.text = profile.gardenType ?? "";
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final updatedProfile = await _apiService.updateProfile(_nameController.text, _typeController.text);
      setState(() {
        _profile = updatedProfile;
        _isEditing = false;
        _isLoading = false;
      });
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated!")));
    } catch (e) {
      setState(() => _isLoading = false);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $e")));
    }
  }

  void _logout() async {
    await _apiService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final stats = _profile!.stats;
    // Gamification Logic
    int level = (stats.totalPlants / 5).floor() + 1;
    double progress = (stats.totalPlants % 5) / 5.0;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Premium Header with Gradient
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                _buildHeaderBackground(),
                Positioned(
                  top: 100, // Overlap
                  child: _buildProfileCard(level, progress),
                ),
              ],
            ),
            
            const SizedBox(height: 140), // Spacing for the overlapping card

            // 2. Main Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Grid
                  _sectionHeader("Garden Analytics"),
                  const SizedBox(height: 15),
                  _buildStatsGrid(stats),
                  
                  const SizedBox(height: 30),

                  // Garden Health Status
                  _buildHealthStatusCard(stats),

                  const SizedBox(height: 30),

                  // Settings / Menu
                  _sectionHeader("Settings & Preferences"),
                  const SizedBox(height: 15),
                  _buildSettingsList(),

                  const SizedBox(height: 40),
                  
                  // Logout
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text("Log Out", style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade100),
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildHeaderBackground() {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryGreen,
            Colors.teal.shade700,
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(), 
              ),
              const Text(
                "Profile",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(_isEditing ? Icons.check : Icons.edit, color: Colors.white),
                onPressed: () {
                  if (_isEditing) _saveProfile();
                  else setState(() => _isEditing = true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(int level, double progress) {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                child: Text(
                  _profile?.fullName?.substring(0, 1).toUpperCase() ?? "U",
                  style: TextStyle(fontSize: 40, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (_isEditing) ...[
            TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: "Full Name", border: InputBorder.none),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 1),
            TextField(
              controller: _typeController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: "Garden Type (e.g. Indoor)", border: InputBorder.none),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ] else ...[
            Text(
              _profile?.fullName ?? "Gardener",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              "${_profile?.gardenType ?? 'Home'} Garden",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
          const SizedBox(height: 20),
          // Level Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Level $level", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
              Text("${(progress * 100).toInt()}% to Lvl ${level + 1}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade100,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(GardenStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _statTile("Total Plants", "${stats.totalPlants}", Icons.local_florist, Colors.green),
        _statTile("Streak", "${stats.streakDays} Days", Icons.local_fire_department, Colors.orange),
        _statTile("Productivity", "${stats.vegetables} Veggies", Icons.eco, Colors.teal),
        _statTile("Flowers", "${stats.flowering} Blooms", Icons.filter_vintage, Colors.pinkAccent),
      ],
    );
  }

  Widget _statTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildHealthStatusCard(GardenStats stats) {
    final isGood = stats.gardenStatus == "Good";
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGood 
             ? [Colors.green.shade400, Colors.green.shade600] 
             : [Colors.orange.shade400, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: (isGood ? Colors.green : Colors.orange).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
           Container(
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
             child: Icon(isGood ? Icons.thumb_up : Icons.health_and_safety, color: Colors.white, size: 28),
           ),
           const SizedBox(width: 16),
           Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(stats.gardenStatus, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
               const Text("Overall Garden Health", style: TextStyle(color: Colors.white70, fontSize: 12)),
             ],
           ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
           _settingTile(Icons.notifications_outlined, "Notifications", true),
           const Divider(height: 1),
           _settingTile(Icons.dark_mode_outlined, "Dark Mode", false),
           const Divider(height: 1),
           _settingTile(Icons.help_outline, "Help & Support", null),
           const Divider(height: 1),
           _settingTile(Icons.lock_outline, "Privacy Policy", null),
        ],
      ),
    );
  }

  Widget _settingTile(IconData icon, String title, bool? value) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: value == null 
          ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
          : Switch(value: value, onChanged: (val) {}, activeColor: AppTheme.primaryGreen),
      onTap: () {},
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87));
  }
}
