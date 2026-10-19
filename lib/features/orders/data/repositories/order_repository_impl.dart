import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasource/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;

  const OrderRepositoryImpl(this._remoteDataSource);

  @override
  Future<String> createOrder(OrderEntity order) {
    return _remoteDataSource.createOrder(order);
  }

  @override
  Stream<List<OrderEntity>> watchOrders(String userId) {
    return _remoteDataSource.watchOrders(userId);
  }
}
