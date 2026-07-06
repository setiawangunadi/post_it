import '../../domain/entities/friend.dart';

class FriendModel extends Friend {
  const FriendModel({required super.name});

  factory FriendModel.fromEntity(Friend friend) =>
      FriendModel(name: friend.name);
}
