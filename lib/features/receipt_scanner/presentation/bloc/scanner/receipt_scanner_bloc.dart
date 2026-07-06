import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/receipt.dart';
import '../../../domain/usecases/save_receipt.dart';
import '../../../domain/usecases/scan_receipt.dart';

part 'receipt_scanner_event.dart';
part 'receipt_scanner_state.dart';

class ReceiptScannerBloc
    extends Bloc<ReceiptScannerEvent, ReceiptScannerState> {
  final ScanReceipt scanReceipt;
  final SaveReceipt saveReceipt;

  ReceiptScannerBloc({
    required this.scanReceipt,
    required this.saveReceipt,
  }) : super(ScannerInitial()) {
    on<ScanReceiptRequested>(_onScanReceiptRequested);
    on<SaveReceiptRequested>(_onSaveReceiptRequested);
    on<ScannerReset>((event, emit) => emit(ScannerInitial()));
  }

  Future<void> _onScanReceiptRequested(
    ScanReceiptRequested event,
    Emitter<ReceiptScannerState> emit,
  ) async {
    emit(ScannerProcessing());
    final result =
        await scanReceipt(ScanReceiptParams(imagePath: event.imagePath));
    result.fold(
      (failure) => emit(ScannerError(failure.message)),
      (receipt) => emit(ScannerReview(receipt)),
    );
  }

  Future<void> _onSaveReceiptRequested(
    SaveReceiptRequested event,
    Emitter<ReceiptScannerState> emit,
  ) async {
    emit(ScannerProcessing());
    final result = await saveReceipt(SaveReceiptParams(receipt: event.receipt));
    result.fold(
      (failure) => emit(ScannerError(failure.message)),
      (_) => emit(ScannerSaved()),
    );
  }
}
