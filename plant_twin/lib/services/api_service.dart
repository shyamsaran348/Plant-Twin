import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:path/path.dart' as path;
import '../models/user.dart';
import '../models/plant.dart';
import '../models/reminder.dart';

class ApiService {
  // Dynamic Base URL
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:8000";
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return "http://10.0.2.2:8000";
    }
    // iOS, macOS, Windows, Linux
    return "http://localhost:8000";
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  // --- Auth ---

  Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': email, 
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
      await _saveToken(authResponse.accessToken);
      return authResponse;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<User> register(String email, String password, String fullName, String gardenType) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email, 
        'password': password,
        'full_name': fullName,
        'garden_type': gardenType,
      }),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  // --- Profile ---

  Future<UserProfile> getUserProfile() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch profile');
    }
  }

  // --- Plants ---

  Future<List<Plant>> getPlants() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$baseUrl/plants/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Plant.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch plants');
    }
  }

  Future<Plant> getPlantDetails(int plantId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$baseUrl/plants/$plantId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Plant.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch plant details');
    }
  }

  Future<Plant> createPlant(String name, String species, XFile imageFile) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/plants/'));
    request.headers['Authorization'] = 'Bearer $token';
    
    request.fields['name'] = name;
    request.fields['species'] = species;
    
    // Web compatible upload
    final bytes = await imageFile.readAsBytes();
    
    var multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: imageFile.name,
    );
    
    request.files.add(multipartFile);

    var response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      return Plant.fromJson(jsonDecode(respStr));
    } else {
      final respStr = await response.stream.bytesToString();
      throw Exception('Failed to create plant: $respStr');
    }
  }

  // --- Extended Features ---

  Future<String> waterPlant(int plantId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl/plants/$plantId/water'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'] ?? "Plant watered successfully.";
    } else {
      throw Exception('Failed to water plant');
    }
  }

  Future<void> addPlantLog(int plantId, double height) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl/plants/$plantId/log'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'height': height}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add log');
    }
  }

  Future<void> updateEnvironment(int plantId, double temperature) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl/plants/$plantId/environment'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'temperature': temperature}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update environment');
    }
  }

  Future<Map<String, dynamic>> analyzeDisease(int plantId, XFile imageFile) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/disease/analyze/$plantId'));
    request.headers['Authorization'] = 'Bearer $token';

    // Web compatible upload
    final bytes = await imageFile.readAsBytes();
    var multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: imageFile.name,
    );
    request.files.add(multipartFile);

    var response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      return jsonDecode(respStr);
    } else {
      final respStr = await response.stream.bytesToString();
      throw Exception('Failed to analyze disease: $respStr');
    }
  }

  Future<Map<String, dynamic>> getAdvice(String species, double temp) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$baseUrl/advice/?species=$species&temperature=$temp'),
       headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get advice');
    }
  }

  // --- Reminders ---

  Future<List<Reminder>> getReminders() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$baseUrl/reminders/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Reminder.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch reminders');
    }
  }

  Future<Reminder> createReminder(int plantId, String type, String date, String freq) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl/reminders/$plantId'),
      headers: {
        'Authorization': 'Bearer $token', 
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'reminder_type': type,
        'next_due_date': date,
        'frequency': freq,
      }),
    );

    if (response.statusCode == 200) {
      return Reminder.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create reminder: ${response.body}');
    }
  }

  // --- Helper to get image URL ---
  String getImageUrl(String relativePath) {
    return "$baseUrl/$relativePath";
  }
}
