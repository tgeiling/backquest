#!/bin/bash

# Directory containing the video files
video_dir="/var/www/backquest/videos"

# Log file to capture the process
logfile="audio_normalization_log.txt"

# Clear the log file at the start of the script
> "$logfile"

# Iterate over all .mp4 files in the directory
for video_file in "$video_dir"/*.mp4; do
  # Extract filename without the directory
  base_name=$(basename "$video_file")
  
  # Temporary output file for normalization
  temp_file="$video_dir/temp_$base_name"
  
  echo "Processing file: $video_file" | tee -a "$logfile"

  # Re-encode only the audio stream to ensure consistency, copy video stream
  ffmpeg -i "$video_file" \
    -c:v copy \
    -c:a aac \
    -b:a 192k \
    -ac 2 \
    -ar 44100 \
    "$temp_file" > "$base_name.log" 2>&1

  # Check if ffmpeg succeeded
  if [ $? -eq 0 ]; then
    # Replace the original file with the normalized one
    mv -f "$temp_file" "$video_file"
    echo "Successfully normalized and replaced: $video_file" | tee -a "$logfile"
  else
    echo "Error normalizing audio for: $video_file. Check $base_name.log for details." | tee -a "$logfile"
    rm -f "$temp_file"  # Remove temp file if there was an error
  fi
done

echo "Audio normalization process completed." | tee -a "$logfile"
