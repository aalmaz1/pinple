import 'package:flutter_test/flutter_test.dart';
import 'package:pinple/core/utils/distance.dart';

void main() {
  group('formatDistance', () {
    test('1km 미만은 m 단위로 표시한다', () {
      expect(formatDistance(0), '0m');
      expect(formatDistance(150), '150m');
      expect(formatDistance(999), '999m');
    });

    test('1km 이상 10km 미만은 소수점 한 자리 km 로 표시한다', () {
      expect(formatDistance(1000), '1.0km');
      expect(formatDistance(5500), '5.5km');
    });

    test('10km 이상은 km 단위로 반올림한다', () {
      expect(formatDistance(12000), '12km');
      expect(formatDistance(12340), '12km');
    });

    test('음수는 빈 문자열을 돌려준다', () {
      expect(formatDistance(-1), '');
      expect(formatDistance(-1234.5), '');
    });
  });
}
