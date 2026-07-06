import '../../../../shared/utils/response_server.dart';
import '../../../../data_source/remote/service_network.dart';
import '../models/reader_file_model.dart';

abstract class ReaderFileRemoteDataSource {
  Future<ReaderFileModel> getReaderFile(String id);
}

class ReaderFileRemoteDataSourceImpl implements ReaderFileRemoteDataSource {
  final ServiceNetwork network;

  ReaderFileRemoteDataSourceImpl({required this.network});

  @override
  Future<ReaderFileModel> getReaderFile(String id) async {
    final ResponseServer response = await network.request(
      'GET',
      '/reader_file/$id',
    );
    return ReaderFileModel.fromJson(response.data as Map<String, dynamic>);
  }
}
