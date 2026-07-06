import 'package:dartz/dartz.dart';
import '../../../../core/error/exception.dart' hide NetworkException;
import '../../../../core/error/failure.dart';
import '../../../../shared/exception/network_exception.dart';
import '../../domain/entities/reader_file.dart';
import '../../domain/repositories/reader_file_repository.dart';
import '../datasources/reader_file_local_datasource.dart';
import '../datasources/reader_file_remote_datasource.dart';

class ReaderFileRepositoryImpl implements ReaderFileRepository {
  final ReaderFileRemoteDataSource remoteDataSource;
  final ReaderFileLocalDataSource localDataSource;

  ReaderFileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, ReaderFile>> getReaderFile(String id) async {
    try {
      final result = await remoteDataSource.getReaderFile(id);
      await localDataSource.cacheReaderFile(result);
      return Right(result);
    } on NetworkException catch (e) {
      try {
        final cached = await localDataSource.getCachedReaderFile(id);
        return Right(cached);
      } on CacheException {
        return Left(NetworkFailure(e.responseMessage ?? ''));
      }
    }
  }

  @override
  Future<Either<Failure, List<ReaderFile>>> getAllReaderFiles() async {
    try {
      // TODO: implement
      return const Right([]);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.responseMessage ?? ''));
    }
  }
}
