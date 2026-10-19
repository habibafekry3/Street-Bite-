import '../../../cart/domain/entities/cart_item.dart';

class OrderEntity {
  final String id;
  final String userId;
  final List<CartItem> items;
  final DateTime createdAt;
  final String status;
  final String paymentMethod;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.createdAt,
    required this.status,
    required this.paymentMethod,
  });

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}
