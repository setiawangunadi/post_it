part of 'receipt_history_bloc.dart';

abstract class ReceiptHistoryState extends Equatable {
  const ReceiptHistoryState();
  @override
  List<Object?> get props => [];
}

class HistoryInitial extends ReceiptHistoryState {}

class HistoryLoading extends ReceiptHistoryState {}

class HistoryLoaded extends ReceiptHistoryState {
  final List<Receipt> receipts;
  const HistoryLoaded(this.receipts);
  @override
  List<Object?> get props => [receipts];
}

class HistoryError extends ReceiptHistoryState {
  final String message;
  const HistoryError(this.message);
  @override
  List<Object?> get props => [message];
}
