import 'payment_method.dart';

class CardPayment implements PaymentMethod {
  @override
  String get type => 'card';
}
