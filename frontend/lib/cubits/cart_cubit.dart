import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_state.dart';
import '../models/medicine.dart';
import '../models/cart_item.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  void addMedicine(Medicine medicine) {
    // Створюємо копію поточного списку
    final currentItems = List<CartItem>.from(state.items);
    
    // Шукаємо, чи є вже такий препарат у кошику
    final existingIndex = currentItems.indexWhere((item) => item.medicine.id == medicine.id);

    if (existingIndex >= 0) {
      currentItems[existingIndex].quantity += 1;
    } else {
      currentItems.add(CartItem(medicine: medicine));
    }

    // Оновлюємо стан новими даними
    emit(state.copyWith(items: currentItems));
  }

  void clearCart() {
    emit(const CartState(items: []));
  }
}