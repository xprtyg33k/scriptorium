#!/usr/bin/env python3
import json

with open('index.html', 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

# Find EMBEDDED_SCHEDULE
start = content.find('const EMBEDDED_SCHEDULE = {')
print('Found EMBEDDED_SCHEDULE at char', start)

# Find where the talks array ends
talks_idx = content.find('"talks": [', start)
print('Found talks array at char', talks_idx)

# Count brackets to find where it closes
pos = talks_idx + len('"talks": [')
depth = 1
while depth > 0 and pos < len(content):
    if content[pos] == '[':
        depth += 1
    elif content[pos] == ']':
        depth -= 1
    pos += 1

talks_close = pos - 1
print('Talks array closes at char', talks_close)
print('Character there:', repr(content[talks_close]))
print('Next 30 chars:', repr(content[talks_close:talks_close+30]))

# The pattern we need to find and fix:
# }]  (closing talks array)
# \n  (newline)
# spaces (indentation)
# };  (JavaScript semicolon, but missing the } that closes the main object)

# We need to insert a } between the indentation and };

# Find the exact pattern
pattern = content[talks_close:talks_close+100]
print('\nPattern to fix:')
print(repr(pattern))

# The fix: add }
# before };
# So }] becomes }]\n        }

lines = content.split('\n')

# Find which line has the };  after the talks
for i in range(len(lines)):
    if '"talks"' in lines[i]:
        # Found the line with talks, now find where };appears after it
        for j in range(i+1, min(i+10, len(lines))):
            if lines[j].strip() == '};' and 'STATE' not in lines[j] and 'MANAGEMENT' not in ''.join(lines[max(0,j-5):j]):
                # This might be it - check if the previous line ends with ]
                if j > 0 and lines[j-1].strip().endswith(']'):
                    print('\nFound the right }; at line', j+1)
                    print('Previous line:', repr(lines[j-1][-50:]))
                    # Insert closing brace
                    lines.insert(j, '        }')
                    break
        break

# Rejoin and verify
new_content = '\n'.join(lines)

# Test the JSON
start = new_content.find('const EMBEDDED_SCHEDULE = {')
json_start = start + len('const EMBEDDED_SCHEDULE = ')

# Find the main closing brace by counting
pos = json_start + 1
depth = 1
while depth > 0 and pos < len(new_content):
    if new_content[pos] == '{':
        depth += 1
    elif new_content[pos] == '}':
        depth -= 1
    pos += 1

json_str = new_content[json_start:pos]

try:
    obj = json.loads(json_str)
    print('\nSUCCESS! JSON is valid!')
    print('Talks:', len(obj.get('talks', [])))
    
    # Write the file
    with open('index.html', 'w', encoding='utf-8') as f:
        f.write(new_content)
    print('File saved!')
except json.JSONDecodeError as e:
    print('\nStill broken:', e)
    undo_file = 'index_backup.html'  # Don't actually undo, just report
    print('JSON error at position', e.pos)
