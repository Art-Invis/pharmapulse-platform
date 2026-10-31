import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/catalog_repository.dart';
import 'catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  final CatalogRepository repository;

  CatalogCubit({required this.repository}) : super(CatalogInitial());

  // --- МЕТОД 1: ЗАВАНТАЖЕННЯ КАТАЛОГУ ---
  Future<void> loadCatalog() async {
    emit(CatalogLoading());
    try {
      // Паралельно завантажуємо ліки та список аптек
      final medicines = await repository.getMedicines();
      final branches = await repository.getBranches();

      emit(CatalogLoaded(medicines, medicines, branches));
    } catch (e) {
      emit(CatalogError('Помилка з\'єднання з сервером: $e'));
    }
  } // <-- Тут метод loadCatalog успішно закінчується!

  // --- МЕТОД 2: ФІЛЬТРАЦІЯ (ТЕПЕР ВІН НА СВОЄМУ МІСЦІ) ---
  void applyFilters({
    String query = '',
    bool onlyInStock = false,
    bool noPrescription = false,
  }) {
    if (state is CatalogLoaded) {
      final currentState = state as CatalogLoaded;

      final filtered = currentState.allMedicines.where((med) {
        final matchesQuery = med.name.toLowerCase().contains(
          query.toLowerCase(),
        );
        final matchesStock = onlyInStock ? med.stock > 0 : true;
        final matchesPrescription = noPrescription
            ? !med.isPrescriptionRequired
            : true;

        return matchesQuery && matchesStock && matchesPrescription;
      }).toList();

      emit(
        CatalogLoaded(
          currentState.allMedicines,
          filtered,
          currentState.branches,
        ),
      );
    }
  }
}
