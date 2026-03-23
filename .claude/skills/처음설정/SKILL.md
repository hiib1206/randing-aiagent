---
name: 처음설정
description: >
  Initial setup for new users on Mac: git install, GitHub config, remote connection, and workspace folder creation.
  Use when user says "setup", "처음설정", "처음 설정", "initial setup".
---

# Setup

비개발자가 이 프로젝트를 처음 사용할 때 필요한 처음 설정을 자동으로 진행한다.

## 사용자는 비개발자다

- git, 커밋, 푸시, 브랜치, remote 같은 기술 용어를 쓰지 마라.
- "설치", "연결", "폴더 만들기" 같이 쉬운 말을 써라.
- 에러가 나면 기술적 메시지를 그대로 보여주지 말고, 무엇이 문제인지 쉽게 설명하라.

## 실행 순서

아래 순서를 **정확히** 따르라. 중간에 실패하면 즉시 중단하고 무엇이 잘못됐는지 쉽게 설명하라.

### Step 1 — Git 설치 확인

`git --version`을 실행한다.

- **성공** → 다음 단계로 진행.
- **실패 (git이 없음)** → `xcode-select --install`을 실행하고 아래와 같이 안내한다:

```
필요한 프로그램을 설치할게요.
팝업 창이 뜨면 "설치" 버튼을 눌러주세요.
설치가 끝나면 알려주세요!
```

사용자가 설치 완료를 알려주면 `git --version`으로 다시 확인하고, 성공하면 다음 단계로 진행한다.

### Step 2 — 사용자 정보 설정

`git config --global user.name`과 `git config --global user.email`을 확인한다.

- **둘 다 설정되어 있으면** → "계정 정보가 이미 설정되어 있어요 ✅"라고 안내하고 다음 단계로 진행.
- **하나라도 없으면** → 사용자에게 아래를 물어본다:

```
GitHub 계정 정보를 설정할게요.

1. GitHub 닉네임이 뭐예요? (예: jeycorp1216)
2. GitHub에 가입한 이메일 주소는요? (예: example@gmail.com)
```

사용자가 답하면 아래를 실행한다:

```bash
git config --global user.name "{닉네임}"
git config --global user.email "{이메일}"
```

### Step 3 — 프로젝트 연결 확인

`git remote -v`를 실행한다.

- **origin이 있으면** → 다음 단계로 진행.
- **origin이 없으면** → 아래를 실행한다:

```bash
git remote add origin https://github.com/hiib1206/randing-aiagent.git
```

### Step 4 — 연결 테스트

`git pull origin main`을 실행한다.

- **성공** → 다음 단계로 진행.
- **브라우저 로그인 창이 뜨는 경우** → 아래와 같이 안내한다:

```
GitHub 로그인 화면이 떴을 거예요.
브라우저에서 GitHub 계정으로 로그인해주세요!
로그인하면 자동으로 연결돼요.
```

- **실패** → 아래와 같이 안내하고 중단한다:

```
연결에 문제가 있어요.
개발팀에 문의해주세요.
```

### Step 5 — 프로젝트 폴더 확인 및 생성

아래 필수 폴더들이 없으면 자동으로 생성한다:

1. `develop/` — 작업 공간
2. `deploy/` — 배포 공간
3. `archive/` — 보관 공간
4. `guideline/` — 가이드라인 모음

각 폴더가 이미 있으면 건너뛴다. 없는 폴더만 생성한다.

그 다음, Step 2에서 설정한 GitHub 닉네임을 그대로 폴더 이름으로 사용하여 개인 작업 폴더를 만든다. 사용자에게 따로 묻지 마라.

1. `develop/{GitHub 닉네임}` 경로에 폴더가 이미 있는지 확인한다.
   - **이미 있으면** → "이미 폴더가 있어요! 그대로 사용하면 돼요 ✅"라고 안내하고 다음 단계로 진행.
   - **없으면** → 폴더를 생성한다.

### Step 6 — 완료 안내

모든 단계가 끝나면 아래 형식으로 결과를 보고한다:

```
처음 설정 완료! ✅

📌 계정: {닉네임} ({이메일})
📁 작업 폴더: develop/{닉네임}

이제 아래 명령어를 사용할 수 있어요:

• /배포 — 만든 페이지를 사이트에 올리기
• /보관 — 사이트에서 페이지 내리기
• /가이드 — 규칙 및 사용법 보기
```

## Example

**Input:**

```
/처음설정
```

**Step 1 결과 (git 있음):**

→ 건너뛰고 다음 단계

**Step 2 질문:**

```
GitHub 계정 정보를 설정할게요.

1. GitHub 닉네임이 뭐예요? (예: jeycorp1216)
2. GitHub에 가입한 이메일 주소는요? (예: example@gmail.com)
```

**Step 5 결과 (GitHub 닉네임으로 자동 생성):**

→ GitHub 닉네임 jeycorp1216으로 폴더 생성

**최종 결과:**

```
처음 설정 완료! ✅

📌 계정: jeycorp1216 (jeycorp1216@gmail.com)
📁 작업 폴더: develop/jeycorp1216

이제 아래 명령어를 사용할 수 있어요:

• /배포 — 만든 페이지를 사이트에 올리기
• /보관 — 사이트에서 페이지 내리기
• /가이드 — 규칙 및 사용법 보기
```
