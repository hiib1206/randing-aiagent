# 테스트 시나리오

각 테스트는 체크박스로 관리. 통과하면 체크.

---

## 1. 기본 흐름 (Happy Path)

전체 라이프사이클을 순서대로 테스트한다.

### T-01. 첫 배포

- [ ] `develop/jeycorp1216/`에 HTML 파일이 있는 상태에서 `/deploy develop/jeycorp1216` 실행
- [ ] v번호가 v1으로 부여되는지 확인
- [ ] 확인 메시지에 `test2.html → v1.html → https://test.tunoinvest.com/v1` 형식 표시되는지
- [ ] 사용자 확인 후 deploy/v1.html 생성되는지
- [ ] deploy/v1.html의 `<head>`에 `deploy-id` 주석 삽입되는지
- [ ] develop/ 원본 파일은 그대로 남아있는지
- [ ] `https://test.tunoinvest.com/v1` 접속 가능한지

### T-02. 두 번째 배포

- [ ] 다른 HTML 파일을 `/deploy`로 배포
- [ ] v2로 부여되는지 확인 (v1이 아님)
- [ ] `https://test.tunoinvest.com/v2` 접속 가능한지

### T-03. 사이트에서 내리기

- [ ] `/archive v1.html` 실행
- [ ] 확인 메시지에 `v1.html (https://test.tunoinvest.com/v1)` 표시되는지
- [ ] deploy/v1.html이 사라지고 archive/v1.html로 이동되는지
- [ ] `https://test.tunoinvest.com/v1` 접속 불가(404)인지

### T-04. 내린 후 새 배포 시 번호

- [ ] v1을 archive한 상태에서 새 파일 배포
- [ ] v3이 부여되는지 (v1 재사용 안 함)
- [ ] deploy/ + archive/ 스캔으로 최대값(v2) + 1 = v3 확인

### T-05. 내린 파일 다시 올리기

- [ ] `/restore v1.html` 실행
- [ ] 확인 메시지에 `v1.html → https://test.tunoinvest.com/v1` 표시되는지
- [ ] archive/v1.html이 사라지고 deploy/v1.html로 이동되는지
- [ ] `https://test.tunoinvest.com/v1` 다시 접속 가능한지

### T-06. 규칙 안내

- [ ] `/guide` 실행
- [ ] 5가지 규칙이 모두 표시되는지
- [ ] `/deploy`, `/archive`, `/restore`, `/guide` 스킬 안내 포함되는지

---

## 2. 여러 파일 처리

### T-07. 폴더 전체 배포 (여러 HTML)

- [ ] develop/ 폴더에 HTML 파일 2~3개 넣고 폴더 경로로 `/deploy`
- [ ] 각 파일에 순차 v번호 부여되는지 (v4, v5, v6...)
- [ ] 확인 메시지에 모든 파일 목록 표시되는지
- [ ] deploy/에 모든 파일 생성되는지

### T-08. 여러 파일 archive

- [ ] `/archive`로 여러 파일 지정
- [ ] 확인 메시지에 모든 파일 목록 표시되는지
- [ ] 모두 archive/로 이동되는지

### T-09. 여러 파일 restore

- [ ] `/restore`로 여러 파일 지정
- [ ] 모두 deploy/로 복원되는지
- [ ] 각각 원래 v번호 유지되는지

---

## 3. v번호 체계

### T-10. 빈 상태에서 첫 배포

- [ ] deploy/, archive/ 둘 다 비어있을 때 → v1 부여

### T-11. 중간 번호 archive 후 배포

- [ ] deploy/에 v1, v2, v3 있을 때 v2를 archive
- [ ] 새 배포 → v4 부여 (v2 재사용 안 함)

### T-12. 전부 archive 후 배포

- [ ] deploy/ 비어있고 archive/에 v1, v2, v3 있을 때
- [ ] 새 배포 → v4 부여 (archive 스캔해서 최대값 3 + 1)

### T-13. restore 후 배포

- [ ] v3을 restore → deploy/v3.html 복원
- [ ] 새 배포 → v번호가 현재 최대값 + 1인지 확인

---

## 4. 에러 / 예외 처리

### T-14. develop/ 밖 파일 배포

- [ ] `/deploy deploy/../something.html` 또는 루트 파일 지정
- [ ] "develop/ 폴더 안의 파일만 배포할 수 있어요" 메시지 표시되는지

### T-15. HTML 아닌 파일 배포

- [ ] develop/ 폴더에 .css, .js, .png 등 넣고 배포
- [ ] HTML만 배포되고 나머지는 무시 + 무시 목록 표시되는지

### T-16. 빈 폴더 배포

- [ ] HTML 없는 빈 폴더로 `/deploy`
- [ ] "배포할 HTML 파일이 없어요" 메시지

### T-17. deploy/에 없는 파일 archive

- [ ] `/archive v99.html` (존재하지 않는 파일)
- [ ] "현재 배포되어 있지 않은 파일이에요" 메시지

### T-18. archive/에 없는 파일 restore

- [ ] `/restore v99.html` (존재하지 않는 파일)
- [ ] "보관된 파일이 아니에요" 메시지

### T-19. 이미 배포 중인 파일 restore

- [ ] deploy/v1.html이 있는 상태에서 archive/v1.html도 있다고 가정
- [ ] (실제로는 발생 불가하지만) "이미 배포되어 있는 파일이에요" 메시지

### T-20. 파일명 미지정 시 restore

- [ ] `/restore` (파일명 없이)
- [ ] archive/ 목록 보여주고 선택하게 하는지

---

## 5. Git 관련

### T-21. pull 먼저 실행

- [ ] deploy, archive, restore 모든 스킬에서 push 전 `git pull origin main` 실행하는지

### T-22. push 실패 시 재시도

- [ ] push 거부됐을 때 "다른 사람이 먼저 업로드한 내용이 있어요" 안내 후 pull → 재push

### T-23. 충돌 발생

- [ ] pull 시 conflict 발생하면 "개발팀에 문의해주세요" 안내 후 중단하는지

---

## 6. 비개발자 UX

### T-24. 기술 용어 사용 안 함

- [ ] 모든 스킬에서 git, commit, push, branch 같은 용어가 사용자에게 노출되지 않는지
- [ ] "배포 완료", "사이트에서 내렸어요" 같은 쉬운 말 사용하는지

### T-25. 에러 메시지

- [ ] 에러 발생 시 기술적 메시지 그대로 노출하지 않는지
- [ ] 쉬운 설명 + 대응 방법 안내하는지

### T-26. 커밋 메시지 형식

- [ ] deploy: `deploy: v1` 또는 `deploy: v4, v5`
- [ ] archive: `archive: v1.html`
- [ ] restore: `restore: v1`

---

## 7. 통합 시나리오

### T-27. 전체 라이프사이클

```
1. HTML 작성 (develop/)
2. /deploy → v1 배포 → URL 확인
3. /deploy → v2 배포 → URL 확인
4. /archive v1 → 사이트에서 내림 확인
5. /deploy → v3 배포 (v1 재사용 안 함 확인)
6. /restore v1 → 다시 올림 확인
7. 현재 상태: deploy/v1, v2, v3 | archive/ 비어있음
```

- [ ] 위 흐름 전체가 끊김 없이 동작하는지

### T-28. archive → restore 반복

```
1. /archive v1 → archive/v1.html
2. /restore v1 → deploy/v1.html
3. /archive v1 → archive/v1.html (다시)
4. /restore v1 → deploy/v1.html (다시)
```

- [ ] 반복해도 문제없이 동작하는지
- [ ] v번호 체계에 영향 없는지

### T-29. 동시 작업 시뮬레이션

- [ ] 다른 사람이 먼저 push한 상황에서 deploy 시도
- [ ] pull → 충돌 없으면 자동 재push 되는지
- [ ] 충돌 있으면 "개발팀에 문의해주세요" 후 중단하는지
