import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/receipt.dart';
import '../repositories/receipt_repository.dart';

class GetReceiptHistory extends UseCase<List<Receipt>, NoParams> {
  final ReceiptRepository repository;

  GetReceiptHistory(this.repository);

  @override
  Future<Either<Failure, List<Receipt>>> call(NoParams params) {
    return repository.getReceiptHistory();
  }
}
