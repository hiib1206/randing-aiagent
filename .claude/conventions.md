# 커밋 컨벤션

모든 스킬에서 git commit 시 이 규칙을 따른다.

## Prefix 규칙

| prefix | 대상 | 서브타입 |
|--------|------|---------|
| `deploy:` | deploy/ 관련 변경 | 신규, 업데이트, 보관해제, 삭제 |
| `archive:` | archive/ 관련 변경 | 보관, 삭제 |
| `save:` | 그 외 (develop/, guideline/ 등) | 추가, 수정, 삭제 |

## 커밋 메시지 형식

하나의 push 안에서 종류가 섞이면 **prefix별로 커밋을 분리**한다.
이렇게 하면 `git log --grep="deploy:"` 등으로 이력 추적이 쉬워진다.

### 1개 파일

```
deploy: 신규 test1.html

신규
- test1.html
```

```
archive: 보관 old-page.html

보관
- old-page.html
```

```
save: 수정 develop/userA/test1.html

수정
- develop/userA/test1.html
```

### 여러 파일 (서브타입 1가지)

```
deploy: 업데이트 3개 파일

업데이트
- test1.html
- about.html
- pricing.html
```

### 여러 파일 (서브타입 섞임)

```
deploy: 3개 파일

신규
- test1.html
- pricing.html

업데이트
- about.html
```

## 커밋 순서

하나의 push에 여러 종류가 섞이면 아래 순서로 커밋한다:

1. `deploy:` (사이트 반영)
2. `archive:` (사이트에서 내림)
3. `save:` (작업 저장)
