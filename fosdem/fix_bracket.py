#!/usr/bin/env python3
import re

with open('index.html', 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

# Find EMBEDDED_SCHEDULE
start = content.find('const EMBEDDED_SCHEDULE = {')
end = content.find('};', start)

if start == -1 or end == -1:
    print('Could not find EMBEDDED_SCHEDULE')
    exit(1)

json_str = content[start + len('const EMBEDDED_SCHEDULE = '):end + 2]

# Find the problematic area - it should end with }]
# But we have }] followed by ] before };
# Let's find where the talks array ends

# Look for the last occurrence of }] in the JSON
last_talk_close = json_str.rfind('}]')
if last_talk_close == -1:
    print('Could not find end of talks array')
    exit(1)

# Show what comes after }]
after_close = json_str[last_talk_close:last_talk_close+50]
print('After last }]:')
print(repr(after_close))
print()

# If there's an extra ], it should be right after }]
if json_str[last_talk_close:last_talk_close+3] == '}]\n':
    print('Found }] followed by newline')
    # Check if there's an extra ] after the newline
    next_part = json_str[last_talk_close+3:last_talk_close+20]
    print('Next part:', repr(next_part))
    
    if next_part.strip().startswith(']'):
        print('FOUND IT! There is an extra ] that needs to be removed')
        # Find the position of this extra ]
        extra_bracket_start = last_talk_close + 3
        while extra_bracket_start < len(json_str) and json_str[extra_bracket_start] in ' \t\n':
            extra_bracket_start += 1
        
        if json_str[extra_bracket_start] == ']':
            print(f'Extra ] at position {extra_bracket_start}')
            print(f'Context: {repr(json_str[extra_bracket_start-20:extra_bracket_start+20])}')
