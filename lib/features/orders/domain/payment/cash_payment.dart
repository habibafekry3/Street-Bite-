import 'payment_method.dart';

class CashPayment implements PaymentMethod {
  @override
  String get type => 'cash';
}
