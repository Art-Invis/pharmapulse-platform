import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/cart_cubit.dart';
import '../cubits/cart_state.dart';
import '../cubits/catalog_cubit.dart';
import '../cubits/catalog_state.dart';
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
    
    setState(() => _isLoading = true);
    
    try {
      final repository = OrderRepository();
      // Для тестів використовуємо користувача id=2 (Олена Коваль, Premium рівень)
      await repository.createOrder(
        userId: 2, 
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
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
              // Ліва частина: Список товарів
              Expanded(
                flex: 2,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartState.items.length,
                  itemBuilder: (context, index) {
                    final item = cartState.items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.medication, size: 40, color: Colors.teal),
                        title: Text(item.medicine.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${item.medicine.price} ₴ x ${item.quantity} шт.'),
                        trailing: Text(
                          '${(item.medicine.price * item.quantity).toStringAsFixed(2)} ₴',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Права частина: Checkout форма (адаптовано для Web)
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
                        
                        // Вибір аптеки (тільки для самовивозу), дані тягнемо з CatalogCubit
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
                        
                        // Підсумкова сума
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Разом:', style: TextStyle(fontSize: 18)),
                            Text(
                              '${cartState.totalPrice.toStringAsFixed(2)} ₴', 
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)
                            ),
                          ],
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