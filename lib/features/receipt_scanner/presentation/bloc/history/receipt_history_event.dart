part of 'receipt_history_bloc.dart';

abstract class ReceiptHistoryEvent extends Equatable {
  const ReceiptHistoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadHistory extends ReceiptHistoryEvent {
  const LoadHistory();
}

class DeleteHistoryReceipt extends ReceiptHistoryEvent {
  final String id;
  const DeleteHistoryReceipt(this.id);
  @override
  List<Object?> get props => [id];
}
