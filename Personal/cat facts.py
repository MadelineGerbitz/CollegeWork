import requests as r
import time
import json
import pyperclip as p

try:
    while True:
        request = r.get("https://some-random-api.ml/facts/cat")
        print(request.json()['fact'])
        p.copy(request.json()['fact'])
        time.sleep(5)
except KeyboardInterrupt:
    pass

print("The program has stopped!")
