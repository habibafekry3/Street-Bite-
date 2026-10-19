import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/create_order_usecase.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final CreateOrderUseCase _createOrder;

  OrderCubit({required CreateOrderUseCase createOrder})
    : _createOrder = createOrder,
      super(const OrderState());

  Future<void> checkout(OrderEntity order) async {
    if (isClosed || state.status == OrderStatus.loading) return;

    emit(
      state.copyWith(
        status: OrderStatus.loading,
        clearError: true,
        clearOrderId: true,
      ),
    );

    try {
      final orderId = await _createOrder(order);

      if (isClosed) return;

      emit(
        state.copyWith(
          status: OrderStatus.success,
          orderId: orderId,
          clearError: true,
        ),
      );
    } catch (error) {
      if (isClosed) return;

      emit(
        state.copyWith(
          status: OrderStatus.failure,
          errorMessage: error.toString(),
          clearOrderId: true,
        ),
      );
    }
  }

  void reset() {
    if (isClosed) return;
    emit(const OrderState());
  }
}
