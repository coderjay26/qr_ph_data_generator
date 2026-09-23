/// Self-contained account model.
///
/// Replaces the app-specific `BankDetails` (`mybuddy2_0`) dependency from
/// `sample.md` so the package can be reused in any app.
class QrPhAccount {
  /// e.g. `GCASH`, `BDO`, `BPI`, `MAYA` (case-insensitive).
  final String bankName;

  /// Wallet / account number, e.g. `09171234567`.
  final String accountNumber;

  /// Merchant / account holder name, e.g. `JUAN A DELA CRUZ`.
  final String accountName;

  /// Merchant city / branch location, e.g. `QUEZON CITY`.
  final String branchLocation;

  /// EMV tag 61 (postal code). Original code hardcodes `1234`.
  final String postalCode;

  const QrPhAccount({
    required this.bankName,
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
