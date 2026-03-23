---
name: restore
description: >
  Restores archived HTML files back to deploy/ with their original v-number.
  Use when user says "restore", "다시 올려줘", "다시 배포", "archive에서 올려줘", "put back".
---

# Restore

`archive/`에 있는 HTML 파일을 원래 v번호 그대로 `deploy/`로 되돌려 사이트에 다시 올린다.

## 배포 URL

`https://test.tunoinvest.com/v{번호}`

예: `archive/v3.html` → `deploy/v3.html` → `https://test.tunoinvest.com/v3`

## 제약 조건

- **대상은 반드시 `archive/` 안의 `.html` 파일이어야 한다.**
- `archive/`에 없는 파일을 지정하면 "보관된 파일이 아니에요"라고 안내하고 중단하라.
- 같은 이름의 파일이 `deploy/`에 이미 존재하면 "이미 배포되어 있는 파일이에요"라고 안내하고 중단하라.

## 사용자는 비개발자다

- git, 커밋, 푸시, 브랜치 같은 기술 용어를 쓰지 마라.
- "다시 올렸어요", "복원 완료" 같이 쉬운 말을 써라.
- 에러가 나면 기술적 메시지를 그대로 보여주지 말고, 무엇이 문제인지 쉽게 설명하라.

## 실행 순서

아래 순서를 **정확히** 따르라. 중간에 실패하면 즉시 중단하고 무엇이 잘못됐는지 쉽게 설명하라.

### Step 1 — 대상 확인

- 사용자가 지정한 파일이 `archive/`에 존재하는지 확인하라.
- `.html` 파일인지 확인하라.
- 같은 이름의 파일이 `deploy/`에 이미 있는지 확인하라. 있으면 "이미 배포되어 있는 파일이에요"라고 안내하고 중단하라.
- 사용자가 파일명을 지정하지 않으면 `archive/`에 있는 파일 목록을 보여주고 선택하게 하라.

### Step 2 — 복원 확인 요청

사용자에게 아래 형식으로 확인을 받아라:

```
아래 파일을 다시 사이트에 올릴까요?

1. v3.html → https://test.tunoinvest.com/v3

총 1개 파일
```

여러 파일일 때:

```
아래 파일을 다시 사이트에 올릴까요?

1. v3.html → https://test.tunoinvest.com/v3
2. v5.html → https://test.tunoinvest.com/v5

총 2개 파일
```

사용자가 확인하면 다음 단계로 진행하라.

### Step 3 — deploy/로 이동

- `archive/`에서 해당 파일을 `deploy/`로 이동하라.
  - 예: `archive/v3.html` → `deploy/v3.html`
- `archive/`에서는 삭제된다 (이동이므로).

### Step 4 — 배포 실행

```bash
git pull origin main
git add -A
git commit -m "restore: <파일 1개면 v번호, 여러 개면 'v번호, v번호'>

- v3.html
- v5.html
..."
git push origin main
```

- **push 전에 반드시 `git pull`을 먼저 실행하라.**
- push가 실패하면 "다른 사람이 먼저 업로드한 내용이 있어요. 다시 시도할게요"라고 안내하고, pull 후 다시 push를 시도하라.
- pull 과정에서 충돌(conflict)이 발생하면 "다른 사람의 작업과 겹치는 부분이 있어요. 개발팀에 문의해주세요."라고 안내하고 중단하라.

### Step 5 — 사이트 반영 확인

push 완료 후 해당 URL에서 페이지가 다시 올라왔는지 확인한다.

1. 해당 파일의 URL에 `curl`로 요청을 보낸다.
   - 파일이 여러 개면 첫 번째 파일만 확인하면 된다.
2. **200 응답이 오면** → 성공.
3. **404 응답이 오면** → 아직 반영 안 됨, 재시도.
4. **5초 간격으로 최대 90초** 동안 반복한다.
5. 90초 초과 시 → "아직 반영이 안 됐어요. 30초 후에 다시 확인해볼게요"라고 안내하고, 30초 후 한 번 더 확인한다.
6. 재확인에서도 실패 시 → "복원에 문제가 생긴 것 같아요. 개발팀에 문의해주세요."라고 안내한다.

```bash
curl -s -o /dev/null -w "%{http_code}" "https://test.tunoinvest.com/v{번호}"
```

### Step 6 — 결과 보고

복원된 파일 목록, 성공/실패, 접속 URL을 명확히 보고하라.

## Example

**Input:**

```
/restore v3.html
```

**확인 단계:**

```
아래 파일을 다시 사이트에 올릴까요?

1. v3.html → https://test.tunoinvest.com/v3

총 1개 파일
```

**결과 (성공):**

```
복원 완료! ✅

복원된 파일:
- v3.html → https://test.tunoinvest.com/v3

사이트에 다시 올라갔어요!
```

**결과 (타임아웃):**

```
파일은 복원했지만, 사이트 반영이 아직 안 된 것 같아요 ⚠️

복원된 파일:
- v3.html

잠시 후 아래 주소에서 직접 확인해보세요:
https://test.tunoinvest.com/v3

그래도 페이지가 보이지 않는다면 개발팀에 문의해주세요.
```
