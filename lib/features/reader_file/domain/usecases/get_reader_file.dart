import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/reader_file.dart';
import '../repositories/reader_file_repository.dart';

class GetReaderFile extends UseCase<ReaderFile, GetReaderFileParams> {
  final ReaderFileRepository repository;

  GetReaderFile(this.repository);

  @override
  Future<Either<Failure, ReaderFile>> call(GetReaderFileParams params) {
    return repository.getReaderFile(params.id);
  }
}

class GetReaderFileParams extends Equatable {
  final String id;
  const GetReaderFileParams({required this.id});

  @override
  List<Object?> get props => [id];
}
