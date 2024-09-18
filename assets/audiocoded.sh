#!/bin/bash

# Navigate to the directory containing your videos
cd /var/www/backquest/videos

# Create a log file to store the audio encoding information
audio_info_log="audio_encoding_info.txt"

# Clear the log file at the start of the script
> "$audio_info_log"

# Loop through all mp4 files in the directory
for video_file in *.mp4; do
  echo "Processing file: $video_file" | tee -a "$audio_info_log"
  
  # Use ffmpeg to get information about the file, extracting only the audio streams
  ffmpeg -i "$video_file" 2>&1 | grep "Audio:" >> "$audio_info_log"
  
  echo "-------------------------------------" >> "$audio_info_log"
done

# Print message when done
echo "Audio encoding information has been saved to $audio_info_log"
