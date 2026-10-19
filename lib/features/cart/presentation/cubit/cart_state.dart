import '../../domain/entities/cart_item.dart';

class CartState {
  final List<CartItem> items;
  final String? error;

  const CartState({this.items = const [], this.error});

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({
    List<CartItem>? items,
    String? error,
    bool clearError = false,
  }) {
    return CartState(
      items: items ?? this.items,
      error: clearError ? null : error ?? this.error,
    );
  }
}
