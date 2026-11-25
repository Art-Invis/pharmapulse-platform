import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/order.dart';
import '../repositories/order_repository.dart';

// --- СТАНИ ---
abstract class AdminState extends Equatable {
  @override
  List<Object> get props => [];
}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final List<Order> orders;
  AdminLoaded(this.orders);
  
  @override
  List<Object> get props => [orders];
}

class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
  
  @override
  List<Object> get props => [message];
}

// --- CUBIT ---
class AdminCubit extends Cubit<AdminState> {
  final OrderRepository repository;

  AdminCubit(this.repository) : super(AdminLoading());

  Future<void> loadOrders() async {
    emit(AdminLoading());
    try {
      final orders = await repository.getOrders();
      emit(AdminLoaded(orders));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> changeOrderStatus(int orderId, String newStatus) async {
    try {
      await repository.updateOrderStatus(orderId, newStatus);
      // Після успішного оновлення просто перезавантажуємо список
      await loadOrders();
    } catch (e) {
      emit(AdminError('Помилка зміни статусу: $e'));
    }
  }
}