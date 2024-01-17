#solves [Error: EPERM: operation not permitted in windows

import os

# Find all Node.js processes
pids = os.popen('tasklist /v /fi "imagename eq node.exe" /fo csv').read().strip().split('\n')[1:]
pids = [int(pid.split(',')[1].replace('"', '')) for pid in pids]

# Kill all Node.js processes
for pid in pids:
    os.system(f'taskkill /pid {pid} /f')
