import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user_profile.dart';
import '../repositories/user_repository.dart';

// --- Стани ---
abstract class CabinetState extends Equatable {
  @override
  List<Object> get props => [];
}

class CabinetLoading extends CabinetState {}

class CabinetLoaded extends CabinetState {
  final UserProfile profile;
  CabinetLoaded(this.profile);

  @override
  List<Object> get props => [profile];
}

class CabinetError extends CabinetState {
  final String message;
  CabinetError(this.message);

  @override
  List<Object> get props => [message];
}

// --- Логіка ---
class CabinetCubit extends Cubit<CabinetState> {
  final UserRepository repository;

  CabinetCubit(this.repository) : super(CabinetLoading());

  Future<void> loadProfile(int userId) async {
    emit(CabinetLoading());
    try {
      final profile = await repository.getProfile(userId); // Передаємо ID
      emit(CabinetLoaded(profile));
    } catch (e) {
      emit(CabinetError(e.toString()));
    }
  }
}