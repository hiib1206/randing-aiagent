---
name: archive
description: >
  Removes HTML files from deploy/ and moves them to archive/.
  Use when user says "archive", "내려줘", "사이트에서 빼줘",
  "배포 취소", "페이지 내려줘", "remove from site".
---

# Archive

`deploy/`에 있는 HTML 파일을 사이트에서 내리고 `archive/`로 이동한다.

## 배포 URL

`https://test.tunoinvest.com/v{번호}`

예: `deploy/v3.html` → `https://test.tunoinvest.com/v3`

## 제약 조건

- **대상은 반드시 `deploy/` 안의 `.html` 파일이어야 한다.**
- `deploy/`에 없는 파일을 지정하면 "현재 배포되어 있지 않은 파일이에요"라고 안내하고 중단하라.
- `archive/` 폴더가 없으면 자동으로 생성하라.
- 아카이브해도 v번호는 재사용되지 않는다. 다음 배포 시 `deploy/`와 `archive/`를 스캔하여 최대 번호 + 1을 부여한다.

## 사용자는 비개발자다

- git, 커밋, 푸시, 브랜치 같은 기술 용어를 쓰지 마라.
- "사이트에서 내렸어요", "보관 완료" 같이 쉬운 말을 써라.
- 에러가 나면 기술적 메시지를 그대로 보여주지 말고, 무엇이 문제인지 쉽게 설명하라.

## 실행 순서

아래 순서를 **정확히** 따르라. 중간에 실패하면 즉시 중단하고 무엇이 잘못됐는지 쉽게 설명하라.

### Step 1 — 대상 확인

- 사용자가 지정한 파일이 `deploy/`에 존재하는지 확인하라.
- `.html` 파일인지 확인하라.

### Step 2 — 내리기 확인 요청

AskUserQuestion 도구를 사용하여 실행 전에 사용자에게 확인을 받아라.

- question: 내릴 파일 목록을 보여주고 확인을 요청한다.
  - 파일이 1개면: "v3.html (https://test.tunoinvest.com/v3) 사이트에서 내릴까요?"
  - 파일이 여러 개면: "아래 파일을 사이트에서 내릴까요?\n1. v3.html (https://test.tunoinvest.com/v3)\n2. v5.html (https://test.tunoinvest.com/v5)"
- options: "내리기", "취소"

사용자가 "내리기"를 선택하면 다음 단계로 진행하라. "취소"를 선택하면 중단하라.

### Step 3 — archive/로 이동

- `deploy/`에서 해당 파일을 `archive/`로 그대로 이동하라.
  - 예: `v3.html` → `archive/v3.html`
- `deploy/`에서는 삭제된다 (이동이므로).

### Step 4 — 배포 실행

```bash
git pull origin main
git add -A
git commit -m "archive: <파일 1개면 파일명, 여러 개면 'N개 파일'>

- file1.html
- file2.html
..."
git push origin main
```

- **push 전에 반드시 `git pull`을 먼저 실행하라.**
- push가 실패하면 "다른 사람이 먼저 업로드한 내용이 있어요. 다시 시도할게요"라고 안내하고, pull 후 다시 push를 시도하라.
- pull 과정에서 충돌(conflict)이 발생하면 "다른 사람의 작업과 겹치는 부분이 있어요. 개발팀에 문의해주세요."라고 안내하고 중단하라.

### Step 5 — 사이트 반영 확인

push 완료 후 해당 URL에서 페이지가 실제로 내려갔는지 확인한다.
파일이 여러 개면 첫 번째 파일만 확인하면 된다.

```bash
bash .claude/scripts/check-site.sh "https://test.tunoinvest.com/v{번호}" "404"
```

- `SUCCESS` 출력 → 성공. "사이트에서 정상적으로 내려갔어요!"
- `RETRY` 출력 → "아직 반영이 안 됐어요. 30초 후에 다시 확인해볼게요"라고 안내한다. (스크립트가 자동으로 재시도한다)
- `FAIL` 출력 → "사이트 반영에 문제가 생긴 것 같아요. 개발팀에 문의해주세요."라고 안내한다.

### Step 6 — 결과 보고

내려진 파일 목록, 성공/실패, 보관 위치를 명확히 보고하라.

## Example

**Input:**

```
/archive v3.html
```

**확인 단계:**

```
아래 파일을 사이트에서 내릴까요?

1. v3.html (https://test.tunoinvest.com/v3)

총 1개 파일
```

**결과 (성공):**

```
사이트에서 내렸어요! ✅

내린 파일:
- v3.html → archive/v3.html 으로 보관됨

https://test.tunoinvest.com/v3 에서 더 이상 접속되지 않아요.
```

**결과 (타임아웃):**

```
파일은 보관했지만, 사이트에서 아직 안 내려진 것 같아요 ⚠️

내린 파일:
- v3.html → archive/v3.html 으로 보관됨

잠시 후 아래 주소에서 직접 확인해보세요:
https://test.tunoinvest.com/v3

그래도 페이지가 보인다면 개발팀에 문의해주세요.
```
