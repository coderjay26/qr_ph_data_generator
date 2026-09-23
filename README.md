# 🚀 QR Ph Data Generator

An EMVCo / **QR Ph** payload (data string) generator for Philippine e-wallets and banks (`GCASH`, `BDO`, `BPI`). 

Feed the resulting string into any QR renderer (e.g. [`qr_flutter`](https://pub.dev/packages/qr_flutter)) to display a scannable QR Ph code.

Ported from the original `GcashController` implementation and decoupled from app-specific models, making it entirely reusable across projects.

- 🛠 Built & tested with **Flutter 3.38.8 / Dart 3.10.7**
- 📦 Package: `qrph_data_generator`

---

## ✨ Features

- **Dynamic & Static QR**: Generate dynamic (with amount, EMV tag `54`) or static (no amount) QR Ph payloads.
- **Type-Safe Banks**: Uses the `QrPhBank` enum to enforce supported banks (GCash, BDO, BPI).
- **CRC-16/CCITT-FALSE**: Includes `QrPhCrc` (`poly 0x1021`, `init 0xFFFF`), complete with `verify()`.
- **Legacy Support**: Deprecated `GcashController` typedef kept for backwards compatibility.

---

## 🚀 Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  qrph_data_generator: ^0.1.0
```

*Requires `sdk: ^3.10.7` and `flutter: ">=3.38.0"`.*

---

## 💻 Usage

```dart
import 'package:qrph_data_generator/qrph_data_generator.dart';

// NOTE: Fictitious demo data — substitute with real account details.
const account = QrPhAccount(
  bank: QrPhBank.gcash, // Use the type-safe enum
  accountNumber: '09171234567',
  accountName: 'JUAN A DELA CRUZ',
  branchLocation: 'QUEZON CITY',
);

// 1️⃣ Static QR (no amount)
final staticData = QrPhDataGenerator.generate(account: account);

// 2️⃣ Dynamic QR (PHP 100.00)
final dynamicData = QrPhDataGenerator.generate(account: account, amount: 100.00);
```

### Rendering the QR Code
Once you have the payload string, you can render it using `qr_flutter`:

```dart
QrImageView(
  data: dynamicData, 
  version: QrVersions.auto,
  size: 200.0,
)
```

> **Tip:** See [`example/lib/main.dart`](example/lib/main.dart) to run the full Flutter example (`cd example && flutter run`) or [`example/qrph_console_example.dart`](example/qrph_console_example.dart) for a pure Dart console run (`dart run example/qrph_console_example.dart`).

---

### 🔍 Sample Vector Output

Using the static demo data above produces the following raw EMV string:

```text
00020101021127830012com.p2pqrpay0111GXCHPHM2XXX02089996440303152170200000006560411091712345675204601653036085802PH5916JUAN A DELA CRUZ6011QUEZON CITY6104123463043085
```

---

## 📚 Additional Information


- **Length prefixes**: Length prefixes use `String.length` (not UTF-8 byte length) to stay bit-compatible with the original code.
- **Contributions**: Feel free to file issues or contribute via pull requests at your repository URL.
