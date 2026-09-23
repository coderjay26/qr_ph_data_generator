# qrph_data_generator

EMVCo / **QR Ph** payload (data string) generator for Philippine e-wallets and banks
(`GCASH`, `MAYA`, `BDO`, `BPI`). Feed the resulting string into any QR renderer
(e.g. [`qr_flutter`](https://pub.dev/packages/qr_flutter)) to display a scannable QR Ph code.

Ported from `sample.md` (`GcashController`) and decoupled from app-specific models.

- Built & tested with **Flutter 3.38.8 / Dart 3.10.7**
- Package: `qrph_data_generator`
- Android applicationId prefix: `com.jjautomationsolution` \
  (sanitized from `com.jj-automation-solution` — dashes are illegal in Java/Kotlin package names)

## Features

- `QrPhDataGenerator.generate()` — dynamic (with amount, EMV tag `54`) and static (no amount) QR Ph payloads
- `QrPhAccount` — plain model replacing the old `BankDetails` import
- `QrPhBank` / `QrPhBankPayload` — GCash / BDO / BPI base prefixes + legacy Maya suffix
- `QrPhCrc` — CRC-16/CCITT-FALSE (`poly 0x1021`, `init 0xFFFF`), with `verify()`
- Deprecated `GcashController` typedef kept for backwards compatibility

## Getting started

```yaml
dependencies:
  qrph_data_generator: ^0.1.0
```

Requires `sdk: ^3.10.7` and `flutter: ">=3.38.0"`.

## Usage

```dart
import 'package:qrph_data_generator/qrph_data_generator.dart';

// NOTE: fictitious demo data — substitute real account details.
const account = QrPhAccount(
  bankName: 'GCASH',
  accountNumber: '09171234567',
  accountName: 'JUAN A DELA CRUZ',
  branchLocation: 'QUEZON CITY',
);

// Static QR (no amount)
final staticData = QrPhDataGenerator.generate(account: account);

// Dynamic QR (PHP 100.00)
final dynamicData = QrPhDataGenerator.generate(account: account, amount: 100.00);
```

Then render it:

```dart
// QrImageView(data: dynamicData, version: QrVersions.auto)
```

See [`example/lib/main.dart`](example/lib/main.dart) (run with `cd example && flutter run`)
and [`example/qrph_console_example.dart`](example/qrph_console_example.dart)
(run with `dart run example/qrph_console_example.dart`).

### Sample vector

Input above (no amount, fictitious data) produces exactly:

```text
00020101021127830012com.p2pqrpay0111GXCHPHM2XXX02089996440303152170200000006560411091712345675204601653036085802PH5916JUAN A DELA CRUZ6011QUEZON CITY6104123463043085
```

## Additional information

- Original reference implementation is preserved in [`sample.md`](sample.md).
- `MAYA` accounts reuse the BDO base prefix plus the legacy `0515+63-966-7004308` suffix (original behaviour).
- Length prefixes use `String.length` (not UTF-8 byte length) to stay bit-compatible with the original code.
- File issues / contribute at your repository URL.
