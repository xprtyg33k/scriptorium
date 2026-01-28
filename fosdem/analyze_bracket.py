#!/usr/bin/env python3
import json

with open('index.html', 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

# Find EMBEDDED_SCHEDULE
start = content.find('const EMBEDDED_SCHEDULE = {')
end_first = content.find('};', start)

json_str = content[start + len('const EMBEDDED_SCHEDULE = '):end_first + 2]

# Try to parse as JSON
try:
    json.loads(json_str)
    print('JSON is valid')
except json.JSONDecodeError as e:
    print(f'Error: {e.msg}')
    print(f'Position: {e.pos}')
    print(f'Near character: {repr(json_str[e.pos-5:e.pos+10])}')
    
    # The error is "Extra data" which means the object is complete
    # but there's more stuff after it. Let's find the closing }
    # of the main object
    
    # Try to find all closing braces/brackets
    pos = e.pos - 1
    while pos >= 0 and json_str[pos] in ' \t\n':
        pos -= 1
    
    print(f'Character at error position: {repr(json_str[e.pos])}')
    print(f'10 chars before: {repr(json_str[e.pos-10:e.pos])}')
    print(f'10 chars after: {repr(json_str[e.pos:e.pos+10])}')
    
    # The problem: JSON decoder successfully parsed the object
    # but found extra data. Let's count brackets
    
    # Extract just the talks part and try parsing that
    talks_start = json_str.find('"talks": [')
    talks_portion = json_str[talks_start:]
    
    print(f'\nLast 500 chars of talks portion:')
    print(repr(talks_portion[-500:]))
