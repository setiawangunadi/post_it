import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/receipt.dart';

abstract class ReceiptRepository {
  /// Runs OCR on [imagePath] and parses the recognized text into a
  /// [Receipt] draft. The result is not persisted until [saveReceipt]
  /// is called.
  Future<Either<Failure, Receipt>> scanReceipt(String imagePath);

  Future<Either<Failure, void>> saveReceipt(Receipt receipt);

  Future<Either<Failure, List<Receipt>>> getReceiptHistory();

  Future<Either<Failure, void>> deleteReceipt(String id);
}
