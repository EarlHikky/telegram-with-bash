# Telegram Bot Script for Downloading Files

Made for control robrock v1 via Telegram.
This script uses a Telegram bot to download files sent by specific users. The script checks for updates from the bot, processes new messages containing files, and downloads the files to a specified directory.

## Requirements

To run this script, you need to have the following installed:

- `bash=5.2.26`
- `curl=8.8.0`
- `jq=1.7.1` 

## Configuration

1. **Set your BOT_TOKEN**

   Replace the placeholder with your actual Telegram bot token.

   ```bash
   BOT_TOKEN="your_bot_token_here"
   ```

2. **Set the list of allowed user IDs**

   Replace the placeholders with the user IDs you want to allow. Add more user IDs as needed.

   ```bash
   ALLOWED_USER_IDS=("user_id1" "user_idN")  
   ```

3. **Set the output directory**

   Specify the directory where you want the downloaded files to be saved.

   ```bash
   OUTPUT_FILE_DIR="/path/to/your/directory/"
   ```

## Usage

1. Save the script to a file, for example, `telegram_bot.sh`.
2. Make the script executable:

   ```bash
   chmod +x telegram_bot.sh
   ```

3. Run the script:

   ```bash
   ./telegram_bot.sh
   ```

This script will fetch updates from your Telegram bot, process new messages containing files from allowed users, download the files to the specified directory, and mark the messages as read.
