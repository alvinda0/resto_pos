import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class PaymentMethodsLoadRequested extends PaymentEvent {
  const PaymentMethodsLoadRequested();
}

class PaymentProcessRequested extends PaymentEvent {
  final String orderId;
  final List<Map<String, dynamic>> paymentMethods;
  final double totalAmount;

  const PaymentProcessRequested({
    required this.orderId,
    required this.paymentMethods,
    required this.totalAmount,
  });

  @override
  List<Object?> get props => [orderId, paymentMethods, totalAmount];
}

class PaymentQRISGenerateRequested extends PaymentEvent {
  final String orderId;
  final double amount;

  const PaymentQRISGenerateRequested({
    required this.orderId,
    required this.amount,
  });

  @override
  List<Object?> get props => [orderId, amount];
}

class PaymentQRISStatusCheckRequested extends PaymentEvent {
  final String transactionId;

  const PaymentQRISStatusCheckRequested(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class PaymentMethodSelected extends PaymentEvent {
  final String method;

  const PaymentMethodSelected(this.method);

  @override
  List<Object?> get props => [method];
}

class PaymentAmountChanged extends PaymentEvent {
  final double amount;

  const PaymentAmountChanged(this.amount);

  @override
  List<Object?> get props => [amount];
}

class PaymentReset extends PaymentEvent {
  const PaymentReset();
}
