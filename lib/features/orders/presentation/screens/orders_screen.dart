import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/dependency_injection/injection.dart';
import '../../domain/entities/order_entity.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('ordersTitle'.tr())),
        body: Center(child: Text('loginRequired'.tr())),
      );
    }

    return BlocProvider(
      create: (_) => getIt<OrdersCubit>()..loadOrders(user.uid),
      child: Scaffold(
        appBar: AppBar(title: Text('ordersTitle'.tr())),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state.status == OrdersStatus.initial ||
                state.status == OrdersStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == OrdersStatus.failure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 56),
                      const SizedBox(height: 12),
                      Text('ordersLoadError'.tr(), textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text(
                        state.errorMessage ?? '',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<OrdersCubit>().loadOrders(user.uid);
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text('retry'.tr()),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state.orders.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.receipt_long_outlined, size: 72),
                      const SizedBox(height: 16),
                      Text('noOrders'.tr(), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _OrderCard(order: state.orders[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
        title: Text(
          '${'orderNumber'.tr()} ${order.id}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${'orderDate'.tr()}: '
          '${DateFormat.yMd(context.locale.toString()).add_jm().format(order.createdAt)}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const Divider(),
          _infoRow('orderStatus'.tr(), _localizedStatus(order.status)),
          _infoRow(
            'paymentMethod'.tr(),
            _localizedPayment(order.paymentMethod),
          ),
          _infoRow('totalItems'.tr(), '${order.totalItems}'),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text('orderItems'.tr(), style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: 8),
          ...order.items.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.meal.thumbnailUrl,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(
                    width: 52,
                    height: 52,
                    child: Icon(Icons.restaurant),
                  ),
                ),
              ),
              title: Text(item.meal.name),
              subtitle: Text(item.meal.category),
              trailing: Text('× ${item.quantity}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _localizedStatus(String status) {
    switch (status) {
      case 'pending':
        return 'statusPending'.tr();
      case 'completed':
        return 'statusCompleted'.tr();
      case 'cancelled':
        return 'statusCancelled'.tr();
      default:
        return status;
    }
  }

  String _localizedPayment(String method) {
    switch (method) {
      case 'cash':
        return 'paymentCash'.tr();
      case 'card':
        return 'paymentCard'.tr();
      default:
        return method;
    }
  }
}
