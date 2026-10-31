import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../cubits/cabinet_cubit.dart';
import '../cubits/cart_cubit.dart';
import '../cubits/catalog_cubit.dart';
import '../cubits/catalog_state.dart';
import '../models/order.dart';
import '../models/user_profile.dart';
import '../models/medicine.dart';
import 'cart_screen.dart';

class CabinetScreen extends StatelessWidget {
  const CabinetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Особистий кабінет'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<CabinetCubit, CabinetState>(
        builder: (context, state) {
          if (state is CabinetLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CabinetError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          } else if (state is CabinetLoaded) {
            final profile = state.profile;

            return DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.person), text: 'Профіль'),
                      Tab(icon: Icon(Icons.history), text: 'Історія'),
                      Tab(icon: Icon(Icons.receipt_long), text: 'Рецепти'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildProfileTab(context, profile),
                        _buildOrdersTab(context, profile.orders),
                        _buildPrescriptionsTab(profile.prescriptions),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context, UserProfile profile) {
    // Демонстраційний розрахунок бонусів (для візуалізації пункту ТЗ про бонусну картку)
    final int bonusBalance = profile.loyaltyTier == 'Premium' ? 450 : (profile.loyaltyTier == 'Social' ? 120 : 50);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
        const SizedBox(height: 16),
        Text(profile.fullName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(profile.email, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        
        // ВІЗУАЛІЗАЦІЯ БОНУСНОЇ КАРТКИ (ТЗ Пункт 4)
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Бонусна картка', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text('$bonusBalance балів', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                  ],
                ),
                const Icon(Icons.wallet_giftcard, size: 48, color: Colors.teal),
              ],
            ),
          ),
        ),
        
        const Divider(height: 48),
        ListTile(
          leading: const Icon(Icons.star, color: Colors.orange),
          title: const Text('Рівень лояльності'),
          trailing: Chip(
            label: Text(profile.loyaltyTier, style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.orange.shade100,
          ),
          subtitle: const Text('Знижки автоматично застосовуються в кошику.'),
        ),
        ListTile(
          leading: const Icon(Icons.notifications_active, color: Colors.teal),
          title: const Text('Сповіщення про наявність'),
          trailing: Switch(value: true, onChanged: (val) {}),
          subtitle: const Text('Отримувати SMS при появі ліків та акціях.'),
        ),
      ],
    );
  }

  Widget _buildOrdersTab(BuildContext context, List<Order> orders) {
    if (orders.isEmpty) return const Center(child: Text('Ви ще не робили замовлень.'));
    
    final catalogState = context.read<CatalogCubit>().state;
    List<Medicine> allMedicines = [];
    if (catalogState is CatalogLoaded) {
      allMedicines = catalogState.allMedicines;
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final date = DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(order.createdAt).toLocal());
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text('Замовлення #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Дата: $date\nСтатус: ${order.status}'),
            trailing: Text(
              '${order.finalPrice.toStringAsFixed(2)} ₴', 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
            children: [
              const Divider(),
              // Виводимо список товарів у цьому замовленні
              ...order.items.map((item) {
                final med = allMedicines.where((m) => m.id == item.medicineId).firstOrNull;
                final medName = med?.name ?? 'Невідомий препарат';
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.medication, size: 24, color: Colors.teal),
                  title: Text(medName),
                  trailing: Text('${item.quantity} шт. x ${item.pricePerUnit} ₴'),
                );
              }),
              // Кнопка повторення замовлення
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FilledButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Повторити замовлення'),
                  onPressed: () {
                    final cartCubit = context.read<CartCubit>();
                    cartCubit.clearCart();
                    
                    bool hasMissingItems = false;
                    
                    for (var item in order.items) {
                      final med = allMedicines.where((m) => m.id == item.medicineId).firstOrNull;
                      if (med != null && med.stock >= item.quantity) {
                        for (int i = 0; i < item.quantity; i++) {
                          cartCubit.addMedicine(med);
                        }
                      } else {
                        hasMissingItems = true;
                      }
                    }
                    
                    if (hasMissingItems) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Деяких товарів зараз немає в достатній кількості на складі.'), 
                          backgroundColor: Colors.orange
                        )
                      );
                    }
                    
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrescriptionsTab(List<Prescription> prescriptions) {
    if (prescriptions.isEmpty) return const Center(child: Text('У вас немає збережених рецептів.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: prescriptions.length,
      itemBuilder: (context, index) {
        final p = prescriptions[index];
        final date = DateFormat('dd.MM.yyyy').format(DateTime.parse(p.expiryDate).toLocal());
        return Card(
          child: ListTile(
            leading: Icon(Icons.medical_information, color: p.isVerified ? Colors.green : Colors.red),
            title: Text('Рецепт: ${p.code}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Лікар: ${p.doctorFullName}\nДійсний до: $date'),
            trailing: p.isVerified 
                ? const Icon(Icons.check_circle, color: Colors.green) 
                : const Icon(Icons.pending, color: Colors.orange),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}