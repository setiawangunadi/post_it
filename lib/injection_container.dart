import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:post_it/data_source/remote/service_network.dart';
import 'package:post_it/features/reader_file/data/datasources/reader_file_local_datasource.dart';
import 'package:post_it/features/reader_file/data/datasources/reader_file_remote_datasource.dart';
import 'package:post_it/features/reader_file/data/repositories/reader_file_repository_impl.dart';
import 'package:post_it/features/reader_file/domain/repositories/reader_file_repository.dart';
import 'package:post_it/features/reader_file/domain/usecases/get_reader_file.dart';
import 'package:post_it/features/reader_file/presentation/bloc/reader_file_bloc.dart';
import 'package:post_it/features/receipt_scanner/data/datasources/receipt_local_datasource.dart';
import 'package:post_it/features/receipt_scanner/data/datasources/receipt_ocr_datasource.dart';
import 'package:post_it/features/receipt_scanner/data/repositories/receipt_repository_impl.dart';
import 'package:post_it/features/receipt_scanner/domain/repositories/receipt_repository.dart';
import 'package:post_it/features/receipt_scanner/domain/usecases/delete_receipt.dart';
import 'package:post_it/features/receipt_scanner/domain/usecases/get_receipt_history.dart';
import 'package:post_it/features/receipt_scanner/domain/usecases/save_receipt.dart';
import 'package:post_it/features/receipt_scanner/domain/usecases/scan_receipt.dart';
import 'package:post_it/features/receipt_scanner/presentation/bloc/history/receipt_history_bloc.dart';
import 'package:post_it/features/receipt_scanner/presentation/bloc/scanner/receipt_scanner_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton(() => ServiceNetwork());

  // ── ReaderFile ──────────────────────────────────────────
  sl.registerFactory(() => ReaderFileBloc(getReaderFile: sl()));
  sl.registerLazySingleton(() => GetReaderFile(sl()));
  sl.registerLazySingleton<ReaderFileRepository>(
    () => ReaderFileRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<ReaderFileRemoteDataSource>(
    () => ReaderFileRemoteDataSourceImpl(network: sl()),
  );
  sl.registerLazySingleton<ReaderFileLocalDataSource>(
    () => ReaderFileLocalDataSourceImpl(),
  );

  // ── ReceiptScanner ──────────────────────────────────────
  await Hive.initFlutter();
  final receiptsBox =
      await Hive.openBox<String>(ReceiptLocalDataSourceImpl.boxName);

  sl.registerFactory(
    () => ReceiptScannerBloc(scanReceipt: sl(), saveReceipt: sl()),
  );
  sl.registerFactory(
    () => ReceiptHistoryBloc(getReceiptHistory: sl(), deleteReceipt: sl()),
  );
  sl.registerLazySingleton(() => ScanReceipt(sl()));
  sl.registerLazySingleton(() => SaveReceipt(sl()));
  sl.registerLazySingleton(() => GetReceiptHistory(sl()));
  sl.registerLazySingleton(() => DeleteReceipt(sl()));
  sl.registerLazySingleton<ReceiptRepository>(
    () => ReceiptRepositoryImpl(ocrDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<ReceiptOcrDataSource>(
    () => ReceiptOcrDataSourceImpl(),
  );
  sl.registerLazySingleton<ReceiptLocalDataSource>(
    () => ReceiptLocalDataSourceImpl(box: receiptsBox),
  );
}
