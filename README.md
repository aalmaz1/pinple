# Pinple (핀플) - 공주대학교 천안캠퍼스 소모임 플랫폼

**Pinple**은 공주대학교 천안캠퍼스 학생들을 위한 위치 기반 소모임 매칭 서비스입니다. 캠퍼스 맵을 중심으로 실시간으로 모임을 찾고, 생성하고, 참여할 수 있습니다.

## 🚀 주요 기능

- **실시간 지도 기반 서비스**: 네이버 지도 API를 활용하여 캠퍼스 내 모임 위치를 한눈에 파악.
- **모임 관리**: 스터디, 운동, 맛집 탐방 등 카테고리별 모임 생성 및 참여 관리.
- **다국어 지원**: 한국어, 영어, 러시아어의 3개 국어를 완벽하게 지원.
- **다크 모드 지원**: 사용자 설정에 따른 라이트/다크 모드 테마 적용.
- **사용자 프로필**: 닉네임 설정 및 프로필 사진 업로드/변경 기능 (Firebase Storage 연동).
- **보안 및 인증**: Firebase Auth를 통한 이메일 인증 기반의 안전한 회원가입.

## 🛠 기술 스택

- **Framework**: Flutter (Dart)
- **State Management**: Flutter Riverpod
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **Navigation**: GoRouter
- **Maps**: Flutter Naver Map
- **Local Storage**: SharedPreferences

## 📦 최적화 및 빌드 (Optimization)

본 프로젝트는 배포를 위해 다음과 같은 최적화가 적용되었습니다:
- **APK 용량 최적화**: 디버그 모드(134MB) 대비 60% 이상 축소 (약 45MB).
- **성능 최적화**: `RepaintBoundary`를 사용한 지도 렌더링 효율화 및 R8(Full Mode) 코드 난독화/압축 적용.
- **리소스 관리**: 불필요한 아이콘 및 로그 제거를 통한 런타임 성능 향상.

### 빌드 방법 (Release APK)

가장 최적화된 APK를 생성하려면 터미널에서 다음 명령어를 실행하세요:

```bash
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols --android-skip-build-dependency-validation
```

## 📂 프로젝트 구조

```
lib/
├── core/               # 공통 테마, 상수, 로컬라이징, 위젯
├── features/
│   ├── auth/           # 로그인, 회원가입, 인증 로직
│   ├── map/            # 지도 표시, 마커, 모임 생성 및 상세
│   ├── profile/        # 내 정보, 프로필 수정
│   ├── settings/       # 테마 및 언어 설정
│   └── shell/          # 앱의 기본 레이아웃 및 내비게이션
└── main.dart           # 앱 진입점 및 초기화
```

## 📝 라이선스

이 프로젝트는 공주대학교 학생들을 위한 비상업적 목적으로 개발되었습니다.

---