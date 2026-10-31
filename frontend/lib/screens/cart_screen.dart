import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/cart_cubit.dart';
import '../cubits/cart_state.dart';
import '../cubits/catalog_cubit.dart';
import '../cubits/catalog_state.dart';
import '../cubits/auth_cubit.dart';
import '../models/pharmacy_branch.dart';
import '../repositories/order_repository.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _deliveryType = 'Pickup';
  PharmacyBranch? _selectedBranch;
  bool _isLoading = false;

  void _submitOrder(BuildContext context, CartState cartState) async {
    if (cartState.items.isEmpty) return;

    // Безпечно перевіряємо, чи є ID користувача
    final authState = context.read<AuthCubit>().state;
    if (authState.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Помилка: Користувач не авторизований! Будь ласка, перезайдіть в систему.'),
          backgroundColor: Colors.red,
        )
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final repository = OrderRepository();
      
      await repository.createOrder(
        userId: authState.userId!,
        deliveryType: _deliveryType,
        branch: _selectedBranch,
        items: cartState.items,
      );
      
      if (!mounted) return;
      
      // Очищаємо кошик після успішного замовлення
      context.read<CartCubit>().clearCart();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Замовлення успішно оформлено!'),
          backgroundColor: Colors.green,
        )
      );
      Navigator.pop(context); // Повертаємось в каталог
    } catch (e) {
      // Очищаємо всі попередні сповіщення, щоб нове з'явилося миттєво
      ScaffoldMessenger.of(context).clearSnackBars(); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // e.toString() додає слово "Exception:", ми його прибираємо для краси
          content: Text(e.toString().replaceAll('Exception: ', '')), 
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Кошик'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, cartState) {
          if (cartState.items.isEmpty) {
            return const Center(
              child: Text('Ваш кошик порожній', style: TextStyle(fontSize: 18)),
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ліва частина: Список товарів з елементами керування
              Expanded(
                flex: 2,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartState.items.length,
                  itemBuilder: (context, index) {
                    final item = cartState.items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.medication, size: 40, color: Colors.teal),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.medicine.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('${item.medicine.price} ₴ / шт.', style: TextStyle(color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                            // Блок керування кількістю (+ та -)
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 20),
                                    onPressed: () => context.read<CartCubit>().updateQuantity(item.medicine.id, -1),
                                  ),
                                  Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 20),
                                    onPressed: () => context.read<CartCubit>().updateQuantity(item.medicine.id, 1),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Загальна ціна за позицію
                            SizedBox(
                              width: 80,
                              child: Text(
                                '${(item.medicine.price * item.quantity).toStringAsFixed(2)} ₴',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Кнопка видалення товару
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => context.read<CartCubit>().removeMedicine(item.medicine.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Права частина: Checkout форма (Оформлення)
              Expanded(
                flex: 1,
                child: Card(
                  margin: const EdgeInsets.all(16),
                  color: Colors.grey.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Оформлення', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const Divider(height: 32),
                        
                        // Вибір типу доставки
                        DropdownButtonFormField<String>(
                          value: _deliveryType,
                          decoration: const InputDecoration(labelText: 'Спосіб отримання', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'Pickup', child: Text('Самовивіз з аптеки')),
                            DropdownMenuItem(value: 'Delivery', child: Text('Кур\'єрська доставка')),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _deliveryType = val!;
                              if (val == 'Delivery') _selectedBranch = null;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Вибір аптеки (тільки для самовивозу)
                        if (_deliveryType == 'Pickup')
                          BlocBuilder<CatalogCubit, CatalogState>(
                            builder: (context, catalogState) {
                              if (catalogState is CatalogLoaded) {
                                final branches = catalogState.branches;
                                if (_selectedBranch == null && branches.isNotEmpty) {
                                  _selectedBranch = branches.first;
                                }
                                return DropdownButtonFormField<PharmacyBranch>(
                                  value: _selectedBranch,
                                  isExpanded: true,
                                  decoration: const InputDecoration(labelText: 'Оберіть аптеку', border: OutlineInputBorder()),
                                  items: branches.map((b) => DropdownMenuItem(
                                    value: b,
                                    child: Text(b.address, overflow: TextOverflow.ellipsis),
                                  )).toList(),
                                  onChanged: (val) => setState(() => _selectedBranch = val),
                                );
                              }
                              return const CircularProgressIndicator();
                            }
                          ),
                          
                        const Spacer(),
                        const Divider(height: 32),

                        // Повідомлення про знижку лояльності
                        const Spacer(),
                        const Divider(height: 32),
                        
                        // РОЗРАХУНОК БОНУСНОЇ КАРТКИ (ЛОЯЛЬНОСТІ)
                        Builder(
                          builder: (context) {
                            // Отримуємо статус лояльності поточного клієнта
                            final loyaltyTier = context.read<AuthCubit>().state.loyaltyTier ?? 'Standard';
                            double discountPercent = 0.0;
                            
                            if (loyaltyTier == 'Premium') discountPercent = 0.15; // 15% знижки
                            if (loyaltyTier == 'Social') discountPercent = 0.10; // 10% знижки
                            
                            final rawTotal = cartState.totalPrice;
                            final discountAmount = rawTotal * discountPercent;
                            final finalPrice = rawTotal - discountAmount;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Сума товарів:'),
                                    Text('${rawTotal.toStringAsFixed(2)} ₴'),
                                  ],
                                ),
                                if (discountPercent > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Бонусна картка ($loyaltyTier):', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                                        Text('- ${discountAmount.toStringAsFixed(2)} ₴', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Разом до сплати:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text(
                                      '${finalPrice.toStringAsFixed(2)} ₴', 
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        ),
                        const SizedBox(height: 24),
                        
                        // Кнопка відправки
                        FilledButton(
                          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
                          onPressed: _isLoading ? null : () => _submitOrder(context, cartState),
                          child: _isLoading 
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                              : const Text('Підтвердити замовлення', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}