#!/usr/bin/env sh

FILE="/home/bakso/.config/awesome/startup_reminders/startup_reminders.txt"

# check if file exists and has data
if [ -f "$FILE" ] && [ -s "$FILE" ]; then
    # open in gedit
    gedit "$FILE" &

    sleep 5

    # clear the file
    > "$FILE"
fi
