import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/friend.dart';
import '../../domain/usecases/add_friend.dart';
import '../../domain/usecases/get_friends.dart';

part 'friends_event.dart';
part 'friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final GetFriends getFriends;
  final AddFriend addFriend;

  FriendsBloc({required this.getFriends, required this.addFriend})
      : super(FriendsInitial()) {
    on<LoadFriends>(_onLoadFriends);
    on<AddFriendRequested>(_onAddFriendRequested);
  }

  Future<void> _onLoadFriends(
    LoadFriends event,
    Emitter<FriendsState> emit,
  ) async {
    final result = await getFriends(const NoParams());
    result.fold(
      (failure) => emit(FriendsError(failure.message)),
      (friends) => emit(FriendsLoaded(friends)),
    );
  }

  Future<void> _onAddFriendRequested(
    AddFriendRequested event,
    Emitter<FriendsState> emit,
  ) async {
    final result = await addFriend(AddFriendParams(name: event.name));
    await result.fold(
      (failure) async => emit(FriendsError(failure.message)),
      (_) async => _onLoadFriends(const LoadFriends(), emit),
    );
  }
}
