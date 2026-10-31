import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/user_profile.dart';

class UserRepository {
  final String baseUrl = 'http://127.0.0.1:8000';

  Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Не вдалося завантажити список користувачів');
    }
  }

  Future<UserProfile> getProfile(int userId) async {
    // Тепер ендпоінт приймає user_id динамічно!
    final response = await http.get(Uri.parse('$baseUrl/users/profile?user_id=$userId'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return UserProfile.fromJson(data);
    } else {
      throw Exception('Не вдалося завантажити профіль');
    }
  }
}