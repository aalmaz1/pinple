import 'package:pinple/core/constants/campus_constants.dart';
import 'package:pinple/core/localization/app_localizations.dart';

bool isValidKongjuEmail(String email) {
  return email.endsWith('@${CampusConstants.emailDomain}');
}

String? validateEmail(String? value, L10n l10n) {
  if (value == null || value.isEmpty) return l10n.emailEmptyError;
  if (!isValidKongjuEmail(value)) {
    return l10n.emailDomainError;
  }
  return null;
}

String? validatePassword(String? value, L10n l10n) {
  if (value == null || value.isEmpty) return l10n.passwordEmptyError;
  if (value.length < 6) return l10n.passwordLengthError;
  return null;
}

String? validateNickname(String? value, L10n l10n) {
  if (value == null || value.isEmpty) return l10n.nicknameEmptyError;
  if (value.length < 2 || value.length > 10) return l10n.nicknameLengthError;
  return null;
}
