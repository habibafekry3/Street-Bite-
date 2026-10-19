import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class SaveCartUseCase {
  final CartRepository _repository;

  const SaveCartUseCase(this._repository);

  Future<void> call(List<CartItem> items) {
    return _repository.saveCart(items);
  }
}
