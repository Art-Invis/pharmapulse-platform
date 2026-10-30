import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'role_selection_screen.dart';
// Використовуємо абсолютні імпорти, щоб уникнути конфліктів у Dart розширенні
import 'package:frontend/cubits/admin_cubit.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ДОДАЄМО КНОПКУ ВИХОДУ ЗЛІВА
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          tooltip: 'Змінити роль',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
            );
          },
        ),
        title: const Text('Панель Фармацевта (Адмінка)'),
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AdminError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          } else if (state is AdminLoaded) {
            final orders = state.orders;
            
            if (orders.isEmpty) {
              return const Center(child: Text('Замовлень поки немає.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final date = DateTime.parse(order.createdAt).toLocal();
                final formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(date);
                
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Замовлення #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 4),
                            Text('Клієнт ID: ${order.userId} | Тип: ${order.deliveryType}'),
                            Text('Дата: $formattedDate'),
                            const SizedBox(height: 8),
                            Text('Сума: ${order.finalPrice.toStringAsFixed(2)} ₴', 
                                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        DropdownButton<String>(
                          value: order.status,
                          items: const [
                            DropdownMenuItem(value: 'Pending', child: Text('Очікує (Pending)')),
                            DropdownMenuItem(value: 'Processing', child: Text('Комплектується (Processing)')),
                            DropdownMenuItem(value: 'Ready', child: Text('Готово (Ready)')),
                            DropdownMenuItem(value: 'Completed', child: Text('Видано (Completed)')),
                            DropdownMenuItem(value: 'Cancelled', child: Text('Скасовано (Cancelled)')),
                          ],
                          onChanged: (newStatus) {
                            if (newStatus != null && newStatus != order.status) {
                              context.read<AdminCubit>().changeOrderStatus(order.id, newStatus);
                            }
                          },
                        ),
                      ],
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
