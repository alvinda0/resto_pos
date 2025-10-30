import 'package:flutter_bloc/flutter_bloc.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  String _selectedMethod = 'Tunai';
  double _amount = 0.0;
  double _change = 0.0;

  final List<String> availableMethods = [
    'Tunai',
    'Qris',
    'Transfer Bank',
    'Kartu Kredit',
    'Kartu Debit',
  ];

  PaymentBloc() : super(const PaymentInitial()) {
    on<PaymentMethodsLoadRequested>(_onMethodsLoadRequested);
    on<PaymentProcessRequested>(_onProcessRequested);
    on<PaymentQRISGenerateRequested>(_onQRISGenerateRequested);
    on<PaymentQRISStatusCheckRequested>(_onQRISStatusCheckRequested);
    on<PaymentMethodSelected>(_onMethodSelected);
    on<PaymentAmountChanged>(_onAmountChanged);
    on<PaymentReset>(_onReset);
  }

  String get selectedMethod => _selectedMethod;
  double get amount => _amount;
  double get change => _change;

  void _onMethodsLoadRequested(
    PaymentMethodsLoadRequested event,
    Emitter<PaymentState> emit,
  ) {
    emit(PaymentMethodsLoaded(availableMethods));
  }

  Future<void> _onProcessRequested(
    PaymentProcessRequested event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(const PaymentProcessing());

      // TODO: Implement actual payment processing

      await Future.delayed(const Duration(seconds: 2));

      emit(PaymentSuccess(
        message: 'Pembayaran berhasil diproses',
        orderId: event.orderId,
      ));
    } catch (e) {
      emit(PaymentError('Gagal memproses pembayaran: ${e.toString()}'));
    }
  }

  Future<void> _onQRISGenerateRequested(
    PaymentQRISGenerateRequested event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(const PaymentLoading());

      // TODO: Implement actual QRIS generation

      await Future.delayed(const Duration(seconds: 1));

      emit(PaymentQRISGenerated(
        qrCode: 'QRIS_CODE_${event.orderId}',
        transactionId: 'TRX_${DateTime.now().millisecondsSinceEpoch}',
        amount: event.amount,
      ));
    } catch (e) {
      emit(PaymentError('Gagal generate QRIS: ${e.toString()}'));
    }
  }

  Future<void> _onQRISStatusCheckRequested(
    PaymentQRISStatusCheckRequested event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      // TODO: Implement actual QRIS status check

      await Future.delayed(const Duration(seconds: 1));

      // Simulate random status
      final isPaid = DateTime.now().second % 2 == 0;

      if (isPaid) {
        emit(PaymentQRISPaid(event.transactionId));
      } else {
        emit(PaymentQRISPending(event.transactionId));
      }
    } catch (e) {
      emit(PaymentError('Gagal cek status QRIS: ${e.toString()}'));
    }
  }

  void _onMethodSelected(
    PaymentMethodSelected event,
    Emitter<PaymentState> emit,
  ) {
    _selectedMethod = event.method;
    emit(PaymentFormState(
      selectedMethod: _selectedMethod,
      amount: _amount,
      change: _change,
    ));
  }

  void _onAmountChanged(
    PaymentAmountChanged event,
    Emitter<PaymentState> emit,
  ) {
    _amount = event.amount;
    // Calculate change if needed
    emit(PaymentFormState(
      selectedMethod: _selectedMethod,
      amount: _amount,
      change: _change,
    ));
  }

  void _onReset(
    PaymentReset event,
    Emitter<PaymentState> emit,
  ) {
    _selectedMethod = 'Tunai';
    _amount = 0.0;
    _change = 0.0;
    emit(const PaymentInitial());
  }
}
