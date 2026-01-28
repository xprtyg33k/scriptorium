#!/usr/bin/env python3
import json

with open('index.html', 'r', encoding='utf-8', errors='replace') as f:
    lines = f.readlines()

# Find the line with };
for i in range(len(lines)-1, -1, -1):
    if lines[i].strip() == '};' and i > 800:  # Must be after the EMBEDDED_SCHEDULE data
        prev_line = lines[i-1]
        if prev_line.strip().endswith(']'):  # Previous line ends with ]
            print('Found closing }; at line', i+1)
            print('Previous line ends with:', repr(prev_line[-50:]))
            
            # Insert a new line with } before };
            lines.insert(i, '        }\n')
            print('Inserted closing brace at line', i+1)
            break

# Write back
with open('index.html', 'w', encoding='utf-8') as f:
    f.writelines(lines)

print('File updated!')

# Verify
with open('index.html', 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()
    
# Find EMBEDDED_SCHEDULE and extract JSON properly
start = content.find('const EMBEDDED_SCHEDULE = {')
json_start = start + len('const EMBEDDED_SCHEDULE = ')

# Find the main closing brace
# We need to count braces carefully
pos = json_start + 1  # Skip the opening {
depth = 1
while depth > 0 and pos < len(content):
    if content[pos] == '{':
        depth += 1
    elif content[pos] == '}':
        depth -= 1
    pos += 1

main_close = pos - 1
json_str = content[json_start:main_close+1]

try:
    obj = json.loads(json_str)
    print('SUCCESS! JSON is now valid!')
    print('Total talks:', len(obj.get("talks", [])))
    day1 = len([t for t in obj.get("talks", []) if t.get("day") == 1])
    day2 = len([t for t in obj.get("talks", []) if t.get("day") == 2])
    print('Day 1 talks:', day1)
    print('Day 2 talks:', day2)
except json.JSONDecodeError as e:
    print('JSON Error:', e)
    print('Near:', repr(json_str[e.pos-50:e.pos+50]))
