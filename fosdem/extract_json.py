import re

with open('index.html', 'r', encoding='utf-8') as f:
    content = f.read()

pattern = r'const EMBEDDED_SCHEDULE = (\{.*?\n        \});'
match = re.search(pattern, content, re.DOTALL)

if match:
    json_str = match.group(1)
    lines = json_str.split('\n')
    
    print("First 20 lines of extracted JSON:")
    for i, line in enumerate(lines[:20], 1):
        print(f"{i:2d}: {line}")
else:
    print("Pattern not found")
    # Try alternative pattern
    pattern2 = r'const EMBEDDED_SCHEDULE = \{(.*?)\n        \};'
    match2 = re.search(pattern2, content, re.DOTALL)
    if match2:
        print("Found with pattern2")
        json_str = '{' + match2.group(1) + '\n        }'
        lines = json_str.split('\n')
        print("\nFirst 20 lines:")
        for i, line in enumerate(lines[:20], 1):
            print(f"{i:2d}: {line}")
