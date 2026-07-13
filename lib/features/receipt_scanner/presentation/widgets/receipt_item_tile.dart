import 'package:flutter/material.dart';
import '../../../../generated/l10n.dart';
import '../../../friends/domain/entities/friend.dart';
import '../../../friends/presentation/widgets/friend_picker.dart';
import '../../domain/entities/receipt.dart';

class ReceiptItemTile extends StatefulWidget {
  final ReceiptItem item;
  final List<Friend> friends;
  final ValueChanged<ReceiptItem> onChanged;
  final ValueChanged<String> onAddFriend;
  final VoidCallback onDelete;

  const ReceiptItemTile({
    super.key,
    required this.item,
    required this.friends,
    required this.onChanged,
    required this.onAddFriend,
    required this.onDelete,
  });

  @override
  State<ReceiptItemTile> createState() => _ReceiptItemTileState();
}

class _ReceiptItemTileState extends State<ReceiptItemTile> {
  late final TextEditingController _nameController;
  late final TextEditingController _qtyController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _qtyController =
        TextEditingController(text: widget.item.quantity.toString());
    _priceController =
        TextEditingController(text: widget.item.price.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _emitChange() {
    widget.onChanged(
      widget.item.copyWith(
        name: _nameController.text,
        quantity: int.tryParse(_qtyController.text) ?? 1,
        price: double.tryParse(_priceController.text) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration:
                      InputDecoration(labelText: S.of(context).itemFieldLabel),
                  onChanged: (_) => _emitChange(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: widget.onDelete,
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _qtyController,
                  decoration:
                      InputDecoration(labelText: S.of(context).qtyFieldLabel),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _emitChange(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _priceController,
                  decoration:
                      InputDecoration(labelText: S.of(context).priceFieldLabel),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => _emitChange(),
                ),
              ),
              const SizedBox(width: 8),
              FriendPicker(
                friends: widget.friends,
                quantity: widget.item.quantity,
                assignments: widget.item.assignments,
                onAddFriend: widget.onAddFriend,
                onAssignmentsChanged: (assignments) => widget.onChanged(
                  widget.item.copyWith(assignments: assignments),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
