#!/bin/bash

cd /var/www/backquest/videos

# Log file to capture the entire process
logfile="processing_log.txt"

# Clear the log file at the start of the script
> "$logfile"

# Iterate over all .mp4 files in the directory
for f in *.mp4; do
  echo "Processing file: $f" | tee -a "$logfile"
  
  # Check if the file name is greater than or equal to "0106.mp4"
  if [[ "$f" > "0101.mp4" ]]; then
    echo "Processing $f file..." | tee -a "$logfile"
    
    temp="temp_$f"
    
    # Run ffmpeg to scale the video to 720p, set framerate to 30fps, and adjust bitrate to 1.5M
    ffmpeg -i "$f" -vf "scale=-2:720" -r 30 -b:v 1.5M -c:a copy "$temp" > "$f.log" 2>&1

    # Check if ffmpeg succeeded
    if [ $? -eq 0 ]; then
      mv -f "$temp" "$f"
      echo "$f has been successfully converted to 720p, 30fps, and adjusted bitrate." | tee -a "$logfile"
    else
      echo "An error occurred with $f. Check the log file for details: $f.log" | tee -a "$logfile"
      rm -f "$temp"  
    fi
  else
    echo "Skipping $f file..." | tee -a "$logfile"
  fi
done
