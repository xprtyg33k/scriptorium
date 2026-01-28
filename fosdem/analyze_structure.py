#!/usr/bin/env python3

with open('index.html', 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

start = content.find('const EMBEDDED_SCHEDULE = {')
print(f'EMBEDDED_SCHEDULE starts at: {start}')

# Manually trace the structure
# It should be: const EMBEDDED_SCHEDULE = { "conference": {...}, "talks": [...] };

# Count the opening and closing braces/brackets
from_start = content[start:]

# Extract first 500 chars to see the structure
print('\nFirst 500 chars:')
print(repr(from_start[:500]))

# Count main braces
open_brace_after_equals = 1
open_braces = 1
open_brackets = 0

pos = start + len('const EMBEDDED_SCHEDULE = ')

# Skip to the first {
while pos < len(content) and content[pos] != '{':
    pos += 1

# Now count from here
braces = 1
brackets = 0
pos += 1

while pos < len(content) and braces > 0:
    if content[pos] == '{':
        braces += 1
    elif content[pos] == '}':
        braces -= 1
        if braces == 0:
            break
    elif content[pos] == '[':
        brackets += 1
    elif content[pos] == ']':
        brackets -= 1
    pos += 1

print(f'\nMain object closes at position: {pos}')
print(f'That char is: {repr(content[pos])}')
print(f'Context around it: {repr(content[pos-50:pos+50])}')
