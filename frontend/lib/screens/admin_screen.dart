import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../cubits/admin_cubit.dart';
import '../cubits/catalog_cubit.dart';
import '../cubits/catalog_state.dart';
import '../models/order.dart';
import '../models/medicine.dart';
import '../repositories/catalog_repository.dart';
import 'role_selection_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  void _showOrderDetails(BuildContext context, Order order) {
    final catalogState = context.read<CatalogCubit>().state;
    List<Medicine> allMedicines = [];
    if (catalogState is CatalogLoaded) {
      allMedicines = catalogState.allMedicines;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Склад замовлення #${order.id}'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final item = order.items[index];
                final med = allMedicines
                    .where((m) => m.id == item.medicineId)
                    .firstOrNull;
                final medName =
                    med?.name ?? 'Невідомий препарат (ID: ${item.medicineId})';

                return ListTile(
                  leading: const Icon(Icons.medication, color: Colors.teal),
                  title: Text(
                    medName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${item.pricePerUnit} ₴ x ${item.quantity} шт.'),
                  trailing: Text(
                    '${(item.pricePerUnit * item.quantity).toStringAsFixed(2)} ₴',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрити'),
            ),
          ],
        );
      },
    );
  }

  void _showAddMedicineDialog(BuildContext context) {
    final nameController = TextEditingController();
    final substanceController = TextEditingController();
    final manufacturerController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController(text: '20');
    bool isPrescription = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stateContext, setState) {
            return AlertDialog(
              title: const Text('Новий медикамент'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Назва препарату',
                      ),
                    ),
                    TextField(
                      controller: substanceController,
                      decoration: const InputDecoration(
                        labelText: 'Діюча речовина',
                      ),
                    ),
                    TextField(
                      controller: manufacturerController,
                      decoration: const InputDecoration(
                        labelText: 'Виробник',
                      ),
                    ),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Ціна (₴)',
                      ),
                    ),
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Кількість на складі',
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('За рецептом'),
                      value: isPrescription,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => isPrescription = val),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Скасувати'),
                ),
                FilledButton(
                  onPressed: () async {
                    final price = double.tryParse(priceController.text) ?? 0.0;
                    final stock = int.tryParse(stockController.text) ?? 0;

                    if (nameController.text.trim().isEmpty || price <= 0) {
                      return;
                    }

                    try {
                      await CatalogRepository().createMedicine(
                        name: nameController.text.trim(),
                        activeSubstance: substanceController.text.trim(),
                        manufacturer: manufacturerController.text.trim(),
                        price: price,
                        stock: stock,
                        isPrescriptionRequired: isPrescription,
                      );

                      if (context.mounted) {
                        context.read<CatalogCubit>().loadCatalog();
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Препарат успішно додано до каталогу!'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Помилка: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Зберегти'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          tooltip: 'Змінити роль',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const RoleSelectionScreen(),
              ),
            );
          },
        ),
        title: const Text('Панель Фармацевта'),
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMedicineDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Додати препарат'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AdminError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state is AdminLoaded) {
            final orders = state.orders;

            if (orders.isEmpty) {
              return const Center(child: Text('Замовлень поки немає.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final date = DateTime.parse(order.createdAt).toLocal();
                final formattedDate =
                    DateFormat('dd.MM.yyyy HH:mm').format(date);

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _showOrderDetails(context, order),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Замовлення #${order.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Клієнт ID: ${order.userId} | Тип: ${order.deliveryType}',
                              ),
                              Text('Дата: $formattedDate'),
                              const SizedBox(height: 8),
                              Text(
                                'Сума: ${order.finalPrice.toStringAsFixed(2)} ₴',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          DropdownButton<String>(
                            value: order.status,
                            items: const [
                              DropdownMenuItem(
                                value: 'Pending',
                                child: Text('Очікує'),
                              ),
                              DropdownMenuItem(
                                value: 'Processing',
                                child: Text('Комплектується'),
                              ),
                              DropdownMenuItem(
                                value: 'Ready',
                                child: Text('Готово'),
                              ),
                              DropdownMenuItem(
                                value: 'Completed',
                                child: Text('Видано'),
                              ),
                              DropdownMenuItem(
                                value: 'Cancelled',
                                child: Text('Скасовано'),
                              ),
                            ],
                            onChanged: (newStatus) {
                              if (newStatus != null &&
                                  newStatus != order.status) {
                                context
                                    .read<AdminCubit>()
                                    .changeOrderStatus(order.id, newStatus);
                              }
                            },
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
