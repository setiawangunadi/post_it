part of 'friends_bloc.dart';

abstract class FriendsState extends Equatable {
  const FriendsState();
  @override
  List<Object?> get props => [];
}

class FriendsInitial extends FriendsState {}

class FriendsLoaded extends FriendsState {
  final List<Friend> friends;
  const FriendsLoaded(this.friends);
  @override
  List<Object?> get props => [friends];
}

class FriendsError extends FriendsState {
  final String message;
  const FriendsError(this.message);
  @override
  List<Object?> get props => [message];
}
