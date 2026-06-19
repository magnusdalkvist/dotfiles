#!/bin/bash
input=$(cat)

make_bar() {
  local pct=$1 width=10
  local filled=$(( pct * width / 100 ))
  local empty=$(( width - filled ))
  local bar=""
  [ "$filled" -gt 0 ] && printf -v f "%${filled}s" && bar="${f// /▓}"
  [ "$empty"  -gt 0 ] && printf -v e "%${empty}s"  && bar="${bar}${e// /░}"
  echo "$bar"
}

pct_color() {
  local pct=$1
  if   [ "$pct" -lt 33 ]; then echo "\033[32m"
  elif [ "$pct" -lt 75 ]; then echo "\033[33m"
  else                          echo "\033[31m"
  fi
}

RESET="\033[0m"

# Context window
TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
CTX_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

if   [ "$TOKENS" -lt 20000 ]; then CTX_COLOR="\033[32m"
elif [ "$TOKENS" -lt 80000 ]; then CTX_COLOR="\033[33m"
else                                CTX_COLOR="\033[31m"
fi

CTX_BAR=$(make_bar "$CTX_PCT")
OUT="${CTX_COLOR}ctx:${CTX_BAR} ${CTX_PCT}% | ${TOKENS}tok${RESET}"

# 5-hour session limit
SESSION_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' | cut -d. -f1)
if [ -n "$SESSION_PCT" ]; then
  S_COLOR=$(pct_color "$SESSION_PCT")
  S_BAR=$(make_bar "$SESSION_PCT")
  OUT="${OUT}  ${S_COLOR}5h:${S_BAR} ${SESSION_PCT}%${RESET}"
fi

# 7-day weekly limit
WEEK_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' | cut -d. -f1)
if [ -n "$WEEK_PCT" ]; then
  W_COLOR=$(pct_color "$WEEK_PCT")
  W_BAR=$(make_bar "$WEEK_PCT")
  OUT="${OUT}  ${W_COLOR}7d:${W_BAR} ${WEEK_PCT}%${RESET}"
fi

echo -e "$OUT"
