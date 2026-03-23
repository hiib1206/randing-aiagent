---
name: 배포
description: >
  Copies HTML files to deploy/ and publishes automatically.
  Use when user says "deploy", "배포", "배포해줘", "deploy this", "배포하고 싶어".
---

# 배포

프로젝트 내 HTML 파일을 `deploy/`에 넣고 자동으로 배포(git push)한다.
배포 후 실제 URL에 반영되었는지까지 확인한다.

## 배포 URL

`https://test.tunoinvest.com/{파일명}`

예: `develop/jeycorp1216/test2.html` → `deploy/test2.html` → `https://test.tunoinvest.com/test2.html`

Cloudflare CDN이 `deploy/` 폴더를 사이트 루트로 서빙한다.

## 핵심 원칙

- **deploy/ + archive/ 전체에서 파일명은 유니크해야 한다.**
- **소스 제한 없음** — 프로젝트 내 어디서든 배포 가능.
- **HTML 파일(.html)만 배포 대상이다.**

## 사용자는 비개발자다

- git, 커밋, 푸시, 브랜치 같은 기술 용어를 쓰지 마라.
- "배포 완료", "업로드 완료" 같이 쉬운 말을 써라.
- 에러가 나면 기술적 메시지를 그대로 보여주지 말고, 무엇이 문제인지 쉽게 설명하라.

## 실행 순서

아래 순서를 **정확히** 따르라. 중간에 실패하면 즉시 중단하고 무엇이 잘못됐는지 쉽게 설명하라.

### Step 1 — 대상 확인

- 사용자가 경로를 지정한 경우: 해당 경로의 HTML 파일을 대상으로 한다.
- 사용자가 파일명만 말한 경우 (경로 없이): 프로젝트 내에서 검색한다.
  - 1개만 있으면 → 바로 진행.
  - 여러 개 있으면 → "같은 이름의 파일이 여러 개 있어요. 어떤 파일을 배포할까요?" 목록을 보여주고 선택을 받아라.
- 폴더를 지정한 경우, 그 안의 `.html` 파일만 대상으로 한다. HTML이 아닌 파일은 무시하고 무시된 파일 목록을 알려줘라.
- HTML 파일이 하나도 없으면 "배포할 HTML 파일이 없어요"라고 안내하고 중단하라.

### Step 2 — 충돌 확인 및 종류 판별

배포할 HTML 파일 각각에 대해 종류를 판별한다.

**소스가 deploy/ 파일인 경우:**

- 종류: **업데이트** (이미 배포 위치에 있으므로 변경사항만 push하면 된다)

**소스가 archive/ 파일인 경우:**

- 종류: **보관해제** (deploy/로 이동한다)

**소스가 그 외 위치인 경우:**

- `deploy/`에 같은 파일명이 있으면:
  - 내용이 다르면 → 종류: **업데이트**
  - 내용이 같으면 → "이미 동일한 내용으로 배포되어 있어요" 안내 후 중단.
- `archive/`에 같은 파일명이 있으면:
  - → "보관함에 같은 이름의 파일이 있어요. 파일명을 변경하거나, 보관함의 파일을 먼저 삭제해주세요." 안내 후 중단.
- 둘 다 없으면 → 종류: **신규**

**이 단계에서는 파일 복사/이동을 하지 않는다.** 확인만 한다.

### Step 3 — 배포 확인 요청

AskUserQuestion 도구를 사용하여 사용자에게 확인을 받아라.

- question: 배포할 파일 목록을 종류와 함께 보여주고 확인을 요청한다.
  - 파일이 1개면: "test2.html (신규) → https://test.tunoinvest.com/test2.html 배포할까요?"
  - 파일이 여러 개면:

    ```
    아래 파일을 배포할까요?

    신규
    - test2.html → https://test.tunoinvest.com/test2.html
    - pricing.html → https://test.tunoinvest.com/pricing.html

    업데이트
    - about.html → https://test.tunoinvest.com/about.html
    ```

- options: "배포하기", "취소"

사용자가 "배포하기"를 선택하면 다음 단계로 진행하라. "취소"를 선택하면 중단하라.

### Step 4 — 파일 처리 + 타임스탬프 삽입

소스 위치에 따라 처리 방식이 다르다:

- **deploy/ 파일** → 복사 없음. 이미 배포 위치에 있다.
- **archive/ 파일** → `archive/`에서 `deploy/`로 이동한다.
- **그 외** → `deploy/{원본파일명}`으로 복사한다 (업데이트 시 덮어쓰기).

모든 배포 대상 파일의 `<head>` 태그 안에 아래 주석을 삽입한다 (배포 확인용).
기존에 `deploy-id` 주석이 있으면 **새 타임스탬프로 교체**하고, 없으면 **새로 삽입**한다:

```html
<!-- deploy-id: {한국 시간 ISO 8601 타임스탬프} -->
```

예: `<!-- deploy-id: 2026-03-23T20:05:30+09:00 -->`

이 주석은 브라우저에 보이지 않으며, Step 6에서 배포 확인에 사용된다.

- 원본(소스 파일)은 삭제하지 마라. (archive/ 소스는 예외 — 이동이므로 archive/에서 사라진다)

### Step 5 — 배포 실행

```bash
git pull origin main
git add -A
git commit -m "<커밋 메시지>"
git push origin main
```

**커밋 메시지 형식:**

1개 파일:

```
deploy: 신규 test1.html

신규
- test1.html
```

여러 파일 (종류 1가지):

```
deploy: 업데이트 3개 파일

업데이트
- test1.html
- about.html
- pricing.html
```

여러 파일 (종류 섞임):

```
deploy: 3개 파일

신규
- test1.html
- pricing.html

업데이트
- about.html
```

- **push 전에 반드시 `git pull`을 먼저 실행하라.** 다른 사람이 먼저 push했을 수 있다.
- push가 실패하면 "다른 사람이 먼저 업로드한 내용이 있어요. 다시 시도할게요"라고 안내하고, pull 후 다시 push를 시도하라.
- pull 과정에서 충돌(conflict)이 발생하면 사용자에게 "다른 사람의 작업과 겹치는 부분이 있어요. 개발팀에 문의해주세요."라고 안내하고 중단하라.

### Step 6 — 배포 반영 확인

push 완료 후 실제 URL에 반영되었는지 확인한다.
파일이 여러 개면 첫 번째 파일만 확인하면 된다.

```bash
bash .claude/scripts/check-site.sh "https://test.tunoinvest.com/{파일명}" "deploy-id: {삽입한 타임스탬프}"
```

- `SUCCESS` 출력 → 성공. "사이트에 정상 반영되었어요!"
- `RETRY` 출력 → "아직 반영이 안 됐어요. 30초 후에 다시 확인해볼게요"라고 안내한다. (스크립트가 자동으로 재시도한다)
- `FAIL` 출력 → "배포에 문제가 생긴 것 같아요. 개발팀에 문의해주세요."라고 안내한다.

### Step 7 — 결과 보고

배포된 파일 목록, 종류, 성공/실패, 접속 URL을 명확히 보고하라.

## Example

**Input:**

```
/배포 develop/jeycorp1216
```

**확인 단계:**

```
아래 파일을 배포할까요?

신규
- test2.html → https://test.tunoinvest.com/test2.html

총 1개 파일
```

**결과 (성공):**

```
배포 완료! ✅

신규
- test2.html → https://test.tunoinvest.com/test2.html

사이트에 정상 반영되었어요!
```

**결과 (여러 파일):**

```
배포 완료! ✅

신규
- test2.html → https://test.tunoinvest.com/test2.html
- pricing.html → https://test.tunoinvest.com/pricing.html

업데이트
- about.html → https://test.tunoinvest.com/about.html

3개 파일이 사이트에 정상 반영되었어요!
```

**결과 (타임아웃):**

```
파일은 업로드했지만, 사이트 반영이 아직 안 된 것 같아요 ⚠️

배포된 파일:
- test2.html

잠시 후 아래 주소에서 직접 확인해보세요:
https://test.tunoinvest.com/test2.html

그래도 페이지가 보이지 않는다면 개발팀에 문의해주세요.
```
