import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/reader_file.dart';
import '../../domain/usecases/get_reader_file.dart';

part 'reader_file_event.dart';
part 'reader_file_state.dart';

class ReaderFileBloc extends Bloc<ReaderFileEvent, ReaderFileState> {
  final GetReaderFile getReaderFile;

  ReaderFileBloc({required this.getReaderFile}) : super(ReaderFileInitial()) {
    on<FetchReaderFile>(_onFetchReaderFile);
  }

  Future<void> _onFetchReaderFile(
    FetchReaderFile event,
    Emitter<ReaderFileState> emit,
  ) async {
    emit(ReaderFileLoading());
    final result = await getReaderFile(GetReaderFileParams(id: event.id));
    result.fold(
      (failure) => emit(ReaderFileError(failure.message)),
      (data) => emit(ReaderFileLoaded(data)),
    );
  }
}
