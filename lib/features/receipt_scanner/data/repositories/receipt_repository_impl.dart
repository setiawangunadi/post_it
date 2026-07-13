import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../datasources/receipt_local_datasource.dart';
import '../datasources/receipt_ocr_datasource.dart';
import '../datasources/receipt_text_parser.dart';
import '../models/receipt_model.dart';

class ReceiptRepositoryImpl implements ReceiptRepository {
  final ReceiptOcrDataSource ocrDataSource;
  final ReceiptLocalDataSource localDataSource;

  ReceiptRepositoryImpl({
    required this.ocrDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Receipt>> scanReceipt(String imagePath) async {
    try {
      final recognized = await ocrDataSource.recognize(imagePath);
      final parsed = ReceiptTextParser.parse(recognized);
      final receipt = Receipt(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        imagePath: imagePath,
        merchantName: parsed.merchantName,
        scannedAt: DateTime.now(),
        items: parsed.items,
        total: parsed.total,
        serviceCharge: parsed.serviceCharge,
        tax: parsed.tax,
        adjustment: parsed.adjustment,
        discount: parsed.discount,
        rawText: recognized.text,
      );
      return Right(receipt);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveReceipt(Receipt receipt) async {
    try {
      final storedImagePath =
          await _persistImage(receipt.id, receipt.imagePath);
      final toStore = ReceiptModel.fromEntity(
        receipt.copyWith(imagePath: storedImagePath),
      );
      await localDataSource.cacheReceipt(toStore);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('Failed to save receipt'));
    }
  }

  @override
  Future<Either<Failure, List<Receipt>>> getReceiptHistory() async {
    try {
      final receipts = await localDataSource.getCachedReceipts();
      return Right(receipts);
    } on CacheException {
      return const Left(CacheFailure('Failed to load receipt history'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReceipt(String id) async {
    try {
      await localDataSource.deleteReceipt(id);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('Failed to delete receipt'));
    }
  }

  Future<String> _persistImage(String id, String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory('${dir.path}/receipts');
    if (!await receiptsDir.exists()) {
      await receiptsDir.create(recursive: true);
    }
    final destPath = '${receiptsDir.path}/$id.jpg';
    if (sourcePath == destPath) return destPath;
    await File(sourcePath).copy(destPath);
    return destPath;
  }
}
