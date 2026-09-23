import 'qrph_account.dart';
import 'qrph_bank.dart';
import 'qrph_crc.dart';

/// Generates EMVCo / QR Ph data strings (the text you encode into a QR).
///
/// Ported from the original `GcashController.getGcashdetails` and cleaned up:
/// * no dependency on app-specific models — pass a plain [QrPhAccount].
/// * `amount` is optional. When `null`, EMV tag `54` is omitted
///   (static QR, see sample `...53036085802PH...`).
/// * CRC-16/CCITT-FALSE handling extracted to [QrPhCrc].
class QrPhDataGenerator {
  const QrPhDataGenerator._();

  // ------------------------------------------------------------------
  // Low-level helpers (kept compatible with the original names/behaviour)
  // ------------------------------------------------------------------

  /// `54` + 2-digit length of `amount.toStringAsFixed(2)`.
  ///
  /// e.g. `100.00` (`"100.00"`, len 6) → `"5406"`.
  static String calculatePrefixDigit(double amount) {
    if (amount.isNaN || amount.isInfinite || amount < 0) {
      throw ArgumentError('Amount must be a finite value >= 0: $amount');
    }
    final amountString = amount.toStringAsFixed(2);
    final length = amountString.length;
    if (length == 0 || length > 99) {
      throw ArgumentError('Amount is invalid or empty.');
    }
    return '54${length.toString().padLeft(2, '0')}';
  }

  /// 2-digit EMV length prefix for names / ids / locations.
  static String calculateNamePrefixDigit(String value) {
    if (value.isEmpty || value.length > 99) {
      throw ArgumentError('String is invalid or empty.');
    }
    return value.length.toString().padLeft(2, '0');
  }

  /// Case-insensitive base-payload lookup. Defaults to BDO.
  static String bankUrl(String bankName) =>
      QrPhBankPayload.basePayloadForName(bankName);

  /// Resolves the merchant-account base and normalizes EMV tag `01`
  /// (point of initiation): `11` = static (no amount), `12` = dynamic.
  ///
  /// This matches the original EMV pattern (`...010211...` for the amount-less sample)
  /// while keeping the original `...010212...` constants for dynamic QRs.
  static String resolveBasePayload(QrPhBank bank, bool hasAmount) {
    final base = QrPhBankPayload.basePayload(bank);
    const prefix = '0002010102';
    if (!base.startsWith(prefix) || base.length < prefix.length + 2) {
      return base;
    }
    final initiation = hasAmount ? '12' : '11';
    return '$prefix$initiation${base.substring(prefix.length + 2)}';
  }

  // ------------------------------------------------------------------
  // High-level API
  // ------------------------------------------------------------------

  /// Builds the final QR payload string including the `6304XXXX` CRC trailer.
  ///
  /// Layout (preserved from the original implementation):
  /// ```text
  /// <bankBase><len(accountNumber)><accountNumber>
  /// 52046016 5303608 [54<len><amount>]
  /// 5802PH 59<len><accountName> 60<len><branchLocation> 61<postalLen><postalCode>
  /// 6304<CRC>
  /// ```
  static String generate({
    required QrPhAccount account,
    double? amount,
    String merchantCategoryCode = '6016',
    String currencyCode = '608',
    String countryCode = 'PH',
  }) {
    account.validate();
    if (merchantCategoryCode.length != 4) {
      throw ArgumentError('merchantCategoryCode must be 4 digits.');
    }
    if (currencyCode.length != 3) {
      throw ArgumentError('currencyCode must be 3 digits (e.g. 608 for PHP).');
    }

    final base = resolveBasePayload(account.bank, amount != null);

    final userId = account.accountNumber;
    final prefixUserId = calculateNamePrefixDigit(userId);
    final nickName = account.accountName;
    final prefixNickName = calculateNamePrefixDigit(nickName);
    final location = account.branchLocation;
    final areaCode = calculateNamePrefixDigit(location);
    final postalPrefix = calculateNamePrefixDigit(account.postalCode);


    final amountSection = amount == null
        ? ''
        : '${calculatePrefixDigit(amount)}${amount.toStringAsFixed(2)}';

    final qrWithoutCrc = '$base$prefixUserId$userId'
        '52${merchantCategoryCode.length.toString().padLeft(2, '0')}$merchantCategoryCode'
        '53${currencyCode.length.toString().padLeft(2, '0')}$currencyCode'
        '$amountSection'
        '58${countryCode.length.toString().padLeft(2, '0')}$countryCode'
        '59$prefixNickName$nickName'
        '60$areaCode$location'
        '61$postalPrefix${account.postalCode}';

    final crc = QrPhCrc.calculate('${qrWithoutCrc}6304');
    return '${qrWithoutCrc}6304$crc';
  }

  /// Backwards-compatible wrapper mirroring
  /// `GcashController.getGcashdetails(double amount, BankDetails bank)`.
  ///
  /// Pass `amount: null` via [generate] for amount-less (static) QRs.
  static String getGcashdetails(double amount, QrPhAccount bank) =>
      generate(account: bank, amount: amount);
}

/// Legacy name kept so existing call sites (`GcashController.*`) keep
/// compiling. Prefer [QrPhDataGenerator] for new code.
@Deprecated('Use QrPhDataGenerator instead.')
typedef GcashController = QrPhDataGenerator;
