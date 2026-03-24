---
name: 선택보관
description: >
  Removes specified HTML files from deploy/ and moves them to archive/.
  Use when user says "archive", "내려줘", "사이트에서 빼줘",
  "배포 취소", "페이지 내려줘", "보관", "보관 해줘", "remove from site".
---

# 선택보관

`deploy/`에 있는 HTML 파일을 사이트에서 내리고 `archive/`로 이동한다.

## 배포 URL

`https://test.tunoinvest.com/{파일명}`

예: `deploy/test2.html` → `https://test.tunoinvest.com/test2.html`

## 핵심 원칙

- **대상은 반드시 `deploy/` 안의 `.html` 파일이어야 한다.**
- **deploy/ + archive/ 전체에서 파일명은 유니크해야 한다.** 보관 시 파일명은 그대로 유지된다.
- `archive/` 폴더가 없으면 자동으로 생성하라.

## 실행 순서

아래 순서를 **정확히** 따르라. 중간에 실패하면 즉시 중단하고 무엇이 잘못됐는지 쉽게 설명하라.

### Step 1 — 대상 확인

- 사용자가 지정한 파일이 `deploy/`에 존재하는지 확인하라.
  - 없으면 → "현재 배포되어 있지 않은 파일이에요: {파일명}"라고 안내하고 중단하라.
- 여러 파일을 지정한 경우 모두 대상으로 한다.
- `.html` 파일인지 확인하라.

### Step 2 — 파일명 충돌 확인

보관 대상 파일과 같은 이름의 파일이 `archive/`에 이미 있는지 확인한다.
있으면 "보관함에 같은 이름의 파일이 이미 있어요: {파일명 목록}. 보관함의 파일을 먼저 삭제하거나 이름을 변경해주세요."라고 안내하고 중단하라.

### Step 3 — 보관 확인 요청

AskUserQuestion 도구를 사용하여 사용자에게 확인을 받아라.

- question: 내릴 파일 목록을 보여주고 확인을 요청한다.
  - 파일이 1개면: "test2.html (https://test.tunoinvest.com/test2.html) 사이트에서 내릴까요?"
  - 파일이 여러 개면:

    ```
    아래 파일을 사이트에서 내릴까요?

    - test2.html (https://test.tunoinvest.com/test2.html)
    - about.html (https://test.tunoinvest.com/about.html)
    ```

- options: "내리기", "취소"

사용자가 "내리기"를 선택하면 다음 단계로 진행하라. "취소"를 선택하면 중단하라.

### Step 4 — archive/로 이동

- `deploy/`에서 해당 파일을 `archive/`로 그대로 이동하라.
  - 예: `deploy/test2.html` → `archive/test2.html`
- `deploy/`에서는 삭제된다 (이동이므로).

### Step 5 — 배포 실행

```bash
git pull origin main
# 이 스킬이 처리한 파일만 staging한다. git add -A를 사용하지 마라.
git add archive/{파일1} archive/{파일2} ...    # 보관된 파일
git add deploy/{파일1} deploy/{파일2} ...      # deploy/에서 삭제된 파일
git commit -m "<커밋 메시지>"
git push origin main
```

**중요: `git add -A`를 사용하지 마라.** 이 스킬이 처리한 파일만 정확히 staging한다.
다른 변경사항(develop/ 수정, 다른 deploy/ 파일 등)은 커밋에 포함하지 않는다.

**커밋 메시지:** `.claude/conventions.md`의 `archive:` prefix 형식을 따르라.

- **push 전에 반드시 `git pull`을 먼저 실행하라.**
- push가 실패하면 "다른 사람이 먼저 업로드한 내용이 있어요. 다시 시도할게요"라고 안내하고, pull 후 다시 push를 시도하라.
- pull 과정에서 충돌(conflict)이 발생하면 충돌 파일 목록을 포함하여 "다른 사람의 작업과 겹치는 부분이 있어요: {충돌 파일 목록}. 개발팀에 문의해주세요."라고 안내하고 중단하라.

### Step 6 — 사이트 반영 확인

push 완료 후 해당 URL에서 페이지가 실제로 내려갔는지 확인한다.
파일이 여러 개면 첫 번째 파일만 확인하면 된다.

```bash
bash .claude/scripts/check-site.sh "https://test.tunoinvest.com/{파일명}" "404"
```

- `SUCCESS` 출력 → 성공. "사이트에서 정상적으로 내려갔어요!"
- `RETRY` 출력 → "아직 반영이 안 됐어요. 30초 후에 다시 확인해볼게요"라고 안내한다. (스크립트가 자동으로 재시도한다)
- `FAIL` 출력 → "사이트 반영에 문제가 생긴 것 같아요. 개발팀에 문의해주세요."라고 안내한다.

### Step 7 — 결과 보고

내려진 파일 목록, 성공/실패를 명확히 보고하라.

결과 보고 후 `git status`로 커밋되지 않은 다른 변경사항이 있는지 확인한다.
있으면 "다른 변경사항도 있어요. 필요하면 `/전체저장`으로 나머지도 저장할 수 있어요."라고 안내하라.

## Example

**Input:**

```
/선택보관 test2.html
```

**확인 단계:**

```
test2.html (https://test.tunoinvest.com/test2.html) 사이트에서 내릴까요?
```

**결과 (성공):**

```
사이트에서 내렸어요! ✅

내린 파일:
- test2.html → archive/test2.html 으로 보관됨

https://test.tunoinvest.com/test2.html 에서 더 이상 접속되지 않아요.
```

**결과 (타임아웃):**

```
파일은 보관했지만, 사이트에서 아직 안 내려진 것 같아요 ⚠️

내린 파일:
- test2.html → archive/test2.html 으로 보관됨

잠시 후 아래 주소에서 직접 확인해보세요:
https://test.tunoinvest.com/test2.html

그래도 페이지가 보인다면 개발팀에 문의해주세요.
```
