---
name: deploy
description: >
  Copies HTML files from develop/ to deploy/ and publishes automatically.
  Use when user says "deploy", "배포", "배포해줘", "deploy this", "배포하고 싶어".
---

# Deploy

`develop/` 안의 HTML 파일 또는 HTML을 포함한 폴더를 `deploy/`로 복사하고 자동으로 배포(git push)한다.

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
- 해당 경로에 `.html` 파일이 있는지 확인하라.

### Step 2 — deploy/로 복사

- 파일이면 `deploy/`에 복사하라.
- 폴더면 폴더째로 `deploy/` 아래에 복사하되, `.html` 파일만 복사하라.
- 같은 이름이 이미 존재하면 사용자에게 덮어쓸지 확인하라.
- 원본은 삭제하지 마라.

### Step 3 — 배포

```bash
git add deploy/
git commit -m "deploy: <대상 이름>"
git push origin <현재 브랜치>
```

이 단계는 사용자에게 기술 용어 없이 "배포할까요?"라고 확인을 받은 뒤 실행하라.

### Step 4 — 결과 보고

## Example

**Input:**

```
/deploy develop/jeycorp1216
```

**Output:**

```
배포 완료!
- develop/jeycorp1216 → deploy/jeycorp1216 (HTML 1개 복사됨)
- 배포가 정상적으로 완료되었어요 ✅
```
