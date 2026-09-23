/// QR Ph data-string generator for Philippine wallets & banks.
///
/// Encode the string returned by `QrPhDataGenerator.generate` into a QR
/// (e.g. with `qr_flutter`) — this package only builds the payload text.
library;
export 'src/qrph_account.dart';
export 'src/qrph_bank.dart';
export 'src/qrph_crc.dart';
export 'src/qrph_generator.dart';
