# 프로젝트 전체 흐름

비개발자가 Claude Code로 HTML 랜딩 페이지를 만들고, 배포/관리하는 프로젝트의 전체 시나리오 정리.

---

## 폴더 구조

```
develop/          ← 작업 공간 (각자 본인 폴더)
  └─ jeycorp1216/   ← 사용자별 폴더 (HTML 작업)
deploy/           ← 배포 공간 (사이트에 올라간 파일)
archive/          ← 보관 공간 (사이트에서 내린 파일)
```

## 스킬 목록

| 스킬 | 설명 | 트리거 |
|------|------|--------|
| `/setup` | 초기 세팅 (Git, 계정, 폴더) | "세팅", "처음", "시작" |
| `/deploy` | 사이트에 올리기 | "배포", "배포해줘" |
| `/archive` | 사이트에서 내리기 | "내려줘", "배포 취소" |
| `/restore` | 내린 파일 다시 올리기 | "다시 올려줘", "다시 배포" |
| `/guide` | 규칙 안내 | "규칙", "가이드" |

---

## 시나리오 1: 신규 사용자 온보딩

```
사용자: "처음이에요" or "/setup"
```

```
Step 1. Git 설치 확인
        ├─ 있음 → 다음
        └─ 없음 → xcode-select --install → 팝업에서 "설치" 클릭

Step 2. GitHub 계정 설정
        ├─ 이미 설정됨 → 다음
        └─ 없음 → 닉네임, 이메일 입력받아 설정

Step 3. 프로젝트 원격 연결 확인
        ├─ origin 있음 → 다음
        └─ 없음 → remote add origin

Step 4. 연결 테스트 (git pull)
        ├─ 성공 → 다음
        ├─ 로그인 필요 → 브라우저에서 GitHub 로그인 안내
        └─ 실패 → "개발팀에 문의해주세요"

Step 5. 작업 폴더 생성
        → develop/{회사닉네임} 폴더 생성

Step 6. 완료 안내
        → 사용 가능한 스킬 목록 안내
```

---

## 시나리오 2: HTML 페이지 제작

```
사용자: "랜딩 페이지 만들어줘"
```

```
1. develop/{본인폴더}/ 안에서 HTML 파일 작성
2. 수정/미리보기 반복
3. 완성되면 → /deploy로 배포
```

**주의사항:**
- 본인 폴더에서만 작업
- HTML 파일만 생성 가능
- 다른 폴더 수정 금지

---

## 시나리오 3: 배포 (/deploy)

```
사용자: "/deploy develop/jeycorp1216" or "배포해줘"
```

```
Step 1. 대상 확인
        ├─ develop/ 하위인지 확인
        ├─ 경로 존재하는지 확인
        └─ .html 파일 있는지 확인

Step 2. v번호 계산
        → deploy/ + archive/ 스캔 → 최대 v번호 + 1

Step 3. 사용자 확인
        → "test2.html → v1.html → https://test.tunoinvest.com/v1 배포할까요?"

Step 4. 파일 복사 + deploy-id 삽입
        → deploy/v1.html 생성
        → <head>에 <!-- deploy-id: 타임스탬프 --> 삽입

Step 5. 업로드 (git pull → add → commit → push)
        ├─ 성공 → 다음
        ├─ push 실패 → pull 후 재시도
        └─ 충돌 → "개발팀에 문의해주세요"

Step 6. 반영 확인 (curl로 deploy-id 확인)
        ├─ 성공 → 완료
        ├─ 90초 초과 → 30초 후 재확인
        └─ 재확인 실패 → "개발팀에 문의해주세요"

Step 7. 결과 보고
        → URL 포함 완료 메시지
```

**결과:** `https://test.tunoinvest.com/v1` 에서 페이지 접속 가능

---

## 시나리오 4: 사이트에서 내리기 (/archive)

```
사용자: "/archive v1.html" or "v1 내려줘"
```

```
Step 1. 대상 확인
        → deploy/에 해당 파일 존재하는지 확인

Step 2. archive/로 이동
        → deploy/v1.html → archive/v1.html

Step 3. 사용자 확인
        → "v1.html (https://test.tunoinvest.com/v1) 내릴까요?"

Step 4. 업로드 (git pull → add → commit → push)

Step 5. 반영 확인 (curl로 404 확인)
        ├─ 404 → 성공
        └─ 200 → 아직 반영 안 됨 → 재시도

Step 6. 결과 보고
        → "v1.html → archive/v1.html 으로 보관됨"
```

**결과:** `https://test.tunoinvest.com/v1` 접속 불가 (404)

---

## 시나리오 5: 내린 파일 다시 올리기 (/restore)

```
사용자: "/restore v1.html" or "v1 다시 올려줘"
```

```
Step 1. 대상 확인
        ├─ archive/에 해당 파일 존재하는지 확인
        └─ deploy/에 같은 파일 이미 있는지 확인

Step 2. 사용자 확인
        → "v1.html (https://test.tunoinvest.com/v1) 다시 올릴까요?"

Step 3. deploy/로 이동
        → archive/v1.html → deploy/v1.html

Step 4. 업로드 (git pull → add → commit → push)

Step 5. 반영 확인 (curl로 200 확인)
        ├─ 200 → 성공
        └─ 404 → 아직 반영 안 됨 → 재시도

Step 6. 결과 보고
        → "v1.html 다시 올라갔어요!"
```

**결과:** `https://test.tunoinvest.com/v1` 다시 접속 가능

---

## 시나리오 6: 규칙 확인 (/guide)

```
사용자: "/guide" or "규칙 알려줘"
```

```
→ 5가지 규칙 안내:
  1. 내 폴더에서만 작업
  2. HTML 파일만 만들기
  3. deploy/, archive/ 직접 수정 금지
  4. /deploy, /archive, /restore, /guide 스킬 사용
  5. 배포 시 파일명 자동 v번호 부여
```

---

## v번호 체계

```
첫 배포:     deploy/ 비어있음, archive/ 비어있음 → v1
두 번째:     deploy/v1.html 있음 → v2
v1 내린 후:  deploy/v2.html, archive/v1.html → 최대값 2 → v3
여러 파일:   최대값 3 + 파일 3개 → v4, v5, v6
```

**핵심:** 번호는 절대 재사용되지 않는다 (DB auto-increment 방식)

---

## 전체 라이프사이클

```
[신규 사용자]
     │
     ▼
  /setup ─── Git 설치 → 계정 설정 → 폴더 생성
     │
     ▼
[HTML 제작] ─── develop/{본인폴더}/에서 작업
     │
     ▼
  /deploy ─── develop/ → deploy/v{N}.html → 사이트 반영
     │
     ▼
[사이트 운영] ─── https://test.tunoinvest.com/v{N}
     │
     ▼ (필요 시)
  /archive ─── deploy/ → archive/ → 사이트에서 제거
     │
     ▼ (필요 시)
  /restore ─── archive/ → deploy/ → 사이트에 다시 올리기
```

---

## 에러 상황 정리

| 상황 | 대응 |
|------|------|
| develop/ 밖 파일 배포 시도 | "develop/ 폴더 안의 파일만 배포할 수 있어요" |
| HTML이 아닌 파일 배포 시도 | 무시하고 무시된 파일 목록 알려줌 |
| 배포할 파일 없음 | "배포할 HTML 파일이 없어요" |
| deploy/에 없는 파일 archive 시도 | "현재 배포되어 있지 않은 파일이에요" |
| archive/에 없는 파일 restore 시도 | "보관된 파일이 아니에요" |
| 이미 배포 중인 파일 restore 시도 | "이미 배포되어 있는 파일이에요" |
| git push 실패 | "다른 사람이 먼저 업로드한 내용이 있어요. 다시 시도할게요" |
| git pull 충돌 | "다른 사람의 작업과 겹치는 부분이 있어요. 개발팀에 문의해주세요" |
| 배포 반영 타임아웃 | "아직 반영이 안 됐어요. 30초 후에 다시 확인해볼게요" |
| 최종 반영 실패 | "개발팀에 문의해주세요" |
