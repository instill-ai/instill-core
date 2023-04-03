# -*- coding: utf-8 -*-

import os
import json
import time

while True:
    cmd = "kubectl get pods -n vdp -o json"
    output = os.popen(cmd).read()
    data = json.loads(output)

    all_running = True
    for pod in data["items"]:
        for status in pod["status"]["containerStatuses"]:
            if not status.get("state", {}).get("running"):
                all_running = False
                break
        if not all_running:
            break

    if all_running:
        print("All pods are OK.")
        break

    print("Waiting..")
    time.sleep(5)
