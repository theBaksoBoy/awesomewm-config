#!/usr/bin/env sh

FILE="/home/bakso/.config/awesome/startup_reminders/startup_reminders.txt"

# check if file exists and has data
if [ -f "$FILE" ] && [ -s "$FILE" ]; then
    # open the file in vim in a kitty terminal
    kitty -- vim "$FILE" &

    sleep 5

    # clear the file
    > "$FILE"
fi
