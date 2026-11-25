import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';
import '../models/pharmacy_branch.dart';
import '../models/order.dart';

class OrderRepository {
  final String baseUrl = 'http://127.0.0.1:8000';

  Future<void> createOrder({
    required int userId, // Для тестів беремо хардкод юзера
    required String deliveryType, // 'Pickup' або 'Delivery'
    PharmacyBranch? branch,
    required List<CartItem> items,
  }) async {
    final url = Uri.parse('$baseUrl/orders/');
    
    // Формуємо JSON згідно з нашою Pydantic-схемою OrderCreate
    final Map<String, dynamic> requestBody = {
      'user_id': userId,
      'delivery_type': deliveryType,
      'branch_id': branch?.id,
      'items': items.map((item) => {
        'medicine_id': item.medicine.id,
        'quantity': item.quantity,
      }).toList(),
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception('Помилка оформлення замовлення: ${response.body}');
    }
  }

  Future<List<Order>> getOrders() async {
    final response = await http.get(Uri.parse('$baseUrl/orders/'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Не вдалося завантажити замовлення');
    }
  }

  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    final url = Uri.parse('$baseUrl/orders/$orderId/status?new_status=$newStatus');
    final response = await http.patch(url);
    
    if (response.statusCode != 200) {
      throw Exception('Помилка оновлення статусу');
    }
  }
}