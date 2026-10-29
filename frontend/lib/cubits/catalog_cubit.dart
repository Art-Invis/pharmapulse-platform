import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/catalog_repository.dart';
import 'catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  final CatalogRepository repository;

  CatalogCubit({required this.repository}) : super(CatalogInitial());

  Future<void> loadCatalog() async {
    emit(CatalogLoading());
    try {
      // Паралельно завантажуємо ліки та список аптек
      final medicines = await repository.getMedicines();
      final branches = await repository.getBranches();
      
      emit(CatalogLoaded(medicines, branches));
    } catch (e) {
      emit(CatalogError('Помилка з\'єднання з сервером: $e'));
    }
  }
}