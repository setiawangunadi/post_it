import 'package:equatable/equatable.dart';

class ReaderFile extends Equatable {
  final String id;

  const ReaderFile({required this.id});

  @override
  List<Object?> get props => [id];
}
