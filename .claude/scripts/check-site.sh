#!/bin/bash
# 배포/보관 후 사이트 반영 확인 스크립트
# 사용법:
#   bash .claude/scripts/check-site.sh <URL> <확인값>
#
# 확인값이 "404"이면 → 해당 URL이 404 응답을 반환하면 성공 (보관용)
# 확인값이 문자열이면 → 응답 본문에 해당 문자열이 포함되면 성공 (배포용)
#
# 예:
#   bash .claude/scripts/check-site.sh "https://test.tunoinvest.com/test.html" "deploy-id: 2026-03-23T20:05:30+09:00"  (배포용)
#   bash .claude/scripts/check-site.sh "https://test.tunoinvest.com/test.html" "404"  (보관용)

URL="$1"
CHECK="$2"
INTERVAL=5
MAX_WAIT=90
RETRY_WAIT=30

if [ -z "$URL" ] || [ -z "$CHECK" ]; then
  echo "ERROR: URL과 확인값을 입력해주세요."
  echo "사용법: bash check-site.sh <URL> <확인값>"
  exit 1
fi

elapsed=0

while [ $elapsed -lt $MAX_WAIT ]; do
  if [ "$CHECK" = "404" ]; then
    status=$(curl -s -L -o /dev/null -w "%{http_code}" "$URL")
    if [ "$status" = "404" ]; then
      echo "SUCCESS"
      exit 0
    fi
  else
    body=$(curl -s -L "$URL")
    if echo "$body" | grep -q "$CHECK"; then
      echo "SUCCESS"
      exit 0
    fi
  fi

  sleep $INTERVAL
  elapsed=$((elapsed + INTERVAL))
done

# 90초 초과 → 30초 후 재시도
echo "RETRY"
sleep $RETRY_WAIT

if [ "$CHECK" = "404" ]; then
  status=$(curl -s -L -o /dev/null -w "%{http_code}" "$URL")
  if [ "$status" = "404" ]; then
    echo "SUCCESS"
    exit 0
  fi
else
  body=$(curl -s -L "$URL")
  if echo "$body" | grep -q "$CHECK"; then
    echo "SUCCESS"
    exit 0
  fi
fi

echo "FAIL"
exit 1
