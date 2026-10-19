import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cart_item.dart';
import '../../../home/domain/entities/meal_entity.dart';
import '../../domain/usecaces/save_cart_usecase.dart';
import '../../domain/usecaces/watch_cart_usecase.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final WatchCartUseCase _watchCart;
  final SaveCartUseCase _saveCart;

  StreamSubscription<List<CartItem>>? _subscription;
  Future<void> _saveQueue = Future<void>.value();

  CartCubit({
    required WatchCartUseCase watchCart,
    required SaveCartUseCase saveCart,
  }) : _watchCart = watchCart,
       _saveCart = saveCart,
       super(const CartState());

  void watchCart() {
    if (isClosed || _subscription != null) return;

    try {
      _subscription = _watchCart().listen(
        (items) {
          if (!isClosed) {
            emit(CartState(items: items));
          }
        },
        onError: (Object error) {
          _subscription = null;

          if (!isClosed) {
            emit(state.copyWith(error: error.toString()));
          }
        },
      );
    } catch (error) {
      _subscription = null;

      if (!isClosed) {
        emit(state.copyWith(error: error.toString()));
      }
    }
  }

  Future<void> _persist(List<CartItem> items) async {
    final snapshot = List<CartItem>.from(items);

    // Keep cart writes in order.
    final nextSave = _saveQueue
        .catchError((Object _) {})
        .then((_) => _saveCart(snapshot));

    _saveQueue = nextSave;

    try {
      await nextSave;
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(error: error.toString()));
      }
    }
  }

  void addItem(MealEntity meal) {
    final updated = List<CartItem>.from(state.items);
    final index = updated.indexWhere((item) => item.meal.id == meal.id);

    if (index >= 0) {
      updated[index] = updated[index].copyWith(
        quantity: updated[index].quantity + 1,
      );
    } else {
      updated.add(CartItem(meal: meal, quantity: 1));
    }

    emit(CartState(items: updated));
    unawaited(_persist(updated));
  }

  void removeItem(String mealId) {
    final updated = List<CartItem>.from(state.items);
    final index = updated.indexWhere((item) => item.meal.id == mealId);

    if (index < 0) return;

    if (updated[index].quantity > 1) {
      updated[index] = updated[index].copyWith(
        quantity: updated[index].quantity - 1,
      );
    } else {
      updated.removeAt(index);
    }

    emit(CartState(items: updated));
    unawaited(_persist(updated));
  }

  void clearAll() {
    emit(const CartState());
    unawaited(_persist(const []));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
