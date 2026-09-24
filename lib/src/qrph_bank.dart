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


  /// BDO Unibank (`BNORPHMMXXX` merchant-account prefix).
  bdo,

  /// Bank of the Philippine Islands (`BOPIPHMMXXX` prefix).
  bpi,

  // ------------------------------------------------------------------
  // Additional banks below are UNTESTED — derived from official
  // SWIFT/BIC codes using the BDO short template
  // (`...27590012com.p2pqrpay0111<BIC>02089996440304`).
  // NOT verified against a real QR scan from each bank's app.
  // Validate by scanning before production use.
  // ------------------------------------------------------------------

  /// Maya wallet (`PAPHPHM1XXX` prefix). UNTESTED — derived from BIC only.
  maya,

  /// Maya Bank (`MYDBPHM2XXX` prefix). UNTESTED — derived from BIC only.
  mayaBank,

  /// Metropolitan Bank and Trust Company (`MBTCPHMMXXX`). UNTESTED.
  metrobank,

  /// Land Bank of the Philippines (`TLBPPHMMXXX`). UNTESTED.
  landbank,

  /// Union Bank of the Philippines (`UBPHPHMMXXX`). UNTESTED.
  unionbank,

  /// Rizal Commercial Banking Corporation (`RCBCPHMMXXX`). UNTESTED.
  rcbc,

  /// China Banking Corporation / Chinabank (`CHBKPHMMXXX`). UNTESTED.
  chinabank,

  /// Security Bank Corporation (`SETCPHMMXXX`). UNTESTED.
  securitybank,

  /// Philippine National Bank (`PNBMPHMMXXX`). UNTESTED.
  pnb,

  /// CIMB Bank Philippines (`CIPHPHMMXXX`). UNTESTED.
  cimb,

  /// Tonik Digital Bank (`TODGPHM2XXX`). UNTESTED.
  tonik,

  /// GoTyme Bank (`GOTYPHM2XXX`). UNTESTED.
  gotyme,

  /// UNO Digital Bank (`UNODPHM2XXX`). UNTESTED.
  uno,

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
///
/// New banks beyond [QrPhBank.gcash]/[QrPhBank.bdo]/[QrPhBank.bpi] are
/// UNTESTED: BIC-derived, not verified with a real QR scan.
abstract final class QrPhBankPayload {
  /// Merchant-account prefix for [QrPhBank.gcash].
  static const gcash =
      '00020101021227830012com.p2pqrpay0111GXCHPHM2XXX020899964403031521702000000065604';

  /// Merchant-account prefix for [QrPhBank.bdo]
  /// (also used as the base for [QrPhBank.unknown]).
  static const bdo =
      '00020101021227590012com.p2pqrpay0111BNORPHMMXXX02089996440304';

  /// Merchant-account prefix for [QrPhBank.bpi].
  static const bpi =
      '00020101021127610012com.p2pqrpay0111BOPIPHMMXXX02089996440304';

  // NOTE: every constant below is UNTESTED — BIC-derived using the BDO
  // short template. NOT verified with a real QR scan from the bank's app.

  /// UNTESTED. Maya wallet (`PAPHPHM1XXX`).
  static const maya =
      '00020101021227590012com.p2pqrpay0111PAPHPHM1XXX02089996440304';

  /// UNTESTED. Maya Bank (`MYDBPHM2XXX`).
  static const mayaBank =
      '00020101021227590012com.p2pqrpay0111MYDBPHM2XXX02089996440304';

  /// UNTESTED. Metrobank (`MBTCPHMMXXX`).
  static const metrobank =
      '00020101021227590012com.p2pqrpay0111MBTCPHMMXXX02089996440304';

  /// UNTESTED. LandBank (`TLBPPHMMXXX`).
  static const landbank =
      '00020101021227590012com.p2pqrpay0111TLBPPHMMXXX02089996440304';

  /// UNTESTED. UnionBank (`UBPHPHMMXXX`).
  static const unionbank =
      '00020101021227590012com.p2pqrpay0111UBPHPHMMXXX02089996440304';

  /// UNTESTED. RCBC (`RCBCPHMMXXX`).
  static const rcbc =
      '00020101021227590012com.p2pqrpay0111RCBCPHMMXXX02089996440304';

  /// UNTESTED. Chinabank (`CHBKPHMMXXX`).
  static const chinabank =
      '00020101021227590012com.p2pqrpay0111CHBKPHMMXXX02089996440304';

  /// UNTESTED. Security Bank (`SETCPHMMXXX`).
  static const securitybank =
      '00020101021227590012com.p2pqrpay0111SETCPHMMXXX02089996440304';

  /// UNTESTED. PNB (`PNBMPHMMXXX`).
  static const pnb =
      '00020101021227590012com.p2pqrpay0111PNBMPHMMXXX02089996440304';

  /// UNTESTED. CIMB (`CIPHPHMMXXX`).
  static const cimb =
      '00020101021227590012com.p2pqrpay0111CIPHPHMMXXX02089996440304';

  /// UNTESTED. Tonik (`TODGPHM2XXX`).
  static const tonik =
      '00020101021227590012com.p2pqrpay0111TODGPHM2XXX02089996440304';

  /// UNTESTED. GoTyme (`GOTYPHM2XXX`).
  static const gotyme =
      '00020101021227590012com.p2pqrpay0111GOTYPHM2XXX02089996440304';

  /// UNTESTED. UNO Digital Bank (`UNODPHM2XXX`).
  static const uno =
      '00020101021227590012com.p2pqrpay0111UNODPHM2XXX02089996440304';



  /// Converts a free-form bank name into a [QrPhBank].
  ///
  /// Matching is case-insensitive and ignores surrounding whitespace:
  /// `'gcash'` → [QrPhBank.gcash]. Anything unrecognized (including
  /// `null` and `''`) yields [QrPhBank.unknown].
  ///
  /// ```dart
  /// QrPhBankPayload.parse('BDO'); // QrPhBank.bdo
  /// ```
  static QrPhBank parse(String? bankName) {
    switch (bankName?.trim().toUpperCase()) {
      case 'GCASH':
      case 'G-XCHANGE':
      case 'GXCH':
        return QrPhBank.gcash;
      case 'BDO':
        return QrPhBank.bdo;
      case 'BPI':
        return QrPhBank.bpi;
      case 'MAYA':
      case 'PAYMAYA':
        return QrPhBank.maya;
      case 'MAYA BANK':
      case 'MAYABANK':
      case 'MYDB':
        return QrPhBank.mayaBank;
      case 'METROBANK':
      case 'METRO':
      case 'MBTC':
        return QrPhBank.metrobank;
      case 'LANDBANK':
      case 'LAND BANK':
      case 'LAND_BANK':
      case 'LBP':
        return QrPhBank.landbank;
      case 'UNIONBANK':
      case 'UNION BANK':
      case 'UBP':
        return QrPhBank.unionbank;
      case 'RCBC':
        return QrPhBank.rcbc;
      case 'CHINABANK':
      case 'CHINA BANK':
      case 'CHINABANKING':
      case 'CBC':
        return QrPhBank.chinabank;
      case 'SECURITYBANK':
      case 'SECURITY BANK':
      case 'SECURITY':
      case 'SBC':
        return QrPhBank.securitybank;
      case 'PNB':
        return QrPhBank.pnb;
      case 'CIMB':
        return QrPhBank.cimb;
      case 'TONIK':
        return QrPhBank.tonik;
      case 'GOTYME':
      case 'GO TYME':
        return QrPhBank.gotyme;
      case 'UNO':
      case 'UNODIGITAL':
      case 'UNO DIGITAL':
        return QrPhBank.uno;

      default:
        return QrPhBank.unknown;
    }
  }

  /// Returns the merchant-account base prefix for [bank].
  ///
  /// [QrPhBank.unknown] intentionally resolves to the
  /// BDO prefix (original behaviour).
  static String basePayload(QrPhBank bank) {
    switch (bank) {
      case QrPhBank.gcash:
        return gcash;
      case QrPhBank.bpi:
        return bpi;
      case QrPhBank.maya:
        return maya;
      case QrPhBank.mayaBank:
        return mayaBank;
      case QrPhBank.metrobank:
        return metrobank;
      case QrPhBank.landbank:
        return landbank;
      case QrPhBank.unionbank:
        return unionbank;
      case QrPhBank.rcbc:
        return rcbc;
      case QrPhBank.chinabank:
        return chinabank;
      case QrPhBank.securitybank:
        return securitybank;
      case QrPhBank.pnb:
        return pnb;
      case QrPhBank.cimb:
        return cimb;
      case QrPhBank.tonik:
        return tonik;
      case QrPhBank.gotyme:
        return gotyme;
      case QrPhBank.uno:
        return uno;
      case QrPhBank.bdo:

      case QrPhBank.unknown:
        return bdo;
    }
  }

  /// String-based variant of [basePayload]; see [parse].
  static String basePayloadForName(String? bankName) =>
      basePayload(parse(bankName));
}
