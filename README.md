# Pinple (핀플) - 공주대학교 천안캠퍼스 소모임 플랫폼

**Pinple**은 공주대학교 천안캠퍼스 학생들을 위한 위치 기반 소모임 매칭 서비스입니다. 캠퍼스 맵을 중심으로 실시간으로 모임을 찾고, 생성하고, 참여할 수 있습니다.

## 주요 기능

- **실시간 지도 기반 서비스**: 네이버 지도 API를 활용하여 캠퍼스 내 모임 위치를 한눈에 파악.
- **모임 관리**: 카테고리별 모임 생성, 참여 신청 및 자유로운 참여 취소(참여 포기) 기능.
- **다국어 지원**: 한국어, 영어, 러시아어의 3개 국어를 완벽하게 지원.
- **다크 모드 지원**: 사용자 설정에 따른 라이트/다크 모드 테마 적용.
- **사용자 프로필**: 닉네임 설정 및 프로필 사진 업로드/변경 기능 (Firebase Storage 연동).
- **보안 및 인증**: Firebase Auth를 통한 이메일 인증 기반의 안전한 회원가입.

## 기술 스택

- **Framework**: Flutter (Dart)
- **State Management**: Flutter Riverpod
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **Navigation**: GoRouter
- **Maps**: Flutter Naver Map
- **Local Storage**: SharedPreferences

## 최적화 및 빌드 (Optimization)

본 프로젝트는 최상의 성능과 최소한의 용량을 위해 다음과 같은 최적화가 적용되었습니다:
- **APK 용량 최적화**: ABI 분할 빌드를 통해 용량을 316MB(Debug)에서 **약 20MB(Release)**로 90% 이상 축소.
- **지도 성능 최적화**: "고정 중앙 조준점" 방식의 UI와 `onCameraIdle` 감지를 통해 지도 이동 시 렉(Lag)을 완벽히 제거.
- **리소스 최적화**: 불필요한 미디어 파일 및 디버г 리포트 제거를 통한 앱 경량화.

### 빌드 방법 (최적화된 Release APK)

가장 가볍고 빠른 APK를 생성하려면 터ми널에서 다음 명령어를 실행하세요:

```bash
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols --android-skip-build-dependency-validation
```

## 프로젝트 구조

```
lib/
├── core/               # 공통 테마, 상수, 로컬라이징, 위젯
├── features/
│   ├── auth/           # 로그인, 회원가입, 인증 로직
│   ├── map/            # 지도 표시, 마커, 모임 생성/상세/위치 선택
│   ├── profile/        # 내 정보, 프로필 수정
│   ├── settings/       # 테마 및 언어 설정
```
Legal Notice: This project is NOT open-source. All rights are reserved by the author. You may view the code for educational purposes, but you are not permitted to copy, modify, fork, or redistribute it.
