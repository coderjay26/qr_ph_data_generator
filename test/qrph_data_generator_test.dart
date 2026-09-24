import 'package:flutter_test/flutter_test.dart';
import 'package:qrph_data_generator/qrph_data_generator.dart';

// NOTE: all account values below are fictitious demo data.
void main() {
  group('QrPhCrc', () {
    test('matches CRC-16/CCITT-FALSE check vector ("123456789" -> "29B1")', () {
      expect(QrPhCrc.calculate('123456789'), '29B1');
    });

    test('verify() accepts a payload with a correct CRC trailer', () {
      const account = QrPhAccount(
        bank: QrPhBank.gcash,
        accountNumber: '09171234567',
        accountName: 'JUAN A DELA CRUZ',
        branchLocation: 'QUEZON CITY',
      );
      final payload = QrPhDataGenerator.generate(account: account);
      expect(QrPhCrc.verify(payload), isTrue);
      expect(QrPhCrc.verify('${payload}X'), isFalse);
    });
  });

  group('length prefixes', () {
    test('calculatePrefixDigit formats amount tag', () {
      // "100.00" has length 6 -> "5406"
      expect(QrPhDataGenerator.calculatePrefixDigit(100), '5406');
      expect(QrPhDataGenerator.calculatePrefixDigit(100000.00), '5409');
    });

    test('calculateNamePrefixDigit pads to 2 digits', () {
      expect(
          QrPhDataGenerator.calculateNamePrefixDigit('09171234567'), '11');
      expect(
          QrPhDataGenerator.calculateNamePrefixDigit('JUAN A DELA CRUZ'),
          '16');
      expect(
          QrPhDataGenerator.calculateNamePrefixDigit('QUEZON CITY'), '11');
    });

    test('throws on empty input', () {
      expect(() => QrPhDataGenerator.calculateNamePrefixDigit(''),
          throwsArgumentError);
    });
  });

  group('bankUrl', () {
    test('resolves known banks case-insensitively, defaults to BDO', () {
      expect(QrPhDataGenerator.bankUrl('GCASH'), QrPhBankPayload.gcash);
      expect(QrPhDataGenerator.bankUrl('gcash'), QrPhBankPayload.gcash);
      expect(QrPhDataGenerator.bankUrl('BDO'), QrPhBankPayload.bdo);
      expect(QrPhDataGenerator.bankUrl('BPI'), QrPhBankPayload.bpi);
      expect(QrPhDataGenerator.bankUrl('SOME_UNKNOWN_BANK'),
          QrPhBankPayload.bdo);
    });

    test(
        'resolves added banks (UNTESTED payloads — BIC-derived, '
        'not verified with a real scan)', () {
      expect(QrPhBankPayload.parse('MAYA'), QrPhBank.maya);
      expect(QrPhBankPayload.parse('PayMaya'), QrPhBank.maya);
      expect(QrPhBankPayload.parse('Maya Bank'), QrPhBank.mayaBank);
      expect(QrPhBankPayload.parse('Metrobank'), QrPhBank.metrobank);
      expect(QrPhBankPayload.parse('MBTC'), QrPhBank.metrobank);
      expect(QrPhBankPayload.parse('Landbank'), QrPhBank.landbank);
      expect(QrPhBankPayload.parse('LBP'), QrPhBank.landbank);
      expect(QrPhBankPayload.parse('UBP'), QrPhBank.unionbank);
      expect(QrPhBankPayload.parse('RCBC'), QrPhBank.rcbc);
      expect(QrPhBankPayload.parse('Chinabank'), QrPhBank.chinabank);
      expect(QrPhBankPayload.parse('SBC'), QrPhBank.securitybank);
      expect(QrPhBankPayload.parse('PNB'), QrPhBank.pnb);
      expect(QrPhBankPayload.parse('CIMB'), QrPhBank.cimb);
      expect(QrPhBankPayload.parse('Tonik'), QrPhBank.tonik);
      expect(QrPhBankPayload.parse('GoTyme'), QrPhBank.gotyme);
      expect(QrPhBankPayload.parse('UNO'), QrPhBank.uno);
    });

    test('every non-unknown bank generates a CRC-valid payload', () {
      const bicByBank = {
        QrPhBank.maya: 'PAPHPHM1XXX',
        QrPhBank.mayaBank: 'MYDBPHM2XXX',
        QrPhBank.metrobank: 'MBTCPHMMXXX',
        QrPhBank.landbank: 'TLBPPHMMXXX',
        QrPhBank.unionbank: 'UBPHPHMMXXX',
        QrPhBank.rcbc: 'RCBCPHMMXXX',
        QrPhBank.chinabank: 'CHBKPHMMXXX',
        QrPhBank.securitybank: 'SETCPHMMXXX',
        QrPhBank.pnb: 'PNBMPHMMXXX',
        QrPhBank.cimb: 'CIPHPHMMXXX',
        QrPhBank.tonik: 'TODGPHM2XXX',
        QrPhBank.gotyme: 'GOTYPHM2XXX',
        QrPhBank.uno: 'UNODPHM2XXX',
      };
      for (final entry in bicByBank.entries) {
        final account = QrPhAccount(
          bank: entry.key,
          accountNumber: '09171234567',
          accountName: 'JUAN A DELA CRUZ',
          branchLocation: 'QUEZON CITY',
        );
        final staticQr = QrPhDataGenerator.generate(account: account);
        final dynamicQr =
            QrPhDataGenerator.generate(account: account, amount: 100);
        expect(staticQr, startsWith('000201010211'),
            reason: entry.key.name);
        expect(dynamicQr, startsWith('000201010212'),
            reason: entry.key.name);
        expect(staticQr, contains(entry.value), reason: entry.key.name);
        expect(QrPhCrc.verify(staticQr), isTrue, reason: entry.key.name);
        expect(QrPhCrc.verify(dynamicQr), isTrue, reason: entry.key.name);
      }
    });
  });

  group('QrPhDataGenerator.generate', () {
    const account = QrPhAccount(
      bank: QrPhBank.gcash,
      accountNumber: '09171234567',
      accountName: 'JUAN A DELA CRUZ',
      branchLocation: 'QUEZON CITY',
    );

    test('static QR omits amount tag and uses initiation method 11', () {
      final payload = QrPhDataGenerator.generate(account: account);
      expect(payload, startsWith('000201010211'));
      expect(payload, isNot(contains('54')));
      expect(payload, contains('1109171234567'));
      expect(payload, contains('5916JUAN A DELA CRUZ'));
      expect(payload, contains('6011QUEZON CITY'));
      expect(QrPhCrc.verify(payload), isTrue);
    });

    test('dynamic QR includes amount tag and uses initiation method 12', () {
      final payload =
          QrPhDataGenerator.generate(account: account, amount: 100);
      expect(payload, startsWith('000201010212'));
      expect(payload, contains('5406100.00'));
      expect(QrPhCrc.verify(payload), isTrue);
    });


    test('validates empty fields', () {
      const bad = QrPhAccount(
        bank: QrPhBank.gcash,
        accountNumber: '',
        accountName: 'X',
        branchLocation: 'Y',
      );
      expect(() => QrPhDataGenerator.generate(account: bad),
          throwsArgumentError);
    });
  });
}
