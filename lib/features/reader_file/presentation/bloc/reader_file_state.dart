part of 'reader_file_bloc.dart';

abstract class ReaderFileState extends Equatable {
  const ReaderFileState();
  @override
  List<Object?> get props => [];
}

class ReaderFileInitial extends ReaderFileState {}

class ReaderFileLoading extends ReaderFileState {}

class ReaderFileLoaded extends ReaderFileState {
  final ReaderFile data;
  const ReaderFileLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class ReaderFileError extends ReaderFileState {
  final String message;
  const ReaderFileError(this.message);
  @override
  List<Object?> get props => [message];
}
