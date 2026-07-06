import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/reader_file.dart';

abstract class ReaderFileRepository {
  Future<Either<Failure, ReaderFile>> getReaderFile(String id);
  Future<Either<Failure, List<ReaderFile>>> getAllReaderFiles();
}
