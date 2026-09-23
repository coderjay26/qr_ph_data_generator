import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrph_data_generator/qrph_data_generator.dart';

void main() => runApp(const QrPhExampleApp());

class QrPhExampleApp extends StatelessWidget {
  const QrPhExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Ph Generator Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const QrPhDemoPage(),
    );
  }
}

class QrPhDemoPage extends StatefulWidget {
  const QrPhDemoPage({super.key});

  @override
  State<QrPhDemoPage> createState() => _QrPhDemoPageState();
}

class _QrPhDemoPageState extends State<QrPhDemoPage> {
  static const _banks = ['GCASH', 'MAYA', 'BDO', 'BPI'];

  String _bank = _banks.first;
  final _numberCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _payload = '';
  String? _error;

  @override
  void dispose() {
    _numberCtrl.dispose();
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _fillDemoData() {
    setState(() {
      _bank = 'GCASH';
      _numberCtrl.text = '09171234567';
      _nameCtrl.text = 'JUAN A DELA CRUZ';
      _locationCtrl.text = 'QUEZON CITY';
      _amountCtrl.text = '';
      _error = null;
      _payload = '';
    });
  }

  void _generate() {
    setState(() {
      _error = null;
      _payload = '';
      try {
        final amountText = _amountCtrl.text.trim();
        final amount =
            amountText.isEmpty ? null : double.parse(amountText);
        final account = QrPhAccount(
          bankName: _bank,
          accountNumber: _numberCtrl.text.trim(),
          accountName: _nameCtrl.text.trim(),
          branchLocation: _locationCtrl.text.trim(),
        );
        _payload = QrPhDataGenerator.generate(
          account: account,
          amount: amount,
        );
      } on FormatException {
        _error = 'Amount must be a number, e.g. 100.00';
      } catch (e) {
        _error = e.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Ph Generator Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _bank,
            decoration: const InputDecoration(labelText: 'Bank / wallet'),
            items: [
              for (final bank in _banks)
                DropdownMenuItem(value: bank, child: Text(bank)),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _bank = value);
            },
          ),
          TextField(
            controller: _numberCtrl,
            decoration: const InputDecoration(
              labelText: 'Account number',
              hintText: 'e.g. 09171234567',
            ),
          ),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Account name',
              hintText: 'e.g. JUAN A DELA CRUZ',
            ),
          ),
          TextField(
            controller: _locationCtrl,
            decoration: const InputDecoration(
              labelText: 'Branch location',
              hintText: 'e.g. QUEZON CITY',
            ),
          ),
          TextField(
            controller: _amountCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount (empty = static QR)',
              hintText: 'e.g. 100.00',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _generate,
            child: const Text('Generate QR data'),
          ),
          TextButton(
            onPressed: _fillDemoData,
            child: const Text('Fill demo data'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Colors.red.shade700)),
          ],
          if (_payload.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('Payload (encode with qr_flutter):'),
            const SizedBox(height: 4),
            SelectableText(_payload),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Clipboard.setData(
                ClipboardData(text: _payload),
              ),
              icon: const Icon(Icons.copy),
              label: const Text('Copy'),
            ),
          ],
        ],
      ),
    );
  }
}
