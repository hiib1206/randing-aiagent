---
name: update
description: >
  Updates an existing deployed HTML file with a new version from develop/.
  Use when user says "update", "업데이트", "업데이트해줘", "업뎃",
---

# Update

이미 배포된 HTML 파일(v번호)의 내용을 develop/에서 수정한 파일로 덮어쓴다.
v번호와 URL은 그대로 유지되고, 내용만 바뀐다.

## 배포 URL

`https://test.tunoinvest.com/v{번호}`

## 제약 조건

- **소스는 반드시 `develop/` 하위 경로여야 한다.**
- **대상은 반드시 `deploy/`에 존재하는 `v{번호}.html` 파일이어야 한다.**
- `deploy/`에 없는 v번호를 지정하면 "현재 배포되어 있지 않은 파일이에요"라고 안내하고 중단하라.
- `.html` 파일만 가능하다.

## 사용자는 비개발자다

- git, 커밋, 푸시, 브랜치 같은 기술 용어를 쓰지 마라.
- "업데이트 완료", "수정 반영 완료" 같이 쉬운 말을 써라.
- 에러가 나면 기술적 메시지를 그대로 보여주지 말고, 무엇이 문제인지 쉽게 설명하라.

## 실행 순서

아래 순서를 **정확히** 따르라. 중간에 실패하면 즉시 중단하고 무엇이 잘못됐는지 쉽게 설명하라.

### Step 0 — 정보 확인

- 대상 페이지(현재 배포된 페이지)를 안 알려줬으면 → "어떤 페이지를 업데이트할까요?" 하고 물어보라.
- 소스 파일(develop/ 안의 수정된 파일)을 안 알려줬으면:
  1. `git config user.name`으로 닉네임을 확인한다.
  2. `develop/{닉네임}/` 폴더에서 대상과 같은 이름의 파일(예: `v3.html`)을 찾는다.
  3. 찾으면 → 그 파일을 소스로 사용하고 바로 Step 1로 진행하라.
  4. 못 찾으면 → "v{번호}.html이 작업 폴더에 없어요. 먼저 deploy/에서 복사해서 수정해주세요." 하고 중단하라.
- 둘 다 알려줬으면 바로 Step 1로 진행하라.

### Step 1 — 대상 확인

- 사용자가 지정한 소스 파일이 `develop/` 하위에 있는지 확인하라.
- 소스 파일이 `.html`인지 확인하라.
- 대상 페이지 파일이 `deploy/`에 존재하는지 확인하라.

### Step 2 — 업데이트 확인 요청

AskUserQuestion 도구를 사용하여 실행 전에 사용자에게 확인을 받아라.

- question: "test2.html → v3.html (https://test.tunoinvest.com/v3) 업데이트할까요? URL은 그대로, 내용만 바뀌어요."
- options: "업데이트하기", "취소"

사용자가 "업데이트하기"를 선택하면 다음 단계로 진행하라. "취소"를 선택하면 중단하라.

### Step 3 — deploy/ 파일 덮어쓰기 + 타임스탬프 삽입

- 소스 파일의 내용으로 `deploy/v{번호}.html`을 덮어쓴다.
- 덮어쓴 파일의 `<head>` 태그 안에 아래 주석을 삽입한다 (배포 확인용):

```html
<!-- deploy-id: {ISO 8601 타임스탬프} -->
```

- 기존 `deploy-id` 주석이 있으면 새 타임스탬프로 교체한다.
- 원본(develop/)은 삭제하지 마라.

### Step 4 — 배포 실행

```bash
git pull origin main
git add -A
git commit -m "update: v{번호}

- 원본: {소스 파일 경로}"
git push origin main
```

- **push 전에 반드시 `git pull`을 먼저 실행하라.**
- push가 실패하면 "다른 사람이 먼저 업로드한 내용이 있어요. 다시 시도할게요"라고 안내하고, pull 후 다시 push를 시도하라.
- pull 과정에서 충돌(conflict)이 발생하면 "다른 사람의 작업과 겹치는 부분이 있어요. 개발팀에 문의해주세요."라고 안내하고 중단하라.

### Step 5 — 배포 반영 확인

push 완료 후 실제 URL에 새 버전이 반영되었는지 확인한다.

```bash
bash .claude/scripts/check-site.sh "https://test.tunoinvest.com/v{번호}" "deploy-id: {삽입한 타임스탬프}"
```

### Step 6 — 결과 보고

업데이트된 파일, 성공/실패, 접속 URL을 명확히 보고하라.

## Example

**Input:**

```
/update v3 develop/jeycorp1216/test2.html
```

**확인 단계:**

```
아래 파일을 업데이트할까요?

test2.html → v3.html (https://test.tunoinvest.com/v3)

URL은 그대로 유지되고, 내용만 바뀌어요.
```

**결과 (성공):**

```
업데이트 완료! ✅

- v3.html 내용이 수정되었어요
- 확인: https://test.tunoinvest.com/v3

사이트에 정상 반영되었어요!
```

**결과 (타임아웃):**

```
파일은 수정했지만, 사이트 반영이 아직 안 된 것 같아요 ⚠️

- v3.html 내용 수정됨

잠시 후 아래 주소에서 직접 확인해보세요:
https://test.tunoinvest.com/v3

그래도 이전 내용이 보인다면 개발팀에 문의해주세요.
```
