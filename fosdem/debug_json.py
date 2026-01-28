import json
import re

with open('index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Extract the embedded schedule
pattern = r'const EMBEDDED_SCHEDULE = \{(.*?)\n          ]'
match = re.search(pattern, content, re.DOTALL)

if match:
    json_str = '{' + match.group(1) + '\n          ]'
    print("First 500 chars of extracted JSON:")
    print(json_str[:500])
    print("\n---")
    
    # Try to find where the error is
    lines = json_str.split('\n')
    print(f"Line 10: {repr(lines[9] if len(lines) > 9 else 'N/A')}")
    
    # Try JSON parsing with more detail
    try:
        data = json.loads(json_str)
        print("SUCCESS: JSON is valid!")
    except json.JSONDecodeError as e:
        print(f"ERROR at line {e.lineno}, col {e.colno}: {e.msg}")
        if e.lineno <= len(lines):
            error_line = lines[e.lineno - 1]
            print(f"Error line: {repr(error_line)}")
            if e.colno <= len(error_line):
                print(f"Error position: {repr(error_line[max(0, e.colno-10):e.colno+10])}")
else:
    print("Could not find EMBEDDED_SCHEDULE pattern")
