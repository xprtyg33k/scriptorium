#!/usr/bin/env python3

with open('index.html', 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

start = content.find('const EMBEDDED_SCHEDULE = {')
end_idx = content.find('};', start)

json_str = content[start + len('const EMBEDDED_SCHEDULE = '):end_idx + 2]

# Find the last }
closing_brace_pos = json_str.rfind('}')
print(f'Position of closing brace: {closing_brace_pos}')
print(f'Total JSON length: {len(json_str)}')

# Look at what comes before the final }
before_brace = json_str[closing_brace_pos-100:closing_brace_pos]
after_brace = json_str[closing_brace_pos:closing_brace_pos+10]

print(f'\n100 chars before closing brace:')
print(repr(before_brace))
print(f'\nClosing brace and after:')
print(repr(after_brace))

# Count brackets and braces
open_braces = json_str.count('{')
close_braces = json_str.count('}')
open_brackets = json_str.count('[')
close_brackets = json_str.count(']')

print(f'\nBracket count:')
print(f'  {{ : {open_braces}')
print(f'  }} : {close_braces}')
print(f'  [ : {open_brackets}')
print(f'  ] : {close_brackets}')

if close_braces > open_braces:
    print(f'\nWARNING: More closing braces than opening! ({close_braces} vs {open_braces})')
if close_brackets > open_brackets:
    print(f'WARNING: More closing brackets than opening! ({close_brackets} vs {open_brackets})')
