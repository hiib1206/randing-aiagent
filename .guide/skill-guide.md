# Claude 스킬 만들기 가이드

> 이 가이드는 Claude Code에서 스킬을 만들 때 참고하는 레퍼런스다.
> 아래 예시들은 작성 패턴을 보여주기 위한 것이며, 스킬의 목적에 맞게 본문 구조를 자유롭게 설계하라.

## 1. 파일 구조

최소 구조:
```
skill-name/
└── SKILL.md          ← 이것만 있으면 스킬
```

확장 구조 (내용이 많을 때):
```
skill-name/
├── SKILL.md              ← 핵심 지시 + 어떤 파일을 언제 읽을지 안내
├── references/           ← 상세 참조 문서 (필요할 때만 로드됨)
│   ├── detail-a.md
│   └── detail-b.md
├── scripts/              ← 실행 스크립트 (코드 자체는 컨텍스트에 안 올라감, 출력만 소비)
└── assets/               ← 템플릿, 아이콘 등
```

---

## 2. SKILL.md 골격

```markdown
---
name: skill-name
description: >
  (Step 4 참고)
---

(여기부터 본문 — Step 5 참고)
```

`---`로 감싼 윗부분 = **frontmatter** (메타데이터)
아랫부분 = **본문** (지시사항)

---

## 3. frontmatter 작성 참고

### name 규칙 (공식)
- 최대 64자
- 소문자, 숫자, 하이픈(`-`)만 사용
- 동명사(verb + -ing) 형태 권장: `code-reviewing`, `generating-reports`
- 이 이름이 `/slash-command`가 된다

### description 규칙 (공식)
- **최대 200자**
- **3인칭**으로 작성 (Claude 시스템 프롬프트에 주입되므로)
- "what + when + trigger keywords" 세 가지를 포함

**공식:**
```
① 이 스킬이 뭘 하는지 (한 문장)
② 언제 써야 하는지 — "Use when..." (한 문장)
③ 트리거 키워드/문구 (한/영 모두)
```

**나쁜 예:**
```yaml
description: Code review tool
```

**좋은 예:**
```yaml
description: >
  Reviews code for bugs, security issues, and best practices.
  Use when user asks to "review code", "check this code",
  "코드 리뷰해줘", or "PR review".
```

### 핵심: Claude는 스킬을 안 쓰는 쪽으로 기울어지는 경향이 있다 (undertrigger)

공식 문서에서 description을 "약간 적극적(pushy)"으로 쓰라고 권장한다. 관련 키워드가 나오면 트리거되도록 범위를 넓혀라.

---

## 4. 본문 작성 원칙

### 4-1. Claude는 이미 똑똑하다 — 아는 것을 다시 설명하지 마라

공식 가이드의 핵심 원칙: **Claude가 이미 아는 것은 넣지 않는다.**

본문에 넣을 내용을 고를 때 스스로에게 물어봐라:
- "Claude가 이걸 정말 모르나?"
- "이 설명이 토큰 비용만큼의 가치가 있나?"

### 4-2. 명령형으로 쓴다

"~하세요"보다 "~하라"가 효과적이다.

### 4-3. MUST 남발 대신 이유를 설명하라

왜 중요한지를 알려주면 Claude가 맥락을 이해하고 더 잘 따른다.

### 4-4. 본문 500줄 이하 유지

넘으면 references/ 폴더로 분리하고, SKILL.md에서 "이런 상황에서는 references/xxx.md를 읽어라"고 안내한다.

### 4-5. 자유도를 목적에 맞게 조절하라 (공식 권장)

| 자유도 | 언제 | 예시 |
|--------|------|------|
| **높음** (텍스트 가이드라인) | 여러 접근이 다 유효할 때 | 코드 리뷰, 글쓰기 스타일 |
| **중간** (pseudo-code/파라미터) | 선호 패턴은 있지만 유연성 필요 | 리포트 생성, API 호출 |
| **낮음** (정확한 스크립트) | 순서가 틀리면 깨지는 작업 | DB 마이그레이션, 배포 |

### 4-6. 예시를 포함하라

Input → Output 쌍을 넣으면 Claude가 의도를 훨씬 정확하게 이해한다.

```markdown
**Example:**
Input: Added user authentication with JWT tokens
Output: feat(auth): implement JWT-based authentication
```

### 4-7. 출력 포맷이 필요하면 명시하라

스킬 목적에 따라 자유롭게 설계한다. 정해진 포맷은 없다.

```markdown
## Output Format
항상 아래 구조를 따르라:
### 제목
### 본문
### 결론
```

---

## 5. 3단계 로딩 (Progressive Disclosure)

| 단계 | 내용 | 로드 시점 |
|------|------|-----------|
| 1단계 | name + description (~100토큰) | 항상 시스템 프롬프트에 있음 |
| 2단계 | SKILL.md 본문 | 스킬 트리거 시 |
| 3단계 | references/, scripts/ 등 | 본문에서 참조할 때만 |

스킬을 100개 설치해도 평소에는 1단계만 올라가므로 부담 없다.
scripts/는 실행만 되고 코드 자체가 컨텍스트에 올라가지 않는다 — 출력만 토큰을 소비한다.

---

## 6. 테스트

1. 스킬 작성 후 2~3개 현실적인 테스트 프롬프트를 만든다
2. 스킬이 잘 트리거되는지 확인
3. 출력이 기대와 맞는지 확인
4. 안 되면 description이나 본문을 수정하고 반복
5. 사용할 모델 전부에서 테스트하라 (Haiku에서 되면 Opus에서도 됨, 반대는 아님)

---

## 7. 전체 작성 예시

> 아래는 "코드 리뷰" 스킬의 예시일 뿐이다. 다른 목적의 스킬이라면 본문 구조를 목적에 맞게 완전히 다르게 설계하라.

```markdown
---
name: code-reviewing
description: >
  Reviews code for bugs, security issues, and best practices.
  Use when user asks to "review code", "check this code",
  "코드 리뷰", "이거 검토해줘", or "PR review".
---

# Code Review

코드 리뷰 시 아래 순서대로 점검하라:

## 1. Bugs & Logic Errors
- Off-by-one errors
- Null/undefined handling
- Race conditions

## 2. Security
- Input validation
- SQL injection risk
- Hardcoded secrets

## 3. Readability
- Clear variable names
- Function length (30줄 이하 권장)
- 복잡한 로직에 주석

## Output Format

### Summary
한 문장으로 전체 평가.

### Issues
각 이슈를 severity로 분류: 🔴 Critical, 🟡 Warning, 🟢 Suggestion

### Positives
최소 하나 긍정적인 점을 언급.
```

---

## 8. 요약 체크리스트

- [ ] SKILL.md 파일이 있는 폴더를 만들었는가
- [ ] name: 소문자+하이픈, 64자 이내, 동명사 형태
- [ ] description: 200자 이내, 3인칭, what+when+keywords, 약간 적극적으로
- [ ] 본문: Claude가 이미 아는 건 빼고, 명령형, 이유 설명, 500줄 이하
- [ ] 자유도: 스킬 목적에 맞게 높음/중간/낮음 선택
- [ ] 예시: Input → Output 쌍 포함
- [ ] 큰 내용은 references/로 분리하고 SKILL.md에서 안내
- [ ] 테스트: 2~3개 프롬프트로 트리거 + 출력 확인