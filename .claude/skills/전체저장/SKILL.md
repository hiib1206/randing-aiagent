---
name: 전체저장
description: >
  Detects all file changes (deploy/archive/develop) and pushes them with proper commit conventions.
disable-model-invocation: true
---

# 전체저장

프로젝트의 모든 변경사항을 자동 감지하고, 종류별로 분류하여 저장한다.
사용자가 Finder/IDE에서 직접 파일을 이동/복사/삭제한 뒤 이 스킬을 실행하면 된다.

## 배포 URL

`https://test.tunoinvest.com/{파일명}`

## 핵심 원칙

- 변경사항을 경로 기반으로 자동 분류한다.
- 종류별로 커밋을 분리한다. (`.claude/conventions.md` 참조)
- deploy/ 변경이 있으면 deploy-id 삽입 + 사이트 반영 확인까지 수행한다.

## 실행 순서

아래 순서를 **정확히** 따르라. 중간에 실패하면 즉시 중단하고 무엇이 잘못됐는지 쉽게 설명하라.

### Step 1 — 변경사항 감지 + 분류

`git status`로 변경된 파일 목록을 파악하고, 경로 기반으로 자동 분류한다.

| 감지 패턴 | 분류 |
|-----------|------|
| deploy/에 새 파일 추가 | `deploy: 신규` |
| deploy/ 파일 수정 | `deploy: 업데이트` |
| deploy/ 파일 삭제 + archive/에 같은 파일명 추가 | `archive: 보관` |
| deploy/ 파일 삭제 (archive에 없음) | `deploy: 삭제` |
| archive/ 파일 삭제 + deploy/에 같은 파일명 추가 | `deploy: 보관해제` |
| archive/ 파일 삭제 (deploy에 없음) | `archive: 삭제` |
| develop/, guideline/ 등 변경 | `save: 추가/수정/삭제` |

- 변경사항이 하나도 없으면 "변경된 파일이 없어요"라고 안내하고 중단하라.

### Step 2 — 파일명 유니크 검사

deploy/에 새로 추가된 파일이 있으면 archive/에 같은 파일명이 있는지 확인한다.
archive/에 새로 추가된 파일이 있으면 deploy/에 같은 파일명이 있는지 확인한다.
(보관/보관해제로 분류된 이동 파일은 제외 — 한쪽에서 삭제되고 다른 쪽에 추가된 것이므로 겹치지 않는다.)

겹치는 파일이 있으면 "deploy/와 archive/에 같은 이름의 파일이 있어요: {중복 파일명 목록}. 파일명을 변경하거나 중복 파일을 삭제해주세요."라고 안내하고 중단하라.

### Step 3 — 확인 요청

먼저 채팅 메시지로 변경사항을 종류별로 정리해서 보여준다. 해당하는 종류만 표시한다.

```
아래 변경사항을 저장할까요?

🌐 사이트 반영
  신규
  - test1.html → https://test.tunoinvest.com/test1.html

  업데이트
  - about.html → https://test.tunoinvest.com/about.html

  보관해제
  - old.html → https://test.tunoinvest.com/old.html

  삭제
  - removed.html (사이트에서 삭제됨)

📦 보관
  - page.html → archive/page.html

🗑️ 보관함 정리
  - ancient.html (보관함에서 삭제됨)

💾 작업 저장
  추가
  - develop/jeycorp1216/new-page.html

  수정
  - develop/jeycorp1216/draft.html

  삭제
  - develop/jeycorp1216/temp.html
```

그 다음 AskUserQuestion 도구로 간단하게 확인을 받는다.

- question: "저장할까요?"
- options: "저장하기", "취소"

사용자가 "저장하기"를 선택하면 다음 단계로 진행하라. "취소"를 선택하면 중단하라.

### Step 4 — deploy-id 처리

deploy/ 신규, 업데이트, 보관해제 파일에 deploy-id 타임스탬프를 삽입한다.

모든 배포 대상 파일의 `<head>` 태그 안에 아래 주석을 삽입한다 (배포 확인용).
기존에 `deploy-id` 주석이 있으면 **새 타임스탬프로 교체**하고, 없으면 **새로 삽입**한다:

```html
<!-- deploy-id: {한국 시간 ISO 8601 타임스탬프} -->
```

예: `<!-- deploy-id: 2026-03-23T20:05:30+09:00 -->`

- deploy/ 삭제, archive/ 보관/삭제, save 변경에는 deploy-id를 삽입하지 않는다.

### Step 5 — 종류별 커밋 분리 + push

`.claude/conventions.md`의 커밋 형식을 따른다.

```bash
git pull origin main
```

deploy 변경이 있으면:
```bash
git add deploy/관련파일들
git commit -m "deploy: ..."
```

archive 변경이 있으면:
```bash
git add archive/관련파일들 deploy/에서삭제된파일들(보관인경우)
git commit -m "archive: ..."
```

save 변경이 있으면:
```bash
git add 나머지파일들
git commit -m "save: ..."
```

```bash
git push origin main
```

- **push 전에 반드시 `git pull`을 먼저 실행하라.**
- push가 실패하면 "다른 사람이 먼저 업로드한 내용이 있어요. 다시 시도할게요"라고 안내하고, pull 후 다시 push를 시도하라.
- pull 과정에서 충돌(conflict)이 발생하면 충돌 파일 목록을 포함하여 "다른 사람의 작업과 겹치는 부분이 있어요: {충돌 파일 목록}. 개발팀에 문의해주세요."라고 안내하고 중단하라.

### Step 6 — 사이트 반영 확인

deploy/ 변경(신규, 업데이트, 보관해제)이 있었으면 첫 번째 파일만 확인:

```bash
bash .claude/scripts/check-site.sh "https://test.tunoinvest.com/{파일명}" "deploy-id: {삽입한 타임스탬프}"
```

archive/ 보관이 있었으면 (deploy/에서 삭제된 파일) 첫 번째 파일만 확인:

```bash
bash .claude/scripts/check-site.sh "https://test.tunoinvest.com/{파일명}" "404"
```

- `SUCCESS` → 성공
- `RETRY` → "아직 반영이 안 됐어요. 30초 후에 다시 확인해볼게요"
- `FAIL` → "반영에 문제가 생긴 것 같아요. 개발팀에 문의해주세요."

deploy/ 삭제만 있고 archive 보관이 없는 경우에도 404 확인한다.
save만 있었으면 사이트 확인을 건너뛴다.

### Step 7 — 결과 보고

종류별로 결과를 정리해서 보고한다.

## Example

**Input:**

```
/전체저장
```

**확인 단계:**

```
아래 변경사항을 저장할까요?

🌐 사이트 반영
  신규
  - test1.html → https://test.tunoinvest.com/test1.html
  - about.html → https://test.tunoinvest.com/about.html

📦 보관
  - old-page.html → archive/old-page.html

💾 작업 저장
  수정
  - develop/jeycorp1216/draft.html
```

**결과 (성공):**

```
저장 완료! ✅

🌐 사이트 반영
  신규
  - test1.html → https://test.tunoinvest.com/test1.html
  - about.html → https://test.tunoinvest.com/about.html

📦 보관
  - old-page.html → archive/old-page.html

💾 작업 저장
  수정
  - develop/jeycorp1216/draft.html

사이트에 정상 반영되었어요!
```

**결과 (변경사항 없음):**

```
변경된 파일이 없어요.
```

**결과 (사이트 확인 타임아웃):**

```
파일은 업로드했지만, 사이트 반영이 아직 안 된 것 같아요 ⚠️

🌐 사이트 반영
  신규
  - test1.html
  - about.html

잠시 후 아래 주소에서 직접 확인해보세요:
- https://test.tunoinvest.com/test1.html
- https://test.tunoinvest.com/about.html

그래도 페이지가 보이지 않는다면 개발팀에 문의해주세요.
```
