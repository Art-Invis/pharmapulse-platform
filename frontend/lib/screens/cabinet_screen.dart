import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../cubits/cabinet_cubit.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/cart_cubit.dart';
import '../cubits/catalog_cubit.dart';
import '../cubits/catalog_state.dart';
import '../repositories/order_repository.dart';
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
              length: 4, 
              child: Column(
                children: [
                  const TabBar(
                    isScrollable: true,
                    tabs: [
                      Tab(icon: Icon(Icons.person), text: 'Профіль'),
                      Tab(icon: Icon(Icons.history), text: 'Історія'),
                      Tab(icon: Icon(Icons.receipt_long), text: 'Рецепти'),
                      Tab(icon: Icon(Icons.notifications), text: 'Сповіщення'), 
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildProfileTab(context, profile),
                        _buildOrdersTab(context, profile.orders),
                        _buildPrescriptionsTab(profile.prescriptions),
                        _buildNotificationsTab(),
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
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade800, Colors.teal.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PHARMAPULSE BONUS', style: TextStyle(color: Colors.white70, letterSpacing: 2)),
                  Icon(Icons.contactless, color: Colors.white70),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Ваш кешбек-баланс:', style: TextStyle(color: Colors.white, fontSize: 16)),
              Text(
                '${profile.bonusBalance.toStringAsFixed(2)} ₴', 
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(profile.fullName.toUpperCase(), style: const TextStyle(color: Colors.white, letterSpacing: 1)),
                  Text(profile.loyaltyTier.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        ListTile(
          leading: const Icon(Icons.info_outline, color: Colors.teal),
          title: const Text('Як працює картка?'),
          subtitle: const Text('За кожне успішно виконане замовлення ви автоматично отримуєте 5% кешбеку на цей рахунок.'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.notifications_active, color: Colors.teal),
          title: const Text('Сповіщення про наявність'),
          trailing: Switch(value: true, onChanged: (val) {}),
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
          child: ExpansionTile(
            title: Text('Замовлення #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Дата: $date\nСтатус: ${order.status}'),
            trailing: Text(
              '${order.finalPrice.toStringAsFixed(2)} ₴', 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                color: order.status == 'Cancelled' ? Colors.grey : Colors.black
              )
            ),
            children: [
              const Divider(),
              ...order.items.map((item) {
                final med = allMedicines.where((m) => m.id == item.medicineId).firstOrNull;
                final medName = med?.name ?? 'Невідомий препарат';
                return ListTile(
                  dense: true,
                  title: Text(medName),
                  trailing: Text('${item.quantity} шт. x ${item.pricePerUnit} ₴'),
                );
              }),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (order.status == 'Pending') ...[
                      TextButton.icon(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text('Скасувати', style: TextStyle(color: Colors.red)),
                        onPressed: () async {
                          try {
                            await OrderRepository().updateOrderStatus(order.id, 'Cancelled');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Замовлення скасовано'), backgroundColor: Colors.orange)
                            );
                            final userId = context.read<AuthCubit>().state.userId!;
                            context.read<CabinetCubit>().loadProfile(userId);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Помилка: $e'), backgroundColor: Colors.red)
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                    ],
                    FilledButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Повторити'),
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
                            const SnackBar(content: Text('Деяких товарів зараз немає в достатній кількості.'), backgroundColor: Colors.orange)
                          );
                        }
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                      },
                    ),
                  ],
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
            title: Text('Рецепт: ${p.code}'),
            subtitle: Text('Лікар: ${p.doctorFullName}\nДійсний до: $date'),
            trailing: p.isVerified ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.pending, color: Colors.orange),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildNotificationsTab() {
    // Фіктивний список сповіщень для демонстрації функціоналу
    final notifications = [
      {
        'title': 'Сезонна акція!',
        'body': 'Знижка 20% на всі вітаміни до кінця тижня. Підготуйтеся до сезону!',
        'icon': Icons.percent,
        'color': Colors.orange,
      },
      {
        'title': 'Препарат знову в наявності',
        'body': 'Ліки "Німесил", які ви шукали, щойно надійшли в найближчу аптеку.',
        'icon': Icons.medical_information,
        'color': Colors.teal,
      },
      {
        'title': 'Нагадування',
        'body': 'У вас закінчується "Корвалмент". Бажаєте повторити замовлення?',
        'icon': Icons.alarm,
        'color': Colors.blue,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final note = notifications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: (note['color'] as Color).withOpacity(0.2),
              child: Icon(note['icon'] as IconData, color: note['color'] as Color),
            ),
            title: Text(note['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(note['body'] as String),
          ),
        );
      },
    );
  }
}