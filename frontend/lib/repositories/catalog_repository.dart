import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medicine.dart';
import '../models/pharmacy_branch.dart';

class CatalogRepository {
  final String baseUrl = 'http://127.0.0.1:8000';

  Future<List<Medicine>> getMedicines() async {
    final response = await http.get(Uri.parse('$baseUrl/catalog/medicines'));

    if (response.statusCode == 200) {
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

  Future<void> createMedicine({
    required String name,
    required String activeSubstance,
    required String manufacturer,
    required double price,
    required int stock,
    required bool isPrescriptionRequired,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/catalog/medicines'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'name': name,
        'active_substance': activeSubstance,
        'manufacturer': manufacturer,
        'price': price,
        'stock': stock,
        'is_prescription_required': isPrescriptionRequired,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Не вдалося додати препарат');
    }
  }
}
