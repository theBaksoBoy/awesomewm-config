#!/usr/bin/env python3

import os

conflict_paths: set[str] = set()

for dirpath, dirnames, filenames in os.walk(os.path.expanduser("~/notes/")):
    for filename in filenames:
        if ".sync-conflict" in filename:
            directory_with_conflict = '~' + dirpath[len(os.path.expanduser('~')):]
            directory_with_conflict += '/' if directory_with_conflict[-1] != '/' else ''
            conflict_paths.add(directory_with_conflict)

if conflict_paths:
    print('\n'.join(conflict_paths))
