import 'package:flutter/material.dart';
import '../../domain/entities/friend.dart';

/// Lets the user split an item's quantity across one or more friends. For a
/// qty-1 item this behaves like a plain single-select; for qty>1 it exposes
/// per-friend quantity steppers so e.g. a shared appetizer can be split.
class FriendPicker extends StatelessWidget {
  final List<Friend> friends;
  final int quantity;
  final Map<String, int> assignments;
  final ValueChanged<Map<String, int>> onAssignmentsChanged;
  final ValueChanged<String> onAddFriend;

  const FriendPicker({
    super.key,
    required this.friends,
    required this.quantity,
    required this.assignments,
    required this.onAssignmentsChanged,
    required this.onAddFriend,
  });

  String get _label {
    if (assignments.isEmpty) return 'Assign';
    if (assignments.length == 1 && assignments.values.first == quantity) {
      return assignments.keys.first;
    }
    return assignments.entries.map((e) => '${e.key} x${e.value}').join(', ');
  }

  Future<void> _openPicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AssignmentSheet(
        friends: friends,
        quantity: quantity,
        initialAssignments: assignments,
        onAssignmentsChanged: onAssignmentsChanged,
        onAddFriend: onAddFriend,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(
        assignments.isEmpty ? Icons.person_add_alt : Icons.person,
        size: 18,
      ),
      label: Text(_label, overflow: TextOverflow.ellipsis),
      onPressed: () => _openPicker(context),
    );
  }
}

class _AssignmentSheet extends StatefulWidget {
  final List<Friend> friends;
  final int quantity;
  final Map<String, int> initialAssignments;
  final ValueChanged<Map<String, int>> onAssignmentsChanged;
  final ValueChanged<String> onAddFriend;

  const _AssignmentSheet({
    required this.friends,
    required this.quantity,
    required this.initialAssignments,
    required this.onAssignmentsChanged,
    required this.onAddFriend,
  });

  @override
  State<_AssignmentSheet> createState() => _AssignmentSheetState();
}

class _AssignmentSheetState extends State<_AssignmentSheet> {
  late Map<String, int> _assignments;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _assignments = Map.of(widget.initialAssignments);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _assignedCount =>
      _assignments.values.fold(0, (sum, qty) => sum + qty);

  int get _remaining => widget.quantity - _assignedCount;

  void _commit() {
    final cleaned = Map.of(_assignments)..removeWhere((_, qty) => qty <= 0);
    widget.onAssignmentsChanged(cleaned);
    setState(() => _assignments = cleaned);
  }

  void _increment(String name) {
    if (_remaining <= 0) return;
    _assignments[name] = (_assignments[name] ?? 0) + 1;
    _commit();
  }

  void _decrement(String name) {
    final current = _assignments[name] ?? 0;
    if (current <= 1) {
      _assignments.remove(name);
    } else {
      _assignments[name] = current - 1;
    }
    _commit();
  }

  void _addNewFriend() {
    final name = _controller.text.trim();
    if (name.isEmpty || _remaining <= 0) return;
    widget.onAddFriend(name);
    _controller.clear();
    _increment(name);
  }

  @override
  Widget build(BuildContext context) {
    final assignedNames = _assignments.keys.toSet();
    final otherFriends =
        widget.friends.where((f) => !assignedNames.contains(f.name)).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assign to', style: Theme.of(context).textTheme.titleMedium),
            if (widget.quantity > 1) ...[
              const SizedBox(height: 4),
              Text(
                '$_remaining of ${widget.quantity} unassigned',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            ..._assignments.entries.map(
              (entry) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: Text(entry.key),
                trailing: widget.quantity == 1
                    ? IconButton(
                        icon: const Icon(Icons.person_off_outlined),
                        onPressed: () => _decrement(entry.key),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _decrement(entry.key),
                          ),
                          Text('${entry.value}'),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: _remaining > 0
                                ? () => _increment(entry.key)
                                : null,
                          ),
                        ],
                      ),
              ),
            ),
            if (otherFriends.isNotEmpty) const Divider(),
            ...otherFriends.map(
              (friend) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_add_alt_outlined),
                title: Text(friend.name),
                enabled: _remaining > 0,
                onTap: _remaining > 0 ? () => _increment(friend.name) : null,
              ),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: _remaining > 0,
                    decoration: const InputDecoration(
                      labelText: 'New friend name',
                    ),
                    onSubmitted: (_) => _addNewFriend(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: _remaining > 0 ? _addNewFriend : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
