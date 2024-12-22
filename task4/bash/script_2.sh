#!/bin/bash

FLAGSTAT_RESULT="output/flagstat.txt"
QUALITY_THRESHOLD=90

echo "Checking the percentage of mapping..."
MAPPED_PERCENT=$(grep "mapped (" $FLAGSTAT_RESULT | awk '{print $5}' | tr -d '()%mapped')

if [ $(echo -e "\n$MAPPED_PERCENT > $QUALITY_THRESHOLD" | bc) -eq 1 ]; then
  echo -e "\n\U0001F605 OK! - Percentage of mapping: $MAPPED_PERCENT%"
else
  echo -e "\n\U0001F61D not OK... - Percentage of mapping is below the threshold: $MAPPED_PERCENT%"
fi
