import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/dependency_injection/injection.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/domain/payment/card_payment.dart';
import '../../../orders/domain/payment/cash_payment.dart';
import '../../../orders/presentation/cubit/order_cubit.dart';
import '../../../orders/presentation/cubit/order_state.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderCubit>(),
      child: BlocListener<OrderCubit, OrderState>(
        listener: (context, orderState) {
          if (orderState.status == OrderStatus.success) {
            context.read<CartCubit>().clearAll();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Order placed successfully! ID: ${orderState.orderId}',
                ),
              ),
            );

            context.read<OrderCubit>().reset();
          } else if (orderState.status == OrderStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to place order: ${orderState.errorMessage}',
                ),
              ),
            );

            context.read<OrderCubit>().reset();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'cartTitle'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  if (state.items.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return IconButton(
                    tooltip: 'removeAll'.tr(),
                    icon: const Icon(Icons.delete_sweep_outlined),
                    onPressed: () => _confirmRemoveAll(context),
                  );
                },
              ),
            ],
          ),
          body: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state.error != null) {
                return _buildError(context, state.error!);
              }

              if (state.items.isEmpty) {
                return _buildEmptyCart(context);
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.items.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = state.items[index];

                        return Card(
                          elevation: 1,
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item.meal.thumbnailUrl,
                                    width: 82,
                                    height: 82,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 82,
                                        height: 82,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHighest,
                                        child: const Icon(
                                          Icons.restaurant,
                                          size: 32,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.meal.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        item.meal.category,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        item.meal.area,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        tooltip: 'increaseQuantity'.tr(),
                                        onPressed: () {
                                          context.read<CartCubit>().addItem(
                                            item.meal,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                      ),
                                      Text(
                                        '${item.quantity}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        tooltip: 'decreaseQuantity'.tr(),
                                        onPressed: () {
                                          context.read<CartCubit>().removeItem(
                                            item.meal.id,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  _buildCartSummary(context, totalItems: state.itemCount),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 20),
            Text(
              'cartEmpty'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'cartEmptySubtitle'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'cartError'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CartCubit>().watchCart();
              },
              icon: const Icon(Icons.refresh),
              label: Text('retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, {required int totalItems}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'totalItems'.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$totalItems',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<OrderCubit, OrderState>(
              builder: (context, orderState) {
                final isLoading = orderState.status == OrderStatus.loading;

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading || totalItems == 0
                        ? null
                        : () => _confirmCheckout(context),
                    icon: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.shopping_bag_outlined),
                    label: Text(isLoading ? 'Processing...' : 'checkout'.tr()),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: totalItems == 0
                    ? null
                    : () => _confirmRemoveAll(context),
                icon: const Icon(Icons.delete_outline),
                label: Text('removeAll'.tr()),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemoveAll(BuildContext context) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.delete_outline),
          title: Text('removeAll'.tr()),
          content: Text('confirmRemoveAll'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('cancel'.tr()),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text('removeAll'.tr()),
            ),
          ],
        );
      },
    );

    if (shouldRemove == true && context.mounted) {
      context.read<CartCubit>().clearAll();
    }
  }

  Future<void> _confirmCheckout(BuildContext context) async {
    final cartCubit = context.read<CartCubit>();
    final orderCubit = context.read<OrderCubit>();

    if (cartCubit.state.items.isEmpty ||
        orderCubit.state.status == OrderStatus.loading) {
      return;
    }

    String selectedPayment = 'cash';

    final paymentMethod = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              icon: const Icon(Icons.shopping_bag_outlined),
              title: Text('checkout'.tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('confirmCheckout'.tr()),
                  const SizedBox(height: 12),
                  RadioGroup<String>(
                    groupValue: selectedPayment,
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedPayment = value;
                        });
                      }
                    },
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<String>(
                          value: 'cash',
                          title: Text('Cash'),
                        ),
                        RadioListTile<String>(
                          value: 'card',
                          title: Text('Card'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('cancel'.tr()),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, selectedPayment);
                  },
                  child: Text('confirm'.tr()),
                ),
              ],
            );
          },
        );
      },
    );

    if (paymentMethod == null || !context.mounted) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in before checkout.')),
      );
      return;
    }

    final cartItems = List.of(cartCubit.state.items);

    if (cartItems.isEmpty) return;

    final payment = paymentMethod == 'cash' ? CashPayment() : CardPayment();

    final order = OrderEntity(
      id: '',
      userId: userId,
      items: cartItems,
      createdAt: DateTime.now(),
      status: 'pending',
      paymentMethod: payment.type,
    );

    await orderCubit.checkout(order);
  }
}
