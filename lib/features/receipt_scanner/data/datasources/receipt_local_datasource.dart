import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../../core/error/exception.dart';
import '../models/receipt_model.dart';

abstract class ReceiptLocalDataSource {
  Future<void> cacheReceipt(ReceiptModel model);
  Future<List<ReceiptModel>> getCachedReceipts();
  Future<void> deleteReceipt(String id);
}

class ReceiptLocalDataSourceImpl implements ReceiptLocalDataSource {
  static const boxName = 'receipts_box';

  final Box<String> box;

  ReceiptLocalDataSourceImpl({required this.box});

  @override
  Future<void> cacheReceipt(ReceiptModel model) async {
    try {
      await box.put(model.id, jsonEncode(model.toJson()));
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  Future<List<ReceiptModel>> getCachedReceipts() async {
    try {
      final receipts = box.values
          .map(
            (raw) =>
                ReceiptModel.fromJson(jsonDecode(raw) as Map<String, dynamic>),
          )
          .toList();
      receipts.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
      return receipts;
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  Future<void> deleteReceipt(String id) async {
    try {
      await box.delete(id);
    } catch (_) {
      throw CacheException();
    }
  }
}
