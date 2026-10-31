import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_state.dart';
import '../models/medicine.dart';
import '../models/cart_item.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  void addMedicine(Medicine medicine) {
    final currentItems = List<CartItem>.from(state.items);
    final existingIndex = currentItems.indexWhere((item) => item.medicine.id == medicine.id);

    if (existingIndex >= 0) {
      // СТВОРЮЄМО НОВИЙ ЕКЗЕМПЛЯР ДЛЯ ОНОВЛЕННЯ СТАНУ
      final oldItem = currentItems[existingIndex];
      currentItems[existingIndex] = CartItem(medicine: medicine, quantity: oldItem.quantity + 1);
    } else {
      currentItems.add(CartItem(medicine: medicine));
    }

    emit(state.copyWith(items: currentItems));
  }

  void updateQuantity(int medicineId, int delta) {
    final currentItems = List<CartItem>.from(state.items);
    final index = currentItems.indexWhere((item) => item.medicine.id == medicineId);

    if (index >= 0) {
      final oldItem = currentItems[index];
      final newQuantity = oldItem.quantity + delta;
      if (newQuantity > 0) {
        // СТВОРЮЄМО НОВИЙ ЕКЗЕМПЛЯР ДЛЯ ОНОВЛЕННЯ СТАНУ
        currentItems[index] = CartItem(medicine: oldItem.medicine, quantity: newQuantity);
        emit(state.copyWith(items: currentItems));
      } else {
        removeMedicine(medicineId);
      }
    }
  }

  void removeMedicine(int medicineId) {
    final currentItems = List<CartItem>.from(state.items);
    currentItems.removeWhere((item) => item.medicine.id == medicineId);
    emit(state.copyWith(items: currentItems));
  }

  void clearCart() {
    emit(const CartState(items: []));
  }
}