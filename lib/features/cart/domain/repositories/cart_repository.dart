import '../entities/cart_item.dart';

abstract class CartRepository {
  Stream<List<CartItem>> watchCart();

  Future<void> saveCart(List<CartItem> items);
}
