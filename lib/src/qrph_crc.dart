import 'dart:convert';

/// CRC-16/CCITT-FALSE calculator used by EMVCo QR payloads.
///
/// Parameters: `poly = 0x1021`, `init = 0xFFFF`, no xor-out.
/// Returns uppercase hex, zero-padded to 4 chars (e.g. `6E4A`).
class QrPhCrc {
  const QrPhCrc._();

  static String calculate(String qrString) {
    const int polynomial = 0x1021;
    int crc = 0xFFFF;

    for (final int byte in utf8.encode(qrString)) {
      crc ^= (byte << 8);
      for (int bit = 0; bit < 8; bit++) {
        if ((crc & 0x8000) != 0) {
          crc = (crc << 1) ^ polynomial;
        } else {
          crc <<= 1;
        }
      }
      crc &= 0xFFFF;
    }
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }

  /// Validates a full payload whose last 4 chars are the CRC
  /// of `<payload-without-last-4-chars>`.
  static bool verify(String fullPayload) {
    if (fullPayload.length < 4) return false;
    final body = fullPayload.substring(0, fullPayload.length - 4);
    final expected = calculate(body);
    return fullPayload.endsWith(expected);
  }
}
