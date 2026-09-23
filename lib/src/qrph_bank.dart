/// The wallet or bank (acquirer) a QR Ph payload is generated for.
///
/// Use this enum — instead of a raw string — when building a
/// [QrPhAccount], so unsupported values are caught at compile time:
///
/// ```dart
/// const account = QrPhAccount(
///   bank: QrPhBank.gcash,
///   accountNumber: '09171234567',
///   accountName: 'JUAN A DELA CRUZ',
///   branchLocation: 'QUEZON CITY',
/// );
/// ```
///
/// If you receive the bank as a plain string (e.g. from a database or an
/// API), convert it with [QrPhBankPayload.parse].
enum QrPhBank {
  /// GCash wallet (`GXCHPHM2XXX` merchant-account prefix).
  gcash,

  /// Maya wallet.
  ///
  /// Reuses the BDO merchant-account prefix plus the legacy
  /// [QrPhBankPayload.mayaSuffix], preserving the original behaviour.
  maya,

  /// BDO Unibank (`BNORPHMMXXX` merchant-account prefix).
  bdo,

  /// Bank of the Philippine Islands (`BOPIPHMMXXX` prefix).
  bpi,

  /// Fallback for unrecognized bank names.
  ///
  /// Resolves to the BDO prefix, matching the original `bankUrl()`
  /// default branch. Prefer handling unknown input explicitly instead of
  /// relying on this.
  unknown;

  /// Uppercase display label, e.g. `GCASH`.
  String get label => name.toUpperCase();
}

/// Raw EMV merchant-account prefixes the payload is built from.
///
/// The constants are kept identical to the original `GcashController`
/// implementation so previously generated QRs stay stable.
abstract final class QrPhBankPayload {
  /// Merchant-account prefix for [QrPhBank.gcash].
  static const gcash =
      '00020101021227830012com.p2pqrpay0111GXCHPHM2XXX020899964403031521702000000065604';

  /// Merchant-account prefix for [QrPhBank.bdo]
  /// (also used as the base for [QrPhBank.maya] and [QrPhBank.unknown]).
  static const bdo =
      '00020101021227590012com.p2pqrpay0111BNORPHMMXXX02089996440304';

  /// Merchant-account prefix for [QrPhBank.bpi].
  static const bpi =
      '00020101021127610012com.p2pqrpay0111BOPIPHMMXXX02089996440304';

  /// Suffix appended right after the account number for [QrPhBank.maya].
  ///
  /// Preserved verbatim from the original implementation. If this value
  /// looks unfamiliar, verify it against your acquirer's specification —
  /// it resembles account-specific data.
  static const mayaSuffix = '0515+63-966-7004308';

  /// Converts a free-form bank name into a [QrPhBank].
  ///
  /// Matching is case-insensitive and ignores surrounding whitespace:
  /// `'gcash'` → [QrPhBank.gcash]. Anything unrecognized (including
  /// `null` and `''`) yields [QrPhBank.unknown].
  ///
  /// ```dart
  /// QrPhBankPayload.parse('Maya'); // QrPhBank.maya
  /// ```
  static QrPhBank parse(String? bankName) {
    switch (bankName?.trim().toUpperCase()) {
      case 'GCASH':
        return QrPhBank.gcash;
      case 'BDO':
        return QrPhBank.bdo;
      case 'BPI':
        return QrPhBank.bpi;
      case 'MAYA':
        return QrPhBank.maya;
      default:
        return QrPhBank.unknown;
    }
  }

  /// Returns the merchant-account base prefix for [bank].
  ///
  /// [QrPhBank.maya] and [QrPhBank.unknown] intentionally resolve to the
  /// BDO prefix (original behaviour).
  static String basePayload(QrPhBank bank) {
    switch (bank) {
      case QrPhBank.gcash:
        return gcash;
      case QrPhBank.bpi:
        return bpi;
      case QrPhBank.bdo:
      case QrPhBank.maya:
      case QrPhBank.unknown:
        return bdo;
    }
  }

  /// String-based variant of [basePayload]; see [parse].
  static String basePayloadForName(String? bankName) =>
      basePayload(parse(bankName));
}
