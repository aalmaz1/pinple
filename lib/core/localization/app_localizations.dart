import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinple/features/settings/providers/settings_provider.dart';

class L10n {
  final Map<String, String> _strings;

  L10n(this._strings);

  String get(String key) => _strings[key] ?? key;

  // Common strings
  String get appTitle => get('appTitle');
  String get settings => get('settings');
  String get profile => get('profile');
  String get map => get('map');
  String get groupList => get('groupList');
  String get logout => get('logout');
  String get language => get('language');
  String get theme => get('theme');
  String get light => get('light');
  String get dark => get('dark');
  String get system => get('system');
  String get myGroups => get('myGroups');
  String get createGroup => get('createGroup');
  String get editGroup => get('editGroup');
  String get themeSettings => get('themeSettings');
  String get languageSettings => get('languageSettings');
  String get distanceSortHint => get('distanceSortHint');
  String get errorLoadingGroups => get('errorLoadingGroups');
  String get noGroupsYet => get('noGroupsYet');
  String get infoLoadError => get('infoLoadError');
  String get noJoinedGroups => get('noJoinedGroups');
  String get joinHint => get('joinHint');
  String get createdBy => get('createdBy');
  String get introduction => get('introduction');
  String get optional => get('optional');

  // Group creation strings
  String get groupTitle => get('groupTitle');
  String get groupDescription => get('groupDescription');
  String get locationName => get('locationName');
  String get selectLocation => get('selectLocation');
  String get category => get('category');
  String get maxMembers => get('maxMembers');
  String get submit => get('submit');
  String get update => get('update');
  String get pickLocationOnMap => get('pickLocationOnMap');

  // Categories
  String get catStudy => get('catStudy');
  String get catExercise => get('catExercise');
  String get catMeal => get('catMeal');
  String get catHobby => get('catHobby');
  String get catOther => get('catOther');

  // Auth & Profile
  String get loginSubtitle => get('loginSubtitle');
  String get emailLabel => get('emailLabel');
  String get passwordLabel => get('passwordLabel');
  String get loginButton => get('loginButton');
  String get noAccountLink => get('noAccountLink');
  String get signupTitle => get('signupTitle');
  String get signupWelcome => get('signupWelcome');
  String get signupSubtitle => get('signupSubtitle');
  String get nicknameLabel => get('nicknameLabel');
  String get confirmPasswordLabel => get('confirmPasswordLabel');
  String get passwordMismatch => get('passwordMismatch');
  String get verifyEmailTitle => get('verifyEmailTitle');
  String get verifyEmailSubtitle => get('verifyEmailSubtitle');
  String get checkVerifyButton => get('checkVerifyButton');
  String get resendEmailButton => get('resendEmailButton');
  String get loginOtherAccount => get('loginOtherAccount');
  String get notVerifiedError => get('notVerifiedError');
  String get resentSuccess => get('resentSuccess');
  String get profileUpdated => get('profileUpdated');
  String get uploadFailed => get('uploadFailed');
  String get error => get('error');
  String get showDetails => get('showDetails');

  // Validators
  String get emailEmptyError => get('emailEmptyError');
  String get emailDomainError => get('emailDomainError');
  String get passwordEmptyError => get('passwordEmptyError');
  String get passwordLengthError => get('passwordLengthError');
  String get nicknameEmptyError => get('nicknameEmptyError');
  String get nicknameLengthError => get('nicknameLengthError');

  // Map Picker
  String get selectLocationTitle => get('selectLocationTitle');
  String get outOfBoundsError => get('outOfBoundsError');
  String get done => get('done');
  String get dragMapHint => get('dragMapHint');

  // Location Blocked
  String get locationBlockedTitle => get('locationBlockedTitle');
  String get locationBlockedSubtitle => get('locationBlockedSubtitle');
  String get locationErrorTitle => get('locationErrorTitle');
  String get retry => get('retry');
  String get retryButton => get('retryButton');

  // New actions
  String get leaveGroup => get('leaveGroup');
  String get leaveConfirmTitle => get('leaveConfirmTitle');
  String get leaveConfirmMessage => get('leaveConfirmMessage');
  String get cancel => get('cancel');
  String get confirm => get('confirm');
  String get joining => get('joining');
  String get joinRequestSent => get('joinRequestSent');
  String get joined => get('joined');
  String get fullMembers => get('fullMembers');
  String get deleteGroup => get('deleteGroup');
  String get deleteConfirmTitle => get('deleteConfirmTitle');
  String get deleteConfirmMessage => get('deleteConfirmMessage');
}

final l10nProvider = Provider<L10n>((ref) {
  final locale = ref.watch(settingsProvider.select((s) => s.locale));

  switch (locale.languageCode) {
    case 'en':
      return L10n(_en);
    case 'ru':
      return L10n(_ru);
    case 'ko':
    default:
      return L10n(_ko);
  }
});

const _ko = {
  'appTitle': 'Pinple',
  'settings': '설정',
  'profile': '내 정보',
  'map': '지도',
  'groupList': '주변 모임',
  'logout': '로그아웃',
  'language': '언어',
  'theme': '테마',
  'light': '라이트',
  'dark': '다크',
  'system': '시스템',
  'myGroups': '내 모임',
  'createGroup': '모임 만들기',
  'editGroup': '모임 수정',
  'themeSettings': '테마 설정',
  'languageSettings': '언어 설정',
  'distanceSortHint': '가까운 순서로 보여드려요',
  'errorLoadingGroups': '모임을 불러올 수 없어요',
  'noGroupsYet': '아직 열린 모임이 없어요',
  'infoLoadError': '정보를 불러올 수 없습니다',
  'noJoinedGroups': '참여 중인 모임이 없어요',
  'joinHint': '주변 모임 탭에서 마음에 드는 모임에 참여해보세요',
  'createdBy': '만든 사람',
  'introduction': '소개',
  'optional': '선택',
  'groupTitle': '모임 이름',
  'groupDescription': '모임 설명',
  'locationName': '장소 이름',
  'selectLocation': '모임 장소를 선택해주세요',
  'category': '카테고리',
  'maxMembers': '최대 인원',
  'submit': '생성하기',
  'update': '수정하기',
  'pickLocationOnMap': '지도에서 장소 선택',
  'catStudy': '공부',
  'catExercise': '운동',
  'catMeal': '밥약',
  'catHobby': '취미',
  'catOther': '기타',
  'loginSubtitle': '학생들의 소모임 공간',
  'emailLabel': '학교 이메일',
  'passwordLabel': '비밀번호',
  'loginButton': '로그인',
  'noAccountLink': '계정이 없으신가요? 회원가입',
  'signupTitle': '회원가입',
  'signupWelcome': '환영해요',
  'signupSubtitle': '학교 이메일로 가입하면\n주변 모임을 바로 볼 수 있어요',
  'nicknameLabel': '닉네임',
  'confirmPasswordLabel': '비밀번호 확인',
  'passwordMismatch': '비밀번호가 일치하지 않습니다',
  'verifyEmailTitle': '이메일을 확인해주세요',
  'verifyEmailSubtitle': '학교 이메일로 인증 메일을 보냈습니다.\n메일함을 확인해주세요.',
  'checkVerifyButton': '인증 완료 확인',
  'resendEmailButton': '인증 메일 다시 보내기',
  'loginOtherAccount': '다른 계정으로 로그인',
  'notVerifiedError': '아직 인증이 완료되지 않았습니다',
  'resentSuccess': '인증 메일을 다시 보냈습니다',
  'profileUpdated': '프로필 사진이 업데이트되었습니다',
  'uploadFailed': '업로드 실패',
  'error': '오류',
  'showDetails': '자세히 보기',
  'emailEmptyError': '이메일을 입력해주세요',
  'emailDomainError': '공주대 이메일 형식만 사용 가능합니다',
  'passwordEmptyError': '비밀번호를 입력해주세요',
  'passwordLengthError': '비밀번호는 6자 이상이어야 합니다',
  'nicknameEmptyError': '닉네임을 입력해주세요',
  'nicknameLengthError': '닉네임은 2~10자여야 합니다',
  'selectLocationTitle': '장소 선택',
  'outOfBoundsError': '어디 가너 동무?! 대한민국으로 돌아와야지!',
  'done': '완료',
  'dragMapHint': '지도를 움직여 장소를 선택해주세요',
  'locationBlockedTitle': '캠퍼스 근처에서만 사용할 수 있어요',
  'locationBlockedSubtitle': '캠퍼스 반경 내에서 이용해주세요',
  'locationErrorTitle': '위치를 확인할 수 없어요',
  'retry': '다시 시도',
  'retryButton': '다시 확인',
  'leaveGroup': '참여포기',
  'leaveConfirmTitle': '참여 포기',
  'leaveConfirmMessage': '정말 이 모임 참여를 포기하시겠습니까?',
  'cancel': '취소',
  'confirm': '확인',
  'joining': '참여 신청',
  'joinRequestSent': '참여 신청을 보냈습니다',
  'joined': '참여 중',
  'fullMembers': '인원이 가득 찼습니다',
  'deleteGroup': '삭제',
  'deleteConfirmTitle': '모임 삭제',
  'deleteConfirmMessage': '정말 이 모임을 삭제하시겠습니까?',
};

const _en = {
  'appTitle': 'Pinple',
  'settings': 'Settings',
  'profile': 'Profile',
  'map': 'Map',
  'groupList': 'Nearby Groups',
  'logout': 'Logout',
  'language': 'Language',
  'theme': 'Theme',
  'light': 'Light',
  'dark': 'Dark',
  'system': 'System',
  'myGroups': 'My Groups',
  'createGroup': 'Create Group',
  'editGroup': 'Edit Group',
  'themeSettings': 'Theme Settings',
  'languageSettings': 'Language Settings',
  'distanceSortHint': 'Showing by distance',
  'errorLoadingGroups': 'Error loading groups',
  'noGroupsYet': 'No groups yet',
  'infoLoadError': 'Error loading info',
  'noJoinedGroups': 'No joined groups',
  'joinHint': 'Join a group near you from the list',
  'createdBy': 'Created by',
  'introduction': 'Introduction',
  'optional': 'Optional',
  'groupTitle': 'Group Name',
  'groupDescription': 'Description',
  'locationName': 'Location Name',
  'selectLocation': 'Please select a location',
  'category': 'Category',
  'maxMembers': 'Max Members',
  'submit': 'Create',
  'update': 'Update',
  'pickLocationOnMap': 'Select on Map',
  'catStudy': 'Study',
  'catExercise': 'Exercise',
  'catMeal': 'Meal',
  'catHobby': 'Hobby',
  'catOther': 'Other',
  'loginSubtitle': 'Community space for students',
  'emailLabel': 'School Email',
  'passwordLabel': 'Password',
  'loginButton': 'Login',
  'noAccountLink': 'Don\'t have an account? Sign up',
  'signupTitle': 'Sign Up',
  'signupWelcome': 'Welcome',
  'signupSubtitle':
      'Join with your school email to\nsee nearby groups right away',
  'nicknameLabel': 'Nickname',
  'confirmPasswordLabel': 'Confirm Password',
  'passwordMismatch': 'Passwords do not match',
  'verifyEmailTitle': 'Please verify your email',
  'verifyEmailSubtitle':
      'We sent a verification email to your school email.\nPlease check your inbox.',
  'checkVerifyButton': 'Check Verification',
  'resendEmailButton': 'Resend Email',
  'loginOtherAccount': 'Login with another account',
  'notVerifiedError': 'Verification is not yet complete',
  'resentSuccess': 'Verification email resent',
  'profileUpdated': 'Profile photo updated',
  'uploadFailed': 'Upload failed',
  'error': 'Error',
  'showDetails': 'Show Details',
  'emailEmptyError': 'Please enter email',
  'emailDomainError': 'Only Kongju email is allowed',
  'passwordEmptyError': 'Please enter password',
  'passwordLengthError': 'Password must be at least 6 characters',
  'nicknameEmptyError': 'Please enter nickname',
  'nicknameLengthError': 'Nickname must be 2-10 characters',
  'selectLocationTitle': 'Select Location',
  'outOfBoundsError': 'Location must be within South Korea',
  'done': 'Done',
  'dragMapHint': 'Drag the map to select a location',
  'locationBlockedTitle': 'Only available near campus',
  'locationBlockedSubtitle': 'Please use within the campus radius',
  'locationErrorTitle': 'Unable to verify location',
  'retry': 'Retry',
  'retryButton': 'Check Again',
  'leaveGroup': 'Leave Group',
  'leaveConfirmTitle': 'Leave Group',
  'leaveConfirmMessage': 'Are you sure you want to leave this group?',
  'cancel': 'Cancel',
  'confirm': 'Confirm',
  'joining': 'Join Request',
  'joinRequestSent': 'Join request sent',
  'joined': 'Joined',
  'fullMembers': 'Group is full',
  'deleteGroup': 'Delete',
  'deleteConfirmTitle': 'Delete Group',
  'deleteConfirmMessage': 'Are you sure you want to delete this group?',
};

const _ru = {
  'appTitle': 'Pinple',
  'settings': 'Настройки',
  'profile': 'Мой профиль',
  'map': 'Карта',
  'groupList': 'Список встреч',
  'logout': 'Выйти',
  'language': 'Язык',
  'theme': 'Тема',
  'light': 'Светлая',
  'dark': 'Темная',
  'system': 'Системная',
  'myGroups': 'Мои встречи',
  'createGroup': 'Создать встречу',
  'editGroup': 'Редактировать',
  'themeSettings': 'Настройки темы',
  'languageSettings': 'Настройки языка',
  'distanceSortHint': 'Сначала ближайшие',
  'errorLoadingGroups': 'Не удалось загрузить встречи',
  'noGroupsYet': 'Пока встреч нет',
  'infoLoadError': 'Ошибка загрузки профиля',
  'noJoinedGroups': 'Вы еще не вступили ни в одну компанию',
  'joinHint': 'Найдите интересную компанию поблизости',
  'createdBy': 'Создатель',
  'introduction': 'Описание',
  'optional': 'Необязательно',
  'groupTitle': 'Название встречи',
  'groupDescription': 'Описание',
  'locationName': 'Место встречи',
  'selectLocation': 'Выберите место встречи',
  'category': 'Категория',
  'maxMembers': 'Макс. участников',
  'submit': 'Создать',
  'update': 'Обновить',
  'pickLocationOnMap': 'Выбрать на карте',
  'catStudy': 'Учеба',
  'catExercise': 'Спорт',
  'catMeal': 'Поесть вместе',
  'catHobby': 'Хобби',
  'catOther': 'Другое',
  'loginSubtitle': 'Пространство для встреч студентов',
  'emailLabel': 'Университетская почта',
  'passwordLabel': 'Пароль',
  'loginButton': 'Войти',
  'noAccountLink': 'Нет аккаунта? Зарегистрироваться',
  'signupTitle': 'Регистрация',
  'signupWelcome': 'Добро пожаловать',
  'signupSubtitle':
      'Зарегистрируйтесь через почту вуза,\nчтобы сразу видеть встречи рядом',
  'nicknameLabel': 'Никнейм',
  'confirmPasswordLabel': 'Подтверждение пароля',
  'passwordMismatch': 'Пароли не совпадают',
  'verifyEmailTitle': 'Подтвердите почту',
  'verifyEmailSubtitle':
      'Мы отправили письмо на вашу почту.\nПожалуйста, проверьте входящие.',
  'checkVerifyButton': 'Проверить подтверждение',
  'resendEmailButton': 'Отправить письмо еще раз',
  'loginOtherAccount': 'Войти в другой аккаунт',
  'notVerifiedError': 'Подтверждение еще не завершено',
  'resentSuccess': 'Письмо отправлено повторно',
  'profileUpdated': 'Фото профиля обновлено',
  'uploadFailed': 'Ошибка загрузки',
  'error': 'Ошибка',
  'showDetails': 'Подробнее',
  'emailEmptyError': 'Введите почту',
  'emailDomainError': 'Разрешена только почта вуза',
  'passwordEmptyError': 'Введите пароль',
  'passwordLengthError': 'Пароль должен быть не менее 6 символов',
  'nicknameEmptyError': 'Введите никнейм',
  'nicknameLengthError': 'Никнейм должен быть от 2 до 10 символов',
  'selectLocationTitle': 'Выберите место',
  'outOfBoundsError': 'Место должно быть на территории Южной Кореи',
  'done': 'Готово',
  'dragMapHint': 'Передвиньте карту, чтобы выбрать место',
  'locationBlockedTitle': 'Доступно только рядом с кампусом',
  'locationBlockedSubtitle':
      'Пожалуйста, используйте приложение в радиусе кампуса',
  'locationErrorTitle': 'Не удалось определить местоположение',
  'retry': 'Повторить',
  'retryButton': 'Проверить снова',
  'leaveGroup': 'Отменить участие',
  'leaveConfirmTitle': 'Отказ от участия',
  'leaveConfirmMessage': 'Вы уверены, что хотите отменить свое участие?',
  'cancel': 'Отмена',
  'confirm': 'Подтвердить',
  'joining': 'Участвовать',
  'joinRequestSent': 'Заявка отправлена',
  'joined': 'Вы участвуете',
  'fullMembers': 'Группа заполнена',
  'deleteGroup': 'Удалить',
  'deleteConfirmTitle': 'Удалить встречу',
  'deleteConfirmMessage': 'Вы уверены, что хотите удалить эту встречу?',
};
