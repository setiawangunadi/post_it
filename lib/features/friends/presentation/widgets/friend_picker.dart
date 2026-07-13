import 'package:flutter/material.dart';
import '../../../../generated/l10n.dart';
import '../../domain/entities/friend.dart';

/// Lets the user split an item's cost across one or more friends.
///
/// - For a qty-1 item there's exactly one physical unit, so it can't be
///   divided by count — tapping a friend adds them to an evenly-split
///   group instead (e.g. two friends sharing one dish each carry 50% of
///   its cost).
/// - For qty>1, per-friend quantity steppers assign whole units instead
///   (e.g. 2 of 3 fries orders to Bob, 1 to Ann).
class FriendPicker extends StatelessWidget {
  final List<Friend> friends;
  final int quantity;
  final Map<String, double> assignments;
  final ValueChanged<Map<String, double>> onAssignmentsChanged;
  final ValueChanged<String> onAddFriend;

  const FriendPicker({
    super.key,
    required this.friends,
    required this.quantity,
    required this.assignments,
    required this.onAssignmentsChanged,
    required this.onAddFriend,
  });

  String _label(BuildContext context) {
    if (assignments.isEmpty) return S.of(context).assignChipLabel;
    if (assignments.length == 1 && assignments.values.first == quantity) {
      return assignments.keys.first;
    }
    if (quantity == 1) {
      // Shared evenly — names alone read more naturally than "x0.5".
      return assignments.keys.join(', ');
    }
    return assignments.entries
        .map((e) => '${e.key} x${e.value.toInt()}')
        .join(', ');
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
      label: Text(_label(context), overflow: TextOverflow.ellipsis),
      onPressed: () => _openPicker(context),
    );
  }
}

class _AssignmentSheet extends StatefulWidget {
  final List<Friend> friends;
  final int quantity;
  final Map<String, double> initialAssignments;
  final ValueChanged<Map<String, double>> onAssignmentsChanged;
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
  late Map<String, double> _assignments;
  final _controller = TextEditingController();

  /// A qty-1 item can't be divided into whole units, so it's split by cost
  /// instead: everyone tapped in shares it evenly, rather than each person
  /// claiming a specific unit count.
  bool get _isSharedMode => widget.quantity == 1;

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

  double get _assignedCount =>
      _assignments.values.fold(0, (sum, qty) => sum + qty);

  double get _remaining => widget.quantity - _assignedCount;

  void _commit() {
    final cleaned = Map.of(_assignments)..removeWhere((_, qty) => qty <= 0);
    widget.onAssignmentsChanged(cleaned);
    setState(() => _assignments = cleaned);
  }

  void _redistributeEvenly() {
    if (_assignments.isEmpty) return;
    final share = widget.quantity / _assignments.length;
    for (final name in _assignments.keys.toList()) {
      _assignments[name] = share;
    }
  }

  /// Toggles [name]'s membership in the evenly-split group (qty-1 items
  /// only), then re-splits the item's cost evenly across whoever remains.
  void _toggleShared(String name) {
    if (_assignments.containsKey(name)) {
      _assignments.remove(name);
    } else {
      _assignments[name] = 0;
    }
    _redistributeEvenly();
    _commit();
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
    if (name.isEmpty) return;
    if (!_isSharedMode && _remaining <= 0) return;
    widget.onAddFriend(name);
    _controller.clear();
    _isSharedMode ? _toggleShared(name) : _increment(name);
  }

  @override
  Widget build(BuildContext context) {
    final assignedNames = _assignments.keys.toSet();
    final otherFriends =
        widget.friends.where((f) => !assignedNames.contains(f.name)).toList();
    final canAddMore = _isSharedMode || _remaining > 0;

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
            Text(
              S.of(context).assignToTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_isSharedMode && _assignments.length > 1) ...[
              const SizedBox(height: 4),
              Text(
                S.of(context).splitEvenlyAmongHint(_assignments.length),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ] else if (!_isSharedMode && widget.quantity > 1) ...[
              const SizedBox(height: 4),
              Text(
                S.of(context).remainingOfQuantityHint(
                      _remaining.toInt(),
                      widget.quantity,
                    ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            ..._assignments.entries.map(
              (entry) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: Text(entry.key),
                trailing: _isSharedMode
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_assignments.length > 1)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text('${(entry.value * 100).round()}%'),
                            ),
                          IconButton(
                            icon: const Icon(Icons.person_off_outlined),
                            onPressed: () => _toggleShared(entry.key),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _decrement(entry.key),
                          ),
                          Text('${entry.value.toInt()}'),
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
                enabled: canAddMore,
                onTap: !canAddMore
                    ? null
                    : () => _isSharedMode
                        ? _toggleShared(friend.name)
                        : _increment(friend.name),
              ),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: canAddMore,
                    decoration: InputDecoration(
                      labelText: S.of(context).newFriendNameLabel,
                    ),
                    onSubmitted: (_) => _addNewFriend(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: canAddMore ? _addNewFriend : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(S.of(context).doneButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
