import datetime
import pyautogui
import random
import time

loop = 0

while True:
    loop += 1
    sleeptime = random.randint(200, 300)
    pyautogui.press("numlock")
    print(f"[{loop}] {datetime.datetime.now()} {sleeptime=}")
    time.sleep(sleeptime)
