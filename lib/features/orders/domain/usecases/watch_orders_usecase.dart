import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class WatchOrdersUseCase {
  final OrderRepository _repository;

  const WatchOrdersUseCase(this._repository);

  Stream<List<OrderEntity>> call(String userId) {
    return _repository.watchOrders(userId);
  }
}
