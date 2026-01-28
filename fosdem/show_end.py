#!/usr/bin/env python3

with open('index.html', 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

start = content.find('const EMBEDDED_SCHEDULE = {')
end_idx = content.find('};', start)

json_str = content[start + len('const EMBEDDED_SCHEDULE = '):end_idx + 2]
print('Last 100 chars of extracted JSON:')
print(repr(json_str[-100:]))
print()
print('Characters around position 325175 (where the error is):')
print(repr(json_str[325165:325177]))
