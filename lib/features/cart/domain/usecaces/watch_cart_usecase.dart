import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class WatchCartUseCase {
  final CartRepository _repository;

  const WatchCartUseCase(this._repository);

  Stream<List<CartItem>> call() {
    return _repository.watchCart();
  }
}
