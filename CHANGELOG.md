## Unreleased

* Lower SDK floor to `sdk: '>=3.4.0 <4.0.0'` / `flutter: ">=3.22.0"`
  (verified with Flutter 3.22.3 / Dart 3.4.4); `flutter_lints` back to
  `^4.0.0`; example dropdown uses `value:` (no `initialValue` on 3.22).
* Add `maya`, `mayaBank`, `metrobank`, `landbank`, `unionbank`, `rcbc`,
  `chinabank`, `securitybank`, `pnb`, `cimb`, `tonik`, `gotyme`, `uno` to
  `QrPhBank` with BIC-derived base payloads and `parse()` aliases.
* ⚠️ UNTESTED: new payloads are derived from official SWIFT/BIC codes using
  the BDO short template — NOT verified with a real QR scan from each bank's
  app. Validate by scanning before production use.
* Tests: parse aliases + CRC-valid static/dynamic generation for every bank.

## 0.1.0

* Initial release.
* `QrPhAccount` model (replaces app-specific `BankDetails` dependency).
* `QrPhBank` with GCash / BDO / BPI base payloads.
* `QrPhDataGenerator.generate()` with optional `amount` (omits EMV tag 54 when null, matching static QR Ph).
* `QrPhCrc.calculate()` — CRC-16/CCITT-FALSE (`poly 0x1021`, `init 0xFFFF`).
* Backwards-compatible `GcashController.getGcashdetails()` preserved as deprecated alias.
* Tests cover CRC vectors, amount/name length prefixes, and the sample QR.
* EMV tag `01` normalized: `11` for static (no amount), `12` for dynamic —
  matches the original EMV pattern (`...010211...` amount-less) while keeping the original
  `...010212...` constants for amount-bearing QRs.
