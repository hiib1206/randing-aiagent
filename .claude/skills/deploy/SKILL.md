---
name: deploy
description: >
  Copies HTML files from develop/ to deploy/ and publishes automatically.
  Use when user says "deploy", "배포", "배포해줘", "deploy this", "배포하고 싶어".
---

# Deploy

`develop/` 하위의 HTML 파일을 `deploy/` 루트로 v번호를 붙여 복사하고 자동으로 배포(git push)한다.
배포 후 실제 URL에 반영되었는지까지 확인한다.

## 배포 URL

`https://test.tunoinvest.com/v{번호}`

예: `develop/jeycorp1216/test2.html` → `deploy/v1.html` → `https://test.tunoinvest.com/v1`

`deploy/` 폴더가 곧 사이트 루트다. 폴더 구조 없이 HTML 파일이 바로 `deploy/`에 들어간다.

## 제약 조건

- **소스는 반드시 `develop/` 하위 경로여야 한다.** develop/ 밖의 파일을 지정하면 "develop/ 폴더 안의 파일만 배포할 수 있어요"라고 안내하고 중단하라.
- **HTML 파일(.html)만 배포 대상이다.** 폴더를 지정한 경우, 그 안의 `.html` 파일만 복사하라. HTML이 아닌 파일은 무시하고 무시된 파일 목록을 알려줘라.
- HTML 파일이 하나도 없으면 "배포할 HTML 파일이 없어요"라고 안내하고 중단하라.

## 사용자는 비개발자다

- git, 커밋, 푸시, 브랜치 같은 기술 용어를 쓰지 마라.
- "배포 완료", "업로드 완료" 같이 쉬운 말을 써라.
- 에러가 나면 기술적 메시지를 그대로 보여주지 말고, 무엇이 문제인지 쉽게 설명하라.

## 실행 순서

아래 순서를 **정확히** 따르라. 중간에 실패하면 즉시 중단하고 무엇이 잘못됐는지 쉽게 설명하라.

### Step 1 — 대상 확인

- 사용자가 지정한 경로가 `develop/` 하위인지 확인하라.
- 경로가 존재하는지 확인하라.
- 해당 경로(파일 또는 폴더)에 `.html` 파일이 있는지 확인하라.

### Step 2 — v번호 계산

- `deploy/`와 `archive/` 두 폴더를 스캔하여 현재 사용된 v번호의 최대값을 구한다.
  - `deploy/`에서: `v{N}.html` 형식의 파일에서 N을 추출한다.
  - `archive/`에서: `v{N}.html` 형식의 파일에서 N을 추출한다.
  - 두 폴더 모두 v번호 파일이 없으면 최대값은 `0`이다.
- 최대값 + 1부터 배포할 파일 수만큼 번호를 부여한다.
  - 예: 최대값이 `3`이고 파일이 2개면 → v4, v5가 부여될 예정.
- **이 단계에서는 파일 복사를 하지 않는다.** 번호 계산만 한다.

### Step 3 — 배포 확인 요청

AskUserQuestion 도구를 사용하여 사용자에게 확인을 받아라.

- question: 배포할 파일 목록을 보여주고 확인을 요청한다.
  - 파일이 1개면: "test2.html → v1.html (https://test.tunoinvest.com/v1) 배포할까요?"
  - 파일이 여러 개면: "아래 파일을 배포할까요?\n1. test2.html → v1.html\n2. test3.html → v2.html"
- options: "배포하기", "취소"

사용자가 "배포하기"를 선택하면 다음 단계로 진행하라. "취소"를 선택하면 중단하라.

### Step 4 — v번호로 HTML 복사 + 타임스탬프 삽입

- 배포할 HTML 파일 **각각에 대해** 순서대로:
  1. 해당 파일을 `deploy/v{번호}.html`로 복사한다.
  2. 복사한 파일의 `<head>` 태그 안에 아래 주석을 삽입한다 (배포 확인용):

```html
<!-- deploy-id: {ISO 8601 타임스탬프} -->
```

예: `<!-- deploy-id: 2026-03-23T11:05:30Z -->`

이 주석은 브라우저에 보이지 않으며, Step 6에서 배포 확인에 사용된다.

- 원본은 삭제하지 마라.

### Step 5 — 배포 실행

```bash
git pull origin main
git add -A
git commit -m "deploy: <파일 1개면 v번호, 여러 개면 'v번호, v번호'>

- 원본파일명 → v번호.html
- 원본파일명 → v번호.html
..."
git push origin main
```

- 프로젝트 전체(develop/, deploy/, archive/ 등)를 함께 push한다. 배포 시 여러 폴더가 동시에 변경될 수 있기 때문이다.
- **push 전에 반드시 `git pull`을 먼저 실행하라.** 다른 사람이 먼저 push했을 수 있다.
- push가 실패하면 "다른 사람이 먼저 업로드한 내용이 있어요. 다시 시도할게요"라고 안내하고, pull 후 다시 push를 시도하라.
- pull 과정에서 충돌(conflict)이 발생하면 사용자에게 "다른 사람의 작업과 겹치는 부분이 있어요. 개발팀에 문의해주세요."라고 안내하고 중단하라.

### Step 6 — 배포 반영 확인

push 완료 후 실제 URL에 새 버전이 반영되었는지 확인한다.
파일이 여러 개면 첫 번째 파일만 확인하면 된다.

```bash
bash .claude/scripts/check-site.sh "https://test.tunoinvest.com/v{번호}" "deploy-id: {삽입한 타임스탬프}"
```

- `SUCCESS` 출력 → 성공. "사이트에 정상 반영되었어요!"
- `RETRY` 출력 → "아직 반영이 안 됐어요. 30초 후에 다시 확인해볼게요"라고 안내한다. (스크립트가 자동으로 재시도한다)
- `FAIL` 출력 → "배포에 문제가 생긴 것 같아요. 개발팀에 문의해주세요."라고 안내한다.

### Step 7 — 결과 보고

배포된 파일 목록, 성공/실패, 접속 URL을 명확히 보고하라.

## Example

**Input:**

```
/deploy develop/jeycorp1216
```

**확인 단계:**

```
아래 파일을 배포할까요?

1. test2.html → v1.html → https://test.tunoinvest.com/v1

총 1개 파일
```

**결과 (성공):**

```
배포 완료! ✅

배포된 파일:
- test2.html → v1.html → https://test.tunoinvest.com/v1

사이트에 정상 반영되었어요!
```

**결과 (여러 파일):**

```
배포 완료! ✅

배포된 파일:
- test2.html → v4.html → https://test.tunoinvest.com/v4
- test3.html → v5.html → https://test.tunoinvest.com/v5
- about.html → v6.html → https://test.tunoinvest.com/v6

3개 파일이 사이트에 정상 반영되었어요!
```

**결과 (타임아웃):**

```
파일은 업로드했지만, 사이트 반영이 아직 안 된 것 같아요 ⚠️

배포된 파일:
- test2.html → v1.html

잠시 후 아래 주소에서 직접 확인해보세요:
https://test.tunoinvest.com/v1

그래도 페이지가 보이지 않는다면 개발팀에 문의해주세요.
```
