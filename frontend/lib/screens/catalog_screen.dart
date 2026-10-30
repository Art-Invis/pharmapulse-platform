import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Імпорти для каталогу та кошика
import '../cubits/catalog_cubit.dart';
import '../cubits/catalog_state.dart';
import '../cubits/cart_cubit.dart';
import '../cubits/cart_state.dart';

// Імпорти для авторизації та кабінету
import '../cubits/auth_cubit.dart';
import '../cubits/cabinet_cubit.dart';
import '../repositories/user_repository.dart';
import 'role_selection_screen.dart';
// Імпорти екранів
import 'cart_screen.dart';
import 'cabinet_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          tooltip: 'Змінити роль',
          onPressed: () {
            context.read<AuthCubit>().logout(); // Очищаємо вибраного юзера
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
            );
          },
        ),
        title: const Text('PharmaPulse Каталог', style: TextStyle(fontWeight: FontWeight.bold)),
        
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 1. Кнопка Особистого кабінету
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Особистий кабінет',
            onPressed: () {
              // Беремо динамічний ID користувача з глобального стану
              final userId = context.read<AuthCubit>().state.userId!;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) =>
                        CabinetCubit(UserRepository())..loadProfile(userId),
                    child: const CabinetScreen(),
                  ),
                ),
              );
            },
          ),

          // 2. Іконка кошика з лічильником
          BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              return Badge(
                isLabelVisible: cartState.totalItems > 0,
                label: Text('${cartState.totalItems}'),
                offset: const Offset(-8, 8),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  tooltip: 'Кошик',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocBuilder<CatalogCubit, CatalogState>(
        builder: (context, state) {
          if (state is CatalogLoading || state is CatalogInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CatalogError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else if (state is CatalogLoaded) {
            final medicines = state.medicines;

            return GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 0.75,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final med = medicines[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // У майбутньому тут можна додати перехід на деталі товару
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Center(
                              child: Icon(
                                Icons.medication,
                                size: 72,
                                color: med.isPrescriptionRequired
                                    ? Colors.red.shade300
                                    : Colors.teal.shade400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            med.name,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            med.manufacturer,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          if (med.isPrescriptionRequired)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'За рецептом',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 24),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${med.price.toStringAsFixed(2)} ₴',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              FilledButton(
                                onPressed: () {
                                  context.read<CartCubit>().addMedicine(med);
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${med.name} додано до кошика!',
                                      ),
                                      duration: const Duration(seconds: 2),
                                      action: SnackBarAction(
                                        label: 'Кошик',
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const CartScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Купити'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
