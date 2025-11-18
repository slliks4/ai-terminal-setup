import json
import time
import os

config_path = os.path.expanduser("~/ai/config/sessions.json")


def watch():
    last = None
    while True:
        try:
            with open(config_path) as f:
                data = f.read()
            if data != last:
                print("🔄 Shared config updated!")
                print(json.dumps(json.loads(data), indent=2))
                last = data
        except Exception as e:
            print("Error:", e)
        time.sleep(2)


if __name__ == "__main__":
    watch()
