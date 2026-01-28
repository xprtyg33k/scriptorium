#!/usr/bin/env python3
import json

with open('index.html', 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

start = content.find('const EMBEDDED_SCHEDULE = {')
print(f'Start of assignment: {start}')

# The JSON starts right after 'const EMBEDDED_SCHEDULE = '
json_start = start + len('const EMBEDDED_SCHEDULE = ')
print(f'JSON content starts at: {json_start}')
print(f'First char: {repr(content[json_start])}')

# Find the closing };
# We need to be careful - this could match other }; in the file
# But we're looking for the one that closes the main object

# The main object closes at 344782
main_close = 344782
print(f'\nMain object closes at: {main_close}')
print(f'That character: {repr(content[main_close])}')

# So the JSON is from json_start to main_close+1
json_content = content[json_start:main_close+1]
print(f'JSON length: {len(json_content)}')
print(f'Last 100 chars: {repr(json_content[-100:])}')

# Try to parse it
try:
    obj = json.loads(json_content)
    print('\nSUCCESS! JSON is valid!')
    print(f'Talks count: {len(obj.get("talks", []))}')
except json.JSONDecodeError as e:
    print(f'\nJSON Error: {e}')
    print(f'Position: {e.pos}')
    print(f'Context: {repr(json_content[e.pos-50:e.pos+50])}')
