import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository _repository;

  const CreateOrderUseCase(this._repository);

  Future<String> call(OrderEntity order) {
    if (order.items.isEmpty) {
      throw ArgumentError('Cannot create an empty order.');
    }

    return _repository.createOrder(order);
  }
}
