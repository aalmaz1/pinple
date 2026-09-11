import 'package:flutter/material.dart';
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
  String get nickname => get('nickname');
  String get email => get('email');
  String get themeSettings => get('themeSettings');
  String get languageSettings => get('languageSettings');
  String get distanceSortHint => get('distanceSortHint');
  String get errorLoadingGroups => get('errorLoadingGroups');
  String get noGroupsYet => get('noGroupsYet');
  String get infoLoadError => get('infoLoadError');
  String get noJoinedGroups => get('noJoinedGroups');
  String get joinHint => get('joinHint');
  String get pickPhoto => get('pickPhoto');

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
  'nickname': '닉네임',
  'email': '이메일',
  'themeSettings': '테마 설정',
  'languageSettings': '언어 설정',
  'distanceSortHint': '가까운 순서로 보여드려요',
  'errorLoadingGroups': '모임을 불러올 수 없어요',
  'noGroupsYet': '아직 열린 모임이 없어요',
  'infoLoadError': '정보를 불러올 수 없습니다',
  'noJoinedGroups': '참여 중인 모임이 없어요',
  'joinHint': '주변 모임 탭에서 마음에 드는 모임에 참여해보세요',
  'pickPhoto': '사진 선택',
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
  'nickname': 'Nickname',
  'email': 'Email',
  'themeSettings': 'Theme Settings',
  'languageSettings': 'Language Settings',
  'distanceSortHint': 'Showing by distance',
  'errorLoadingGroups': 'Error loading groups',
  'noGroupsYet': 'No groups yet',
  'infoLoadError': 'Error loading info',
  'noJoinedGroups': 'No joined groups',
  'joinHint': 'Join a group near you from the list',
  'pickPhoto': 'Pick Photo',
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
  'nickname': 'Никнейм',
  'email': 'Электронная почта',
  'themeSettings': 'Настройки темы',
  'languageSettings': 'Настройки языка',
  'distanceSortHint': 'Сначала ближайшие',
  'errorLoadingGroups': 'Не удалось загрузить встречи',
  'noGroupsYet': 'Пока встреч нет',
  'infoLoadError': 'Ошибка загрузки профиля',
  'noJoinedGroups': 'Вы еще не вступили ни в одну компанию',
  'joinHint': 'Найдите интересную компанию поблизости',
  'pickPhoto': 'Выбрать фото',
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
