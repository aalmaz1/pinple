# CI 워크플로 설치하기

이 폴더의 파일들은 GitHub Actions 워크플로입니다.
자동화 도구(Arena GitHub App)에는 `workflows` 권한이 없어서 `.github/workflows/` 로 직접 푸시할 수 없습니다.
아래 둘 중 한 가지 방법으로 활성화하세요.

## 방법 1. 로컬에서 옮기기 (권장)

```bash
mkdir -p .github/workflows
git mv docs/ci/ci.yml                   .github/workflows/ci.yml
git mv docs/ci/build-android.yml        .github/workflows/build-android.yml
git mv docs/ci/dependabot-auto-merge.yml .github/workflows/dependabot-auto-merge.yml
git rm -r --cached docs/ci 2>/dev/null; rm -rf docs/ci
git commit -m "ci: activate workflows"
git push
```

## 방법 2. GitHub 웹에서 만들기

1. 저장소 → **Add file → Create new file**
2. 파일 이름에 `.github/workflows/ci.yml` 입력
3. `docs/ci/ci.yml` 내용을 복사해 붙여넣고 **Commit changes**
4. 나머지 두 파일도 같은 방식으로 추가

## 파일 설명

| 파일 | 역할 |
| --- | --- |
| `ci.yml` | PR / `main` 푸시 시 `flutter analyze` + `flutter test --coverage` |
| `build-android.yml` | 주 1회 / 수동 실행으로 debug APK 빌드 검증 |
| `dependabot-auto-merge.yml` | Dependabot 의 patch 업데이트를 검사 통과 후 자동 병합 |

`.github/dependabot.yml` 은 일반 설정 파일이라 이미 적용되어 있습니다. (별도 설치 불필요)

설치 후 저장소 설정에서 한 번만 켜면 되는 항목은 README 의 **🤖 자동화 (CI / Dependabot)** 항목을 참고하세요.
