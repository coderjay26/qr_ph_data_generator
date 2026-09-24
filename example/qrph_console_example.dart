// Run with: dart run example/qrph_console_example.dart
// ignore_for_file: avoid_print
import 'package:qrph_data_generator/qrph_data_generator.dart';

void main() {
  // NOTE: values below are fictitious demo data — replace with real details.
  // Supported banks: GCASH, BDO, BPI (verified pattern) plus MAYA,
  // MAYA BANK, METROBANK, LANDBANK, UNIONBANK, RCBC, CHINABANK,
  // SECURITY BANK, PNB, CIMB, TONIK, GOTYME, UNO (UNTESTED —
  // BIC-derived, not verified with a real scan).
  const account = QrPhAccount(
    bank: QrPhBank.gcash,
    accountNumber: '09171234567',
    accountName: 'JUAN A DELA CRUZ',
    branchLocation: 'QUEZON CITY',
  );

  // Static QR (no amount).
  final staticPayload = QrPhDataGenerator.generate(account: account);
  print('Static QR data: $staticPayload');

  // Dynamic QR (with amount).
  final dynamicPayload = QrPhDataGenerator.generate(
    account: account,
    amount: 100.00,
  );
  print('Dynamic QR data (PHP 100.00): $dynamicPayload');

  // Encode `dynamicPayload` with your favourite QR widget, e.g. qr_flutter:
  // QrImageView(data: dynamicPayload, version: QrVersions.auto)
}
