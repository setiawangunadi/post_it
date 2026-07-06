import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/friend.dart';

abstract class FriendRepository {
  Future<Either<Failure, List<Friend>>> getFriends();
  Future<Either<Failure, void>> addFriend(String name);
}
