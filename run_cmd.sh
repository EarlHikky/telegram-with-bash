#!/bin/bash

# Source bot settings and common functions
source bot_settings.sh
source common_functions.sh

# Temp filename
temp_cron="mycron"

# Function for comment or uncomment string in crontab
toggle_crontab_entry() {
    local action="$1"
    local entry="/mnt/data/random_phrases/phrases.sh"  # String for replace crontab

    # Export current crontab
    crontab -l > $temp_cron
    
    # Check action
    if [ "$action" == "disable" ]; then
        # Comment string
        sed -i "s|^.*$entry|#&|" $temp_cron
        echo "Commented: $entry"
    elif [ "$action" == "enable" ]; then
        # Uncomment string
        sed -i "s|^#\(.*$entry\)|\1|" $temp_cron
        echo "Uncommented: $entry"
    else
        echo "Wrong action. Use 'enable' or 'disable'."
        rm $temp_cron  # Remove the tempfile
        return 1
    fi
    
    # Update crontab
    crontab $temp_cron
    
    # Remove the tempfile
    rm $temp_cron

    # Send the message to the user
    send_message "$BOT_TOKEN" "$from_id" "$action success"
}

# Fetch updates from the bot
updates=$(fetch_updates "$BOT_TOKEN")

# Check if the update list is not empty
if is_empty_updates "$updates"; then
  echo "No new updates."
  exit 0
fi

# Process all updates
for i in $(seq 0 $(($(echo "$updates" | jq '.result | length') - 1))); do
  # Extract message information
  message=$(echo "$updates" | jq -r ".result[$i].message")
  from_id=$(echo "$message" | jq -r '.from.id')
  text=$(echo "$message" | jq -r '.text')

  # Check if the sender is in the allowed list
  if contains "${ALLOWED_USER_IDS[@]}" "$from_id"; then
    # Execute the command and capture the output
    if [ "$text" == "/disable" ]; then
      toggle_crontab_entry "disable"
    elif [ "$text" == "/enable" ]; then
      toggle_crontab_entry "enable"
    elif [ "$text" == "/clear" ]; then
      rm -r /mnt/data/random_phrases/phrases/*
      send_message "$BOT_TOKEN" "$from_id" "clear success"
    elif [ "$text" == "/files" ]; then
      output=$(ls "$FILE_DIR")
      send_message "$BOT_TOKEN" "$from_id" "Output:\n$output"
    elif [[ "$text" =~ ^/delete ]]; then
      # Extract the SOMIFILE part of the command
      SOMEFILE=$(echo "$text" | cut -d ' ' -f 2)
      rm "$FILE_DIR$SOMEFILE"
      send_message "$BOT_TOKEN" "$from_id" "$SOMEFILE deleted"
    else
      output=$(eval "$text" 2>&1)
      send_message "$BOT_TOKEN" "$from_id" "Command: $text\nOutput:\n$output"
    fi
  else
    send_message "$BOT_TOKEN" "$from_id" "You are not authorized to execute commands on this server."
  fi
done

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
