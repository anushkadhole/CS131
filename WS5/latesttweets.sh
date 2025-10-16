#!/bin/bash
# latesttweets.sh - append new tweets and delete them

TWEET_DIR=~/TWEETS
ALL_OUT=~/ALLTWEETS.out

find $TWEET_DIR -type f -name "*.out" -mmin -5 | while read file; do
  cat "$file" >> $ALL_OUT
  rm -f "$file"
done
