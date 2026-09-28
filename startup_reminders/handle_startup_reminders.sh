#!/usr/bin/env sh

FILE="/home/bakso/.config/awesome/startup_reminders/startup_reminders.txt"

# check if file exists and has data
if [ -f "$FILE" ] && [ -s "$FILE" ]; then
    # prints out the file in a kitty terminal
    kitty --hold cat "$FILE" &

    sleep 10

    # clear the file
    > "$FILE"
fi
