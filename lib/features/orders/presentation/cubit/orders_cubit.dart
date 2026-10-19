import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/watch_orders_usecase.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final WatchOrdersUseCase _watchOrders;

  StreamSubscription? _subscription;

  OrdersCubit({required WatchOrdersUseCase watchOrders})
    : _watchOrders = watchOrders,
      super(const OrdersState());

  void loadOrders(String userId) {
    if (isClosed || _subscription != null) return;

    emit(state.copyWith(status: OrdersStatus.loading, clearError: true));

    try {
      _subscription = _watchOrders(userId).listen(
        (orders) {
          if (isClosed) return;

          emit(
            state.copyWith(
              status: OrdersStatus.success,
              orders: orders,
              clearError: true,
            ),
          );
        },
        onError: (Object error) {
          if (isClosed) return;

          emit(
            state.copyWith(
              status: OrdersStatus.failure,
              errorMessage: error.toString(),
            ),
          );
        },
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: OrdersStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
