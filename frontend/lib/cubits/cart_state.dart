import 'package:equatable/equatable.dart';
import '../models/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;

  const CartState({this.items = const []});

  double get totalPrice => items.fold(
      0, (total, item) => total + (item.medicine.price * item.quantity));
      
  int get totalItems => items.fold(
      0, (total, item) => total + item.quantity);

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }

  @override
  List<Object> get props => [items]; // Equatable відслідковує зміни списку
}