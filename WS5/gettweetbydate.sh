#!/bin/bash
# gettweetbydate.sh
# Usage: ./gettweetbydate.sh YY-MM-DD

if [ $# -ne 1 ]; then
  echo "Usage: $0 YY-MM-DD"
  exit 1
fi

DATE=$1
mkdir -p ~/TWEETS
grep "$DATE" *.txt > ~/TWEETS/$DATE.out 2>/dev/null
echo "Tweets saved to ~/TWEETS/$DATE.out"
