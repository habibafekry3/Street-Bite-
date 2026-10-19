import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _dataSource;

  CartRepositoryImpl(this._dataSource);

  @override
  Stream<List<CartItem>> watchCart() {
    return _dataSource.watchCart();
  }

  @override
  Future<void> saveCart(List<CartItem> items) {
    return _dataSource.saveCart(items);
  }
}
