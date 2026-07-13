import 'package:dartz/dartz.dart';

import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../../../../generated/l10n.dart';
import '../../domain/entities/friend.dart';
import '../../domain/repositories/friend_repository.dart';
import '../datasources/friend_local_datasource.dart';

class FriendRepositoryImpl implements FriendRepository {
  final FriendLocalDataSource localDataSource;

  FriendRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Friend>>> getFriends() async {
    try {
      final friends = await localDataSource.getFriends();
      return Right(friends);
    } on CacheException {
      return Left(CacheFailure(S.current.failedToLoadFriends));
    }
  }

  @override
  Future<Either<Failure, void>> addFriend(String name) async {
    try {
      await localDataSource.addFriend(name);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure(S.current.failedToSaveFriend));
    }
  }
}
