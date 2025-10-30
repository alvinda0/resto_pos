import 'package:equatable/equatable.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class PaymentMethodsLoaded extends PaymentState {
  final List<String> methods;

  const PaymentMethodsLoaded(this.methods);

  @override
  List<Object?> get props => [methods];
}

class PaymentProcessing extends PaymentState {
  const PaymentProcessing();
}

class PaymentSuccess extends PaymentState {
  final String message;
  final String orderId;

  const PaymentSuccess({
    required this.message,
    required this.orderId,
  });

  @override
  List<Object?> get props => [message, orderId];
}

class PaymentQRISGenerated extends PaymentState {
  final String qrCode;
  final String transactionId;
  final double amount;

  const PaymentQRISGenerated({
    required this.qrCode,
    required this.transactionId,
    required this.amount,
  });

  @override
  List<Object?> get props => [qrCode, transactionId, amount];
}

class PaymentQRISPending extends PaymentState {
  final String transactionId;

  const PaymentQRISPending(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class PaymentQRISPaid extends PaymentState {
  final String transactionId;

  const PaymentQRISPaid(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class PaymentFormState extends PaymentState {
  final String selectedMethod;
  final double amount;
  final double change;

  const PaymentFormState({
    required this.selectedMethod,
    required this.amount,
    required this.change,
  });

  @override
  List<Object?> get props => [selectedMethod, amount, change];

  PaymentFormState copyWith({
    String? selectedMethod,
    double? amount,
    double? change,
  }) {
    return PaymentFormState(
      selectedMethod: selectedMethod ?? this.selectedMethod,
      amount: amount ?? this.amount,
      change: change ?? this.change,
    );
  }
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}
