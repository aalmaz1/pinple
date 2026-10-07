import 'package:flutter_test/flutter_test.dart';
import 'package:pinple/core/localization/app_localizations.dart';
import 'package:pinple/core/utils/validators.dart';

void main() {
  // L10n.map 에 없는 키는 키 이름을 그대로 돌려주므로,
  // 테스트에서는 빈 사전을 넘기고 키 이름으로 결과를 검증한다.
  final l10n = L10n(const <String, String>{});

  group('isValidKongjuEmail', () {
    test('공주대 학교 메일 도메인만 통과시킨다', () {
      expect(isValidKongjuEmail('student@smail.kongju.ac.kr'), isTrue);
      expect(isValidKongjuEmail('student@kongju.ac.kr'), isFalse);
      expect(isValidKongjuEmail('student@gmail.com'), isFalse);
    });
  });

  group('validateEmail', () {
    test('비어 있으면 emailEmptyError', () {
      expect(validateEmail(null, l10n), 'emailEmptyError');
      expect(validateEmail('', l10n), 'emailEmptyError');
    });

    test('도메인이 다르면 emailDomainError', () {
      expect(validateEmail('student@gmail.com', l10n), 'emailDomainError');
    });

    test('학교 메일이면 null', () {
      expect(validateEmail('student@smail.kongju.ac.kr', l10n), isNull);
    });
  });

  group('validatePassword', () {
    test('비어 있으면 passwordEmptyError', () {
      expect(validatePassword(null, l10n), 'passwordEmptyError');
      expect(validatePassword('', l10n), 'passwordEmptyError');
    });

    test('6자 미만이면 passwordLengthError', () {
      expect(validatePassword('12345', l10n), 'passwordLengthError');
      expect(validatePassword('123456', l10n), isNull);
    });
  });

  group('validateNickname', () {
    test('비어 있으면 nicknameEmptyError', () {
      expect(validateNickname(null, l10n), 'nicknameEmptyError');
      expect(validateNickname('', l10n), 'nicknameEmptyError');
    });

    test('2자 미만이거나 10자 초과면 nicknameLengthError', () {
      expect(validateNickname('a', l10n), 'nicknameLengthError');
      expect(validateNickname('abcdefghijk', l10n), 'nicknameLengthError');
      expect(validateNickname('홍길동', l10n), isNull);
      expect(validateNickname('abcdefghij', l10n), isNull);
    });
  });
}
