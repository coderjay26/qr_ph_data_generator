## 0.1.0

* Initial release.
* `QrPhAccount` model (replaces app-specific `BankDetails` dependency).
* `QrPhBank` with GCash / BDO / BPI base payloads + Maya suffix handling.
* `QrPhDataGenerator.generate()` with optional `amount` (omits EMV tag 54 when null, matching static QR Ph).
* `QrPhCrc.calculate()` — CRC-16/CCITT-FALSE (`poly 0x1021`, `init 0xFFFF`).
* Backwards-compatible `GcashController.getGcashdetails()` preserved as deprecated alias.
* Tests cover CRC vectors, amount/name length prefixes, and the sample QR from `sample.md`.
* EMV tag `01` normalized: `11` for static (no amount), `12` for dynamic —
  matches `sample.md` (`...010211...` amount-less) while keeping the original
  `...010212...` constants for amount-bearing QRs.
