
#!/bin/bash

# Function to fetch updates from the bot
fetch_updates() {
  local bot_token="$1"
  curl -s -X GET "https://api.telegram.org/bot${bot_token}/getUpdates"
}

# Function to check if the update list is empty
is_empty_updates() {
  local updates="$1"
  [[ $(echo "$updates" | jq '.result | length') -eq 0 ]]
}

# Function to check if a value is in an array
contains() {
  local n=$#
  local value=${!n}
  for ((i=1; i < $#; i++)); do
    if [ "${!i}" == "${value}" ]; then
      return 0
    fi
  done
  return 1
}

# Function to get the last update_id
get_last_update_id() {
  local updates="$1"
  echo "$updates" | jq -r ".result[$(echo "$updates" | jq '.result | length') - 1].update_id"
}

# Function to send request with offset
send_offset_request() {
  local bot_token="$1"
  local next_offset="$2"
  curl -s -X GET "https://api.telegram.org/bot${bot_token}/getUpdates?offset=${next_offset}"
}

# Function to send message via bot
send_message() {
  local bot_token="$1"
  local chat_id="$2"
  local text="$3"
  curl -s -X POST "https://api.telegram.org/bot${bot_token}/sendMessage" \
    -d "chat_id=${chat_id}" \
    -d "text=$(echo -e "${text}")"
}
