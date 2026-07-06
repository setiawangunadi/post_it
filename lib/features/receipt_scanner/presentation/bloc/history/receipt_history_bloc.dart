import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../domain/entities/receipt.dart';
import '../../../domain/usecases/delete_receipt.dart';
import '../../../domain/usecases/get_receipt_history.dart';

part 'receipt_history_event.dart';
part 'receipt_history_state.dart';

class ReceiptHistoryBloc
    extends Bloc<ReceiptHistoryEvent, ReceiptHistoryState> {
  final GetReceiptHistory getReceiptHistory;
  final DeleteReceipt deleteReceipt;

  ReceiptHistoryBloc({
    required this.getReceiptHistory,
    required this.deleteReceipt,
  }) : super(HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<DeleteHistoryReceipt>(_onDeleteHistoryReceipt);
  }

  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<ReceiptHistoryState> emit,
  ) async {
    emit(HistoryLoading());
    final result = await getReceiptHistory(const NoParams());
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (receipts) => emit(HistoryLoaded(receipts)),
    );
  }

  Future<void> _onDeleteHistoryReceipt(
    DeleteHistoryReceipt event,
    Emitter<ReceiptHistoryState> emit,
  ) async {
    final result = await deleteReceipt(DeleteReceiptParams(id: event.id));
    await result.fold(
      (failure) async => emit(HistoryError(failure.message)),
      (_) async => _onLoadHistory(const LoadHistory(), emit),
    );
  }
}
