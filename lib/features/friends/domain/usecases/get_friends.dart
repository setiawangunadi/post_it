import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/friend.dart';
import '../repositories/friend_repository.dart';

class GetFriends extends UseCase<List<Friend>, NoParams> {
  final FriendRepository repository;

  GetFriends(this.repository);

  @override
  Future<Either<Failure, List<Friend>>> call(NoParams params) {
    return repository.getFriends();
  }
}
