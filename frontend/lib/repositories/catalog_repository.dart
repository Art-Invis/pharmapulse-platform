import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medicine.dart';
import '../models/pharmacy_branch.dart';

class CatalogRepository {
  // Адреса нашого FastAPI сервера
  final String baseUrl = 'http://127.0.0.1:8000';

  Future<List<Medicine>> getMedicines() async {
    final response = await http.get(Uri.parse('$baseUrl/catalog/medicines'));

    if (response.statusCode == 200) {
      // utf8.decode запобігає появі "кракозябр" замість кирилиці
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Medicine.fromJson(json)).toList();
    } else {
      throw Exception('Не вдалося завантажити каталог ліків');
    }
  }

  Future<List<PharmacyBranch>> getBranches() async {
    final response = await http.get(Uri.parse('$baseUrl/catalog/branches'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => PharmacyBranch.fromJson(json)).toList();
    } else {
      throw Exception('Не вдалося завантажити список аптек');
    }
  }
}