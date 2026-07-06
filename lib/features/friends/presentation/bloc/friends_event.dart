part of 'friends_bloc.dart';

abstract class FriendsEvent extends Equatable {
  const FriendsEvent();
  @override
  List<Object?> get props => [];
}

class LoadFriends extends FriendsEvent {
  const LoadFriends();
}

class AddFriendRequested extends FriendsEvent {
  final String name;
  const AddFriendRequested(this.name);
  @override
  List<Object?> get props => [name];
}
