#!/bin/bash

cd /var/www/backquest/videos

for f in *.mp4; do
  echo "Processing $f file..."
  
  temp="temp_$f"
  
  ffmpeg -i "$f" -vf "scale=-2:1080" -c:a copy "$temp"

  if [ $? -eq 0 ]; then
    mv -f "$temp" "$f"
    echo "$f has been successfully converted to 1080p."
  else
    echo "An error occurred with $f. It has not been replaced."
    rm -f "$temp"  
  fi
done