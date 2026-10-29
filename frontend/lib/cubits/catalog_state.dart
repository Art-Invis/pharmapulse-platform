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
  final List<Medicine> medicines;
  final List<PharmacyBranch> branches;

  const CatalogLoaded(this.medicines, this.branches);

  @override
  List<Object> get props => [medicines, branches];
}

class CatalogError extends CatalogState {
  final String message;

  const CatalogError(this.message);

  @override
  List<Object> get props => [message];
}