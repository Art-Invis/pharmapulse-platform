import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubits/cabinet_cubit.dart';
import '../models/order.dart';
import '../models/user_profile.dart';

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
                        _buildOrdersTab(profile.orders),
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
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
        const SizedBox(height: 16),
        Text(profile.fullName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(profile.email, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
        const Divider(height: 48),
        ListTile(
          leading: const Icon(Icons.star, color: Colors.orange),
          title: const Text('Рівень лояльності'),
          trailing: Chip(
            label: Text(profile.loyaltyTier, style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.orange.shade100,
          ),
          subtitle: const Text('Знижки автоматично застосовуються в кошику завдяки патерну Strategy.'),
        ),
        ListTile(
          leading: const Icon(Icons.notifications_active, color: Colors.teal),
          title: const Text('Сповіщення про наявність'),
          trailing: Switch(value: true, onChanged: (val) {}),
          subtitle: const Text('Отримувати SMS при появі ліків у найближчій аптеці.'),
        ),
      ],
    );
  }

  Widget _buildOrdersTab(List<Order> orders) {
    if (orders.isEmpty) return const Center(child: Text('Ви ще не робили замовлень.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final date = DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(order.createdAt).toLocal());
        return Card(
          child: ListTile(
            title: Text('Замовлення #${order.id}'),
            subtitle: Text('Дата: $date\nСтатус: ${order.status}'),
            trailing: Text('${order.finalPrice.toStringAsFixed(2)} ₴', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            isThreeLine: true,
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
}