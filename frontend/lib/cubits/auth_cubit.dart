import 'package:flutter_bloc/flutter_bloc.dart';

class AuthState {
  final int? userId;
  final String? userName;
  final String? loyaltyTier;

  AuthState({this.userId, this.userName, this.loyaltyTier});
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState());

  void login(int id, String name, String tier) {
    emit(AuthState(userId: id, userName: name, loyaltyTier: tier));
  }
  
  void logout() {
    emit(AuthState());
  }
}