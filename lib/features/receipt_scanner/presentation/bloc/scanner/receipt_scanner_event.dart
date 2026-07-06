part of 'receipt_scanner_bloc.dart';

abstract class ReceiptScannerEvent extends Equatable {
  const ReceiptScannerEvent();
  @override
  List<Object?> get props => [];
}

class ScanReceiptRequested extends ReceiptScannerEvent {
  final String imagePath;
  const ScanReceiptRequested(this.imagePath);
  @override
  List<Object?> get props => [imagePath];
}

class SaveReceiptRequested extends ReceiptScannerEvent {
  final Receipt receipt;
  const SaveReceiptRequested(this.receipt);
  @override
  List<Object?> get props => [receipt];
}

class ScannerReset extends ReceiptScannerEvent {}
