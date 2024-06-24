#!/bin/bash

# Source bot settings and common functions
source bot_settings.sh
source common_functions.sh

# Fetch updates from the bot
updates=$(fetch_updates "$BOT_TOKEN")

# Check if the update list is not empty
if is_empty_updates "$updates"; then
  echo "No new updates."
  exit 0
fi

# Counter for new messages
new_message_count=0

# Process all updates
for i in $(seq 0 $(($(echo "$updates" | jq '.result | length') - 1))); do
  # Extract message information
  message=$(echo "$updates" | jq -r ".result[$i].message")
  from_id=$(echo "$message" | jq -r '.from.id')
  document=$(echo "$message" | jq -r '.audio')

  # Check if the sender is in the allowed list
  if [ "$document" != "null" ] && contains "${ALLOWED_USER_IDS[@]}" "$from_id"; then
    file_id=$(echo "$document" | jq -r '.file_id')
    file_name=$(echo "$document" | jq -r '.file_name')
    
    # Extract file information
    file_info=$(curl -s -X GET "https://api.telegram.org/bot${BOT_TOKEN}/getFile?file_id=${file_id}")
    file_path=$(echo "$file_info" | jq -r '.result.file_path')

    # Check filepath
    if [ -n "$file_path" ]; then
      # Download file
      curl -s -o "${FILE_DIR}${file_name}" "https://api.telegram.org/file/bot${BOT_TOKEN}/${file_path}"
      if [ $? -eq 0 ]; then
        echo "${file_name} downloaded.."
        ((new_message_count++))
        send_message "$BOT_TOKEN" "$from_id" "${file_name} downloaded."
      else
        echo "Download error for ${file_name}."
        send_message "$BOT_TOKEN" "$from_id" "Download error for ${file_name}."
      fi
    else
      echo "Get path for $file_id error. Skiping."
      send_message "$BOT_TOKEN" "$from_id" "Get path for $file_id error. Skiping."
    fi
  fi
done

if [ $new_message_count -gt 0 ]; then
  echo "Messages processed: $new_message_count"
else
  echo "No new messages found to process."
fi

# Get the last update_id
last_update_id=$(get_last_update_id "$updates")

# Sending a request with offset equal to the last update_id plus one
next_offset=$((last_update_id + 1))
response=$(send_offset_request "$BOT_TOKEN" "$next_offset")

# Check result
if is_empty_updates "$response"; then
  echo "All messages marked as read."
  send_message "$BOT_TOKEN" "$from_id" "All messages marked as read."
else
  echo "Error with offset."
  send_message "$BOT_TOKEN" "$from_id" "Error with offset."
fi
