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
};

const _ru = {
  'appTitle': 'Pinple',
  'settings': 'Настройки',
  'profile': 'Мой профиль',
  'map': 'Карта',
  'groupList': 'Группы рядом',
  'logout': 'Выйти',
  'language': 'Язык',
  'theme': 'Тема',
  'light': 'Светлая',
  'dark': 'Темная',
  'system': 'Системная',
  'myGroups': 'Мои группы',
  'createGroup': 'Создать группу',
  'editGroup': 'Редактировать группу',
  'nickname': 'Никнейм',
  'email': 'Электронная почта',
  'themeSettings': 'Настройки темы',
  'languageSettings': 'Настройки языка',
  'distanceSortHint': 'Сортировка по расстоянию',
  'errorLoadingGroups': 'Ошибка загрузки групп',
  'noGroupsYet': 'Групп пока нет',
  'infoLoadError': 'Ошибка загрузки профиля',
  'noJoinedGroups': 'Вы пока не вступили в группы',
  'joinHint': 'Найдите интересную группу на вкладке рядом',
  'pickPhoto': 'Выбрать фото',
  'groupTitle': 'Название группы',
  'groupDescription': 'Описание',
  'locationName': 'Название места',
  'selectLocation': 'Пожалуйста, выберите место',
  'category': 'Категория',
  'maxMembers': 'Макс. участников',
  'submit': 'Создать',
  'update': 'Обновить',
  'pickLocationOnMap': 'Выбрать на карте',
};
