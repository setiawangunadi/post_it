import 'package:flutter/material.dart';
import '../../data/local/user_storage.dart';

class PaymentInfoPage extends StatefulWidget {
  const PaymentInfoPage({super.key});

  @override
  State<PaymentInfoPage> createState() => _PaymentInfoPageState();
}

class _PaymentInfoPageState extends State<PaymentInfoPage> {
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bankName = await UserStorage.getBankName();
    final accountNumber = await UserStorage.getBankAccountNumber();
    final accountHolder = await UserStorage.getBankAccountHolder();
    if (!mounted) return;
    setState(() {
      _bankNameController.text = bankName ?? '';
      _accountNumberController.text = accountNumber ?? '';
      _accountHolderController.text = accountHolder ?? '';
      _loading = false;
    });
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await UserStorage.saveBankName(_bankNameController.text.trim());
    await UserStorage.saveBankAccountNumber(
      _accountNumberController.text.trim(),
    );
    await UserStorage.saveBankAccountHolder(
      _accountHolderController.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment info saved')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Info')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'This is included in payment requests you share with '
                  'friends, so they know where to send money.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bankNameController,
                  decoration: const InputDecoration(
                    labelText: 'Bank / e-wallet name',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _accountNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Account number',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _accountHolderController,
                  decoration: const InputDecoration(
                    labelText: 'Account holder name',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ],
            ),
    );
  }
}
