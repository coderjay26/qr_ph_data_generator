/// Supported QR Ph acquirers / wallets.
///
/// The raw EMV merchant-account prefixes are kept identical to the
/// original `GcashController` implementation so existing QRs stay stable.
enum QrPhBank {
  gcash,
  bdo,
  bpi,
  maya,
  unknown,
}

/// Raw merchant-account prefixes from `sample.md`.
abstract final class QrPhBankPayload {
  static const gcash =
      '00020101021227830012com.p2pqrpay0111GXCHPHM2XXX020899964403031521702000000065604';
  static const bdo =
      '00020101021227590012com.p2pqrpay0111BNORPHMMXXX02089996440304';
  static const bpi =
      '00020101021127610012com.p2pqrpay0111BOPIPHMMXXX02089996440304';

  /// Appended right after the account number when `bank == maya`.
  /// Preserved verbatim from the original implementation.
  static const mayaSuffix = '0515+63-966-7004308';

  /// Case-insensitive lookup. Unknown / empty names fall back to [bdo],
  /// matching the original `bankUrl()` default branch.
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

  /// Base payload for [bank]. [QrPhBank.maya] and [QrPhBank.unknown]
  /// intentionally resolve to the BDO prefix (original behaviour).
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

  static String basePayloadForName(String? bankName) =>
      basePayload(parse(bankName));
}
