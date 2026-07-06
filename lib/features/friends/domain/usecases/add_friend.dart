import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/friend_repository.dart';

class AddFriend extends UseCase<void, AddFriendParams> {
  final FriendRepository repository;

  AddFriend(this.repository);

  @override
  Future<Either<Failure, void>> call(AddFriendParams params) {
    return repository.addFriend(params.name);
  }
}

class AddFriendParams extends Equatable {
  final String name;
  const AddFriendParams({required this.name});

  @override
  List<Object?> get props => [name];
}
