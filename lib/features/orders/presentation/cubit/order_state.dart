enum OrderStatus { initial, loading, success, failure }

class OrderState {
  final OrderStatus status;
  final String? errorMessage;
  final String? orderId;

  const OrderState({
    this.status = OrderStatus.initial,
    this.errorMessage,
    this.orderId,
  });

  OrderState copyWith({
    OrderStatus? status,
    String? errorMessage,
    String? orderId,
    bool clearError = false,
    bool clearOrderId = false,
  }) {
    return OrderState(
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      orderId: clearOrderId ? null : orderId ?? this.orderId,
    );
  }
}
