#!/bin/bash  -e

# Result is 1 if expires within the time
# 1 day left
MAX_LEFT=86400

#MAX_LEFT give or take 10 %
RENEW_TIME=$(($MAX_LEFT - ($MAX_LEFT / 100 * ($RANDOM % 10 ))))

echo | openssl s_client -connect ${1} 2>/dev/null | openssl x509 -checkend ${RENEW_TIME}  -noout
