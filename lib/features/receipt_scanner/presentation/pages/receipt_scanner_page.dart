import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../injection_container.dart';
import '../../domain/entities/receipt.dart';
import '../bloc/scanner/receipt_scanner_bloc.dart';
import '../widgets/receipt_item_tile.dart';

class ReceiptScannerPage extends StatelessWidget {
  const ReceiptScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReceiptScannerBloc>(),
      child: const _ReceiptScannerView(),
    );
  }
}

class _ReceiptScannerView extends StatefulWidget {
  const _ReceiptScannerView();

  @override
  State<_ReceiptScannerView> createState() => _ReceiptScannerViewState();
}

class _ReceiptScannerViewState extends State<_ReceiptScannerView> {
  final _picker = ImagePicker();
  final _merchantController = TextEditingController();
  final _serviceChargeController = TextEditingController();
  final _taxController = TextEditingController();
  final _adjustmentController = TextEditingController();

  Receipt? _draft;
  List<ReceiptItem> _editableItems = [];

  @override
  void dispose() {
    _merchantController.dispose();
    _serviceChargeController.dispose();
    _taxController.dispose();
    _adjustmentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 90);
    if (picked == null || !mounted) return;
    context.read<ReceiptScannerBloc>().add(ScanReceiptRequested(picked.path));
  }

  double get _itemsTotal =>
      _editableItems.fold(0, (sum, item) => sum + item.lineTotal);

  double get _grandTotal =>
      _itemsTotal +
      (double.tryParse(_serviceChargeController.text) ?? 0) +
      (double.tryParse(_taxController.text) ?? 0) +
      (double.tryParse(_adjustmentController.text) ?? 0);

  void _save() {
    if (_draft == null) return;
    final receipt = _draft!.copyWith(
      merchantName: _merchantController.text,
      items: _editableItems,
      serviceCharge: double.tryParse(_serviceChargeController.text),
      tax: double.tryParse(_taxController.text),
      adjustment: double.tryParse(_adjustmentController.text),
    );
    context.read<ReceiptScannerBloc>().add(SaveReceiptRequested(receipt));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Receipt')),
      body: BlocConsumer<ReceiptScannerBloc, ReceiptScannerState>(
        listener: (context, state) {
          if (state is ScannerReview) {
            setState(() {
              _draft = state.receipt;
              _editableItems = List.of(state.receipt.items);
              _merchantController.text = state.receipt.merchantName ?? '';
              _serviceChargeController.text =
                  state.receipt.serviceCharge?.toStringAsFixed(0) ?? '';
              _taxController.text = state.receipt.tax?.toStringAsFixed(0) ?? '';
              _adjustmentController.text =
                  state.receipt.adjustment?.toStringAsFixed(0) ?? '';
            });
          } else if (state is ScannerSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Receipt saved')),
            );
            Navigator.of(context).pop();
          } else if (state is ScannerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ScannerProcessing) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ScannerReview ||
              (_draft != null && state is! ScannerInitial)) {
            return _buildReview();
          }
          return _buildPickButtons(context);
        },
      ),
    );
  }

  Widget _buildPickButtons(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Choose from Gallery'),
          ),
        ],
      ),
    );
  }

  Widget _buildReview() {
    final draft = _draft!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              Image.file(File(draft.imagePath), height: 180, fit: BoxFit.cover),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _merchantController,
          decoration: const InputDecoration(labelText: 'Merchant'),
        ),
        const SizedBox(height: 16),
        Text('Items', style: Theme.of(context).textTheme.titleMedium),
        const Divider(),
        ..._editableItems.asMap().entries.map((entry) {
          final index = entry.key;
          return ReceiptItemTile(
            key: ValueKey(index),
            item: entry.value,
            onChanged: (updated) =>
                setState(() => _editableItems[index] = updated),
            onDelete: () => setState(() => _editableItems.removeAt(index)),
          );
        }),
        TextButton.icon(
          onPressed: () => setState(
            () => _editableItems
                .add(const ReceiptItem(name: '', quantity: 1, price: 0)),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Add item'),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Items subtotal'),
            Text(_itemsTotal.toStringAsFixed(0)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _serviceChargeController,
                decoration: const InputDecoration(labelText: 'Service Charge'),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _taxController,
                decoration: const InputDecoration(labelText: 'Tax (PPN)'),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _adjustmentController,
          decoration: const InputDecoration(labelText: 'Adjustment'),
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              _grandTotal.toStringAsFixed(0),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save Receipt'),
        ),
      ],
    );
  }
}
