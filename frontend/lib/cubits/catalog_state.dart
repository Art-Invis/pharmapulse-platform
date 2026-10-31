import 'package:equatable/equatable.dart';
import '../models/medicine.dart';
import '../models/pharmacy_branch.dart';

abstract class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object> get props => [];
}

class CatalogInitial extends CatalogState {}

class CatalogLoading extends CatalogState {}

class CatalogLoaded extends CatalogState {
  final List<Medicine> allMedicines;      // Всі ліки з бази
  final List<Medicine> filteredMedicines; // Ліки після застосування фільтрів
  final List<PharmacyBranch> branches;

  const CatalogLoaded(this.allMedicines, this.filteredMedicines, this.branches);

  @override
  List<Object> get props => [allMedicines, filteredMedicines, branches];
}
class CatalogError extends CatalogState {
  final String message;

  const CatalogError(this.message);

  @override
  List<Object> get props => [message];
}