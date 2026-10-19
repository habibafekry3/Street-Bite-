import '../entities/order_entity.dart';

abstract class OrderRepository {
  // Creates a new order.
  Future<String> createOrder(OrderEntity order);

  // Watches the current user's previous orders.
  Stream<List<OrderEntity>> watchOrders(String userId);
}
