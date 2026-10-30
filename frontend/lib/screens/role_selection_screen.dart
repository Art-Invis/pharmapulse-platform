import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'catalog_screen.dart';
import 'admin_screen.dart';
import '../cubits/admin_cubit.dart';
import '../repositories/order_repository.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_pharmacy, size: 100, color: Colors.teal),
              const SizedBox(height: 24),
              Text(
                'Вітаємо у PharmaPulse!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Оберіть свою роль для входу в систему:',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Використовуємо Wrap, щоб картки гарно переносилися на вузьких екранах
              Wrap(
                spacing: 32,
                runSpacing: 32,
                alignment: WrapAlignment.center,
                children: [
                  _buildRoleCard(
                    context,
                    title: 'Я Клієнт',
                    icon: Icons.person,
                    color: Colors.teal,
                    onTap: () {
                      // Переходимо на вітрину для клієнтів (без можливості повернутися назад кнопкою Back)
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const CatalogScreen()),
                      );
                    },
                  ),
                  _buildRoleCard(
                    context,
                    title: 'Я Фармацевт',
                    icon: Icons.admin_panel_settings,
                    color: Colors.blueGrey,
                    onTap: () {
                      // Переходимо в адмінку, одразу ініціалізуючи Cubit
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => AdminCubit(OrderRepository())..loadOrders(),
                            child: const AdminScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, {
    required String title, 
    required IconData icon, 
    required Color color, 
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      hoverColor: color.withOpacity(0.05),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 220,
          height: 220,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 72, color: color),
              const SizedBox(height: 24),
              Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}