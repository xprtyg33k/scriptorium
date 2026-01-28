#!/usr/bin/env python3
import json

with open('index.html', 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

# Find the talks array end
talks_idx = content.find('"talks": [')
pos = talks_idx + len('"talks": [')

# Count brackets to find where talks array closes
depth = 1
while depth > 0 and pos < len(content):
    if content[pos] == '[':
        depth += 1
    elif content[pos] == ']':
        depth -= 1
    pos += 1

talks_close_pos = pos - 1

print(f'Talks array closes at position {talks_close_pos}')
print(f'Character: {repr(content[talks_close_pos])}')
print(f'Next 20 chars: {repr(content[talks_close_pos:talks_close_pos+20])}')

# The pattern should be: }]\n        };
# But we need it to be: }]\n        }\n        };

# Find where this pattern occurs and fix it
pattern = '}]\n        };'
new_pattern = '}]\n        }\n        };'

if pattern in content:
    print(f'\nFound the pattern to replace!')
    new_content = content.replace(pattern, new_pattern, 1)  # Replace just the first occurrence
    
    # Verify it's now valid JSON
    start = new_content.find('const EMBEDDED_SCHEDULE = {')
    end_idx = new_content.find('};', start)
    json_str = new_content[start + len('const EMBEDDED_SCHEDULE = '):end_idx + 2]
    
    try:
        obj = json.loads(json_str)
        print(f'SUCCESS! JSON is now valid!')
        print(f'Total talks: {len(obj.get("talks", []))}')
        
        # Write the fixed content
        with open('index.html', 'w', encoding='utf-8') as f:
            f.write(new_content)
        print('File saved!')
    except json.JSONDecodeError as e:
        print(f'JSON still invalid: {e}')
else:
    print(f'\nPattern not found exactly. Let me search more broadly...')
    # Look for the exact position after ]
    next_chars = content[talks_close_pos:talks_close_pos+30]
    print(f'Actual next chars: {repr(next_chars)}')
