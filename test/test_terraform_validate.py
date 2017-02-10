#!/usr/bin/env python3
import os
import subprocess
import shlex

exclude = set(['.idea', '.git', 'scripts', '.terraform'])

for root, dirs, files in os.walk('.', topdown=True):
    dirs[:] = [d for d in dirs if d not in exclude]
    for dir in dirs:
        path = os.path.join(root, dir)
        if any([f for f in os.listdir(path) if f.endswith('.tf')]):
            prefix = '==> checked Terraform module @ {0} '.format(path)
            res = subprocess.call(shlex.split('terraform validate {0}'.format(path)))
            res = 'OK' if res == 0 else 'FAIL'

            padding = 80 - len(prefix)
            print(prefix + res.rjust(padding, ' '))
