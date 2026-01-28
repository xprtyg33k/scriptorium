#!/usr/bin/env python3

with open('index.html', 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

# Find EMBEDDED_SCHEDULE
start = content.find('const EMBEDDED_SCHEDULE = {')
end_idx = content.find('};', start)

# The issue: ends with }] but should end with }]}
# We need to add a } before the };

# Find the exact location where we need to insert the }
# It should be after }] and before };

problem_area = content[end_idx-5:end_idx+3]
print(f'Current ending: {repr(problem_area)}')

# Replace }]; with }];
fixed_content = content.replace('          "talks": [', '          "talks": [')

# The problem is that line 809 has just };
# We need it to have };
# Let's find and replace that specific line

lines = content.split('\n')
for i in range(len(lines)-1, -1, -1):
    if lines[i].strip() == '};' and i > 800:  # Near the EMBEDDED_SCHEDULE end
        print('Found }; at line', i+1)
        print('  Line content:', repr(lines[i]))
        if i > 0:
            print('  Previous line:', repr(lines[i-1][-100:]))
        
        # Check if this is the one we need to fix
        prev_line = lines[i-1] if i > 0 else ''
        if prev_line.endswith(']'):
            print('  -> This is the one to fix!')
            # Replace this line
            lines[i] = lines[i].replace('};', '};')  # This doesn't change anything
            # Actually we need to add } before };
            lines[i] = '        };'  # This is correct
            # But we need to add } on a new line before it
            lines.insert(i, '        }')
            break

# Write back
with open('index.html', 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))

print('File fixed!')

# Verify
with open('index.html', 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()
    start = content.find('const EMBEDDED_SCHEDULE = {')
    end_idx = content.find('};', start)
    json_str = content[start + len('const EMBEDDED_SCHEDULE = '):end_idx + 2]
    
    import json
    try:
        json.loads(json_str)
        print('JSON is now valid!')
    except json.JSONDecodeError as e:
        print('Still broken:', e)
