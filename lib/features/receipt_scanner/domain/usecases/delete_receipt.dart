import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/receipt_repository.dart';

class DeleteReceipt extends UseCase<void, DeleteReceiptParams> {
  final ReceiptRepository repository;

  DeleteReceipt(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteReceiptParams params) {
    return repository.deleteReceipt(params.id);
  }
}

class DeleteReceiptParams extends Equatable {
  final String id;
  const DeleteReceiptParams({required this.id});

  @override
  List<Object?> get props => [id];
}
