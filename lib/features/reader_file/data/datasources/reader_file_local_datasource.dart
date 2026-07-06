import '../../../../core/error/exception.dart';
import '../models/reader_file_model.dart';

abstract class ReaderFileLocalDataSource {
  Future<ReaderFileModel> getCachedReaderFile(String id);
  Future<void> cacheReaderFile(ReaderFileModel model);
}

class ReaderFileLocalDataSourceImpl implements ReaderFileLocalDataSource {
  // TODO: inject Hive box or SharedPreferences

  @override
  Future<ReaderFileModel> getCachedReaderFile(String id) async {
    throw CacheException();
  }

  @override
  Future<void> cacheReaderFile(ReaderFileModel model) async {
    // TODO: implement cache
  }
}
