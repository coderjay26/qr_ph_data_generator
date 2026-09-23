import 'qrph_bank.dart';

/// Self-contained account model representing a merchant or payee.
///
/// Replaces the app-specific `BankDetails` dependency
/// so the package can be reused in any app.
class QrPhAccount {
  /// The bank or e-wallet of this account.
  /// Used to determine the correct payload prefix for the QR Ph code.
  final QrPhBank bank;

  /// Wallet / account number, e.g. `09171234567`.
  final String accountNumber;

  /// Merchant / account holder name, e.g. `JUAN A DELA CRUZ`.
  final String accountName;

  /// Merchant city / branch location, e.g. `QUEZON CITY`.
  final String branchLocation;

  /// EMV tag 61 (postal code). Original code hardcodes `1234`.
  final String postalCode;

  /// Creates a new [QrPhAccount] instance.
  /// 
  /// The [bank], [accountNumber], [accountName], and [branchLocation] are required.
  const QrPhAccount({
    required this.bank,
    required this.accountNumber,
    required this.accountName,
    required this.branchLocation,
    this.postalCode = '1234',
  });

  void validate() {
    if (accountNumber.isEmpty) {
      throw ArgumentError('Account number must not be empty.');
    }
    if (accountName.isEmpty) {
      throw ArgumentError('Account name must not be empty.');
    }
    if (branchLocation.isEmpty) {
      throw ArgumentError('Branch location must not be empty.');
    }
    for (final entry in {
      'accountNumber': accountNumber,
      'accountName': accountName,
      'branchLocation': branchLocation,
      'postalCode': postalCode,
    }.entries) {
      if (entry.value.length > 99) {
        throw ArgumentError(
            '${entry.key} is ${entry.value.length} chars; EMV length prefix supports max 99.');
      }
    }
  }
}
