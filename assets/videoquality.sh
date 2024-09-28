#!/bin/bash

# Directory containing the video files
video_dir="/var/www/backquest/videos/test"

# Process each video
for video_file in "$video_dir"/*.mp4; do
  # Get the base name of the file
  base_name=$(basename "$video_file")
  
  # Create a temporary file path
  temp_file="$video_dir/temp_$base_name"

  echo "Processing $video_file (using a temporary file first)"

  # Apply h264_mp4toannexb filter and save to the temporary file
  ffmpeg -i "$video_file" \
    -c:v copy \
    -bsf:v h264_mp4toannexb \
    -c:a copy \
    -y "$temp_file"  # The -y flag forces overwrite of the temporary file if it exists
  
  # Check if ffmpeg succeeded
  if [ $? -eq 0 ]; then
    # Replace the original file with the temporary file
    mv "$temp_file" "$video_file"
    echo "Successfully processed and replaced: $video_file"
  else
    echo "Error processing: $video_file"
    rm -f "$temp_file"  # Remove the temp file in case of error
  fi
done

echo "Processing completed for all videos."
