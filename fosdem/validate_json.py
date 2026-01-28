#!/usr/bin/env python3
import json
import sys

with open('index.html', 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

# Find EMBEDDED_SCHEDULE
start = content.find('const EMBEDDED_SCHEDULE = {')
if start == -1:
    print('EMBEDDED_SCHEDULE not found')
    sys.exit(1)

# Find the closing };
end = content.find('};', start)
if end == -1:
    print('Closing }; not found')
    sys.exit(1)

json_str = content[start + len('const EMBEDDED_SCHEDULE = '):end + 2]

# Try to parse
try:
    obj = json.loads(json_str)
    print(f'✓ JSON is valid!')
    print(f'  Talks: {len(obj.get("talks", []))}')
    print(f'  Day 1: {len([t for t in obj.get("talks", []) if t.get("day") == 1])}')
    print(f'  Day 2: {len([t for t in obj.get("talks", []) if t.get("day") == 2])}')
except json.JSONDecodeError as e:
    print('JSON Error:', e)
    print('  Line:', e.lineno, ', Column:', e.colno)
    print('  Message:', e.msg)
    
    # Show context
    lines = json_str.split('\n')
    if e.lineno <= len(lines):
        line = lines[e.lineno - 1]
        preview = line[:100] + '...' if len(line) > 100 else line
        print('  Context:', preview)
    
    # Show what's after the valid JSON
    print('\nExtra data around error position:')
    start_pos = max(0, e.pos - 50)
    end_pos = min(len(json_str), e.pos + 100)
    snippet = json_str[start_pos:end_pos]
    print('  ', repr(snippet))
