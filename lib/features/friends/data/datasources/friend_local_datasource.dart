import 'package:hive/hive.dart';

import '../../../../core/error/exception.dart';
import '../models/friend_model.dart';

abstract class FriendLocalDataSource {
  Future<List<FriendModel>> getFriends();
  Future<void> addFriend(String name);
}

class FriendLocalDataSourceImpl implements FriendLocalDataSource {
  static const boxName = 'friends_box';

  final Box<String> box;

  FriendLocalDataSourceImpl({required this.box});

  @override
  Future<List<FriendModel>> getFriends() async {
    try {
      final friends = box.values.map((name) => FriendModel(name: name)).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return friends;
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  Future<void> addFriend(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    try {
      await box.put(trimmed.toLowerCase(), trimmed);
    } catch (_) {
      throw CacheException();
    }
  }
}
