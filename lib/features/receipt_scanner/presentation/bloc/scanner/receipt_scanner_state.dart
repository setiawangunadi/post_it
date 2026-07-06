part of 'receipt_scanner_bloc.dart';

abstract class ReceiptScannerState extends Equatable {
  const ReceiptScannerState();
  @override
  List<Object?> get props => [];
}

class ScannerInitial extends ReceiptScannerState {}

class ScannerProcessing extends ReceiptScannerState {}

class ScannerReview extends ReceiptScannerState {
  final Receipt receipt;
  const ScannerReview(this.receipt);
  @override
  List<Object?> get props => [receipt];
}

class ScannerSaved extends ReceiptScannerState {}

class ScannerError extends ReceiptScannerState {
  final String message;
  const ScannerError(this.message);
  @override
  List<Object?> get props => [message];
}
