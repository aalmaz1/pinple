# Pinple (Pin + People)

**Pinple**은 **국립공주대학교(KNU)** 학생들을 위해 개발된 전문가급 커뮤니티 애플리케이션입니다. 실시간 위치 정보와 고도의 지오펜싱 기술을 활용하여 캠퍼스 내에서 스터디, 운동, 맛집 탐방, 취미 활동 등 다양한 소모임을 쉽고 빠르게 조직하고 참여할 수 있도록 돕습니다.

## 📌 프로젝트 정체성
*   **타겟 대상:** 국립공주대학교 천안캠퍼스 재학생 및 휴학생.
*   **사용자 인증:** `@smail.kongju.ac.kr` 도메인 이메일 계정으로만 가입 및 이용 가능.
*   **브랜딩:** 공주대학교 공식 **UI(University Identity)** 컬러 및 아이콘 시스템을 완벽하게 통합.

## 🚀 고도화된 기술 스택
*   **Framework:** Flutter (3.x) - 최상의 안정성을 위해 **Skia 렌더링 엔진** 사용 (Impeller 최적화).
*   **State Management:** **Riverpod 3.0 (Notifier-based)** - 반응형이고 효율적인 데이터 흐름 제어.
*   **Backend:** Firebase (Auth, Firestore, Storage) - **Atomic Batch** 작업을 통한 데이터 무결성 보장.
*   **Maps:** Naver Maps SDK - **인스타그램 스타일의 탐색 모드(Explore Mode)** 구현.
*   **UI/UX:** 글래스모피즘(Glassmorphism), 스켈레톤 로딩(Skeleton Loading), 햅틱 피드백(Haptic Feedback) 적용.

## 🛠 주요 프리미엄 기능
1.  **인스타그램 스타일 탐색 모드:** 마커 클릭 시 하단에 카드 슬라이더가 등장하며, 카드를 넘길 때마다 지도가 부드럽게 해당 위치로 이동합니다.
2.  **몰입형 그룹 상세 페이지:** 지도가 포함된 확장형 시트, 투명한 글래스 스타일 버튼, 햅틱 반응을 통해 끊김 없는 사용자 경험을 제공합니다.
3.  **카드형 지도 핀(Pin):** 카테고리 아이콘과 KNU 공식 컬러를 결합한 커스텀 마커를 통해 클릭 없이도 활동 종류를 즉시 식별할 수 있습니다.
4.  **스마트 지오펜싱 (DMZ 대응):** 휴전선의 대각선 곡선을 고려한 정교한 경계 로직을 적용하여, 강원도 북부(인제, 속초 등) 지역은 지원하되 제한 구역 접근 시 "동무 경고" 기능을 제공합니다.
5.  **클린 코드 아키텍처:** 미사용 코드 제거, 저장소(Repository) 전수 조사, 3개 국어(한국어, 영어, 러시아어) 100% 로컬라이징 완료.

## 📉 최적화 및 성능
*   **WebP 이미지 포맷:** 화질 저하 없이 에셋 크기를 70% 이상 절감.
*   **R8 강력 압축:** 고급 Proguard 규칙을 적용하여 APK 용량 최소화.
*   **ABI 분할 빌드:** 프로세서 아키텍처별 최적화 빌드 지원 (arm64-v8a 기준 약 22MB).

## 🚦 시작하기
최적화된 릴리스 빌드를 생성하려면 다음 명령어를 실행하세요:
```bash
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols
```

## 🤖 자동화 (CI / Dependabot)
의존성 관리와 검증은 GitHub Actions + Dependabot 이 담당합니다. 별도 서버나 유료 도구가 필요 없습니다.

| 워크플로 | 실행 시점 | 하는 일 |
| --- | --- | --- |
| `CI` | `main` 대상 PR / `main` 푸시 | `flutter analyze` + `flutter test --coverage` |
| `Build (Android)` | 매주 월요일 03:00 (KST), 수동 실행 | debug APK 빌드 후 아티팩트 업로드 (툴체인/플러그인 호환성 확인용) |
| `Dependabot auto-merge` | Dependabot PR | patch 업데이트는 CI 통과 시 자동 병합, 나머지는 안내 코멘트 |

### 의존성 자동 업데이트
* `.github/dependabot.yml` 설정에 따라 **매주 월요일 09:00 (KST)** 에 `pubspec.yaml`, `android/*.gradle.kts`, GitHub Actions 업데이트 PR 이 생성됩니다.
* minor/patch 는 PR 하나로 묶고, major 는 개별 PR 로 만들어 직접 리뷰합니다.
* 방금 나온 버전을 바로 올리지 않도록 cooldown 을 둡니다 (patch 7일 / major 30일). 보안 업데이트는 cooldown 이 적용되지 않아 즉시 PR 이 생성됩니다.
* patch 업데이트 PR 은 필요한 검사(status check)가 통과하면 자동으로 squash 병합됩니다.

### 저장소에서 한 번만 켜면 되는 설정
1. **Settings → General → Pull requests → Allow auto-merge** 체크 → 자동 병합 활성화
2. **Settings → Code security → Dependabot alerts / Dependabot security updates** 활성화 → 취약점 알림 + 보안 업데이트 PR
3. **Settings → Branches → Add branch protection rule** (Branch name pattern: `main`)
   * `Require status checks to pass` → `Analyze & Test` 선택 (자동 병합이 검사를 기다리게 하는 장치입니다)
   * (권장) `Require a pull request before merging`
4. (선택) **Settings → Secrets and variables → Actions → New repository secret** 에 `GOOGLE_SERVICES_JSON` 추가
   * 값: `android/app/google-services.json` 파일 내용 그대로
   * 시크릿이 없으면 `Build (Android)` 워크플로는 경고만 남기고 빌드를 건너뜁니다.

### 로컬에서 같은 검사 실행하기
```bash
flutter pub get
flutter analyze
flutter test --coverage
flutter pub outdated          # 오래된 의존성 확인
flutter pub upgrade --major-versions   # 메이저까지 한 번에 올리기 (직접 실행 시)
```

## ⚠️ 법적 고지 (Legal Notice)
**본 프로젝트는 오픈 소스가 아닙니다.** 모든 권리는 저작권자에게 있습니다. 저작권자의 허가 없는 코드의 복제, 수정, 배포 및 포크(Fork)를 엄격히 금지합니다. 소스 코드는 오직 교육적 목적으로만 열람 가능합니다.

---
*Developed with pride for the KNU community.* 🚀🇰🇷🎓
