import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/receipt.dart';
import '../repositories/receipt_repository.dart';

class ScanReceipt extends UseCase<Receipt, ScanReceiptParams> {
  final ReceiptRepository repository;

  ScanReceipt(this.repository);

  @override
  Future<Either<Failure, Receipt>> call(ScanReceiptParams params) {
    return repository.scanReceipt(params.imagePath);
  }
}

class ScanReceiptParams extends Equatable {
  final String imagePath;
  const ScanReceiptParams({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}
