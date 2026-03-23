---
name: 깃저장
description: >
  Commits and pushes all project changes to git.
  Use when user says "깃저장", "깃에 저장해줘", "깃에 올려줘", "깃에 푸쉬해줘", "git save", "git push".
---

# 깃저장

프로젝트의 변경사항을 확인하고 git에 저장(commit + push)한다.

## 사용자는 비개발자다

- git, 커밋, 푸시, 브랜치 같은 기술 용어를 쓰지 마라.
- "저장 완료", "업로드 완료" 같이 쉬운 말을 써라.
- 에러가 나면 기술적 메시지를 그대로 보여주지 말고, 무엇이 문제인지 쉽게 설명하라.

## 실행 순서

아래 순서를 **정확히** 따르라. 중간에 실패하면 즉시 중단하고 무엇이 잘못됐는지 쉽게 설명하라.

### Step 1 — 변경사항 확인

`git status`로 변경된 파일 목록을 파악한다.

- 새 파일, 수정된 파일, 삭제된 파일을 각각 분류한다.
- 변경사항이 하나도 없으면 "변경된 파일이 없어요"라고 안내하고 중단하라.

### Step 2 — 저장 확인 요청

AskUserQuestion 도구를 사용하여 사용자에게 확인을 받아라.

- question: 변경된 파일 목록을 종류별로 보여주고 확인을 요청한다.
  - 파일이 1개면: "develop/userA/test1.html (수정) 저장할까요?"
  - 파일이 여러 개면:

    ```
    아래 변경사항을 저장할까요?

    추가
    - develop/userA/new-page.html

    수정
    - develop/userA/test1.html
    - guideline/rule.md
    ```

- 목록 아래에 "의도하지 않은 변경이 있는지 확인해주세요!" 문구를 추가하라.
- options: "저장하기", "취소"

사용자가 "저장하기"를 선택하면 다음 단계로 진행하라. "취소"를 선택하면 중단하라.

### Step 3 — 저장 실행

```bash
git pull origin main
git add -A
git commit -m "<커밋 메시지>"
git push origin main
```

- **push 전에 반드시 `git pull`을 먼저 실행하라.** 다른 사람이 먼저 push했을 수 있다.
- pull 과정에서 충돌(conflict)이 발생하면 사용자에게 "다른 사람의 작업과 겹치는 부분이 있어요. 개발팀에 문의해주세요."라고 안내하고 중단하라.
- push가 실패하면 "다른 사람이 먼저 업로드한 내용이 있어요. 다시 시도할게요"라고 안내하고, pull 후 다시 push를 시도하라.
- 재시도 pull에서 충돌이 발생하면 "다른 사람의 작업과 겹치는 부분이 있어요. 개발팀에 문의해주세요."라고 안내하고 중단하라.

**커밋 메시지 형식 (자동 생성):**

항상 파일 경로를 포함한다. 종류: 추가 / 수정 / 삭제

1개 파일:

```
save: 수정 develop/userA/test1.html

수정
- develop/userA/test1.html
```

여러 파일 (종류 1가지):

```
save: 수정 3개 파일

수정
- develop/userA/test1.html
- develop/userA/about.html
- guideline/rule.md
```

여러 파일 (종류 섞임):

```
save: 3개 파일

추가
- develop/userA/new-page.html

수정
- develop/userA/test1.html
- guideline/rule.md
```

### Step 4 — 결과 보고

저장된 파일 목록을 명확히 보고하라.

## Example

**Input:**

```
/깃저장
```

**확인 단계:**

```
아래 변경사항을 저장할까요?

수정
- develop/jeycorp1216/test1.html
- develop/jeycorp1216/about.html

총 2개 파일
```

**결과 (성공):**

```
저장 완료! ✅

수정
- develop/jeycorp1216/test1.html
- develop/jeycorp1216/about.html

2개 파일이 저장되었어요!
```

**결과 (변경사항 없음):**

```
변경된 파일이 없어요.
```
