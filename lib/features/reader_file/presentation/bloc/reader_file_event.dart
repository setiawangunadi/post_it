part of 'reader_file_bloc.dart';

abstract class ReaderFileEvent extends Equatable {
  const ReaderFileEvent();
  @override
  List<Object?> get props => [];
}

class FetchReaderFile extends ReaderFileEvent {
  final String id;
  const FetchReaderFile(this.id);
  @override
  List<Object?> get props => [id];
}
