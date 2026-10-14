#!/usr/bin/env ./venv/bin/python

from libre_link_up import LibreLinkUpClient  # have to do pip install libre-linkup-py AND pip install pydantic
import os
import time
import subprocess

DIR = f"{os.path.expanduser('~')}/.config/awesome/glucose"
username = ""
password = ""

try:
    with open(f"{DIR}/login_credentials.txt", "r") as f:
        for i, line in enumerate(f.readlines()):
            if i == 0:
                username = line.strip()
            elif i == 1:
                password = line.strip()
except FileNotFoundError:
    subprocess.run(["notify-send", "glucose_updater.py did not find the file containing the username and password for your LibreLinkUp account. Make sure that the file ~/.config/awesome/glucose/login_credentials.txt exists, that line 1 is of your email, and line 2 is of your password.", "--urgency=critical"])
    exit(1)


client = LibreLinkUpClient(
    username=username,
    password=password,
    url="https://api-eu.libreview.io",
    version="4.16.0",
)

client.login()

while True:

    # note that this data contains a bunch of readings at different times, but in this script only the most recent one is utilized, to see the most relevant value
    glucose_data = client.get_graph_readings()

    with open(f"{DIR}/current_reading.txt", "w") as f:
        f.write(str(int(glucose_data[-1].unix_timestamp)) + "\n" + str(glucose_data[-1].value))  # line 1: unix timestamp of when the value was measured. line 2: glucose value

    print("updated")
    time.sleep(60)  # wait for a minute before restarting the loop
