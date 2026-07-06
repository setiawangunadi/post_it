import 'package:equatable/equatable.dart';

class Friend extends Equatable {
  final String name;

  const Friend({required this.name});

  @override
  List<Object?> get props => [name];
}
