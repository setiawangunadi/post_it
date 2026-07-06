import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/receipt.dart';
import '../repositories/receipt_repository.dart';

class SaveReceipt extends UseCase<void, SaveReceiptParams> {
  final ReceiptRepository repository;

  SaveReceipt(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveReceiptParams params) {
    return repository.saveReceipt(params.receipt);
  }
}

class SaveReceiptParams extends Equatable {
  final Receipt receipt;
  const SaveReceiptParams({required this.receipt});

  @override
  List<Object?> get props => [receipt];
}
