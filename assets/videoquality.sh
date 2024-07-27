#!/bin/bash

cd /var/www/backquest/videos

for f in *.mp4; do
  echo "Processing $f file..."
  
  temp="temp_$f"
  
  # Run ffmpeg to scale the video to 720p, set framerate to 30fps, and adjust bitrate to 1.5M
  ffmpeg -i "$f" -vf "scale=-2:720" -r 30 -b:v 1.5M -c:a copy "$temp" > "$f.log" 2>&1

  # Check if ffmpeg succeeded
  if [ $? -eq 0 ]; then
    mv -f "$temp" "$f"
    echo "$f has been successfully converted to 720p, 30fps, and adjusted bitrate."
  else
    echo "An error occurred with $f. Check the log file for details: $f.log"
    rm -f "$temp"  
  fi
done
