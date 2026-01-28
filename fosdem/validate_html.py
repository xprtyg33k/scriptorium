import json
import re

with open('index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Check for basic structure
if 'const EMBEDDED_SCHEDULE' not in content:
    print("ERROR: EMBEDDED_SCHEDULE not found")
    exit(1)

# Extract the embedded schedule to validate JSON
pattern = r'const EMBEDDED_SCHEDULE = \{(.*?)\n          \}'
match = re.search(pattern, content, re.DOTALL)

if match:
    try:
        # Build valid JSON
        json_str = '{' + match.group(1) + '}'
        data = json.loads(json_str)
        print(f"✓ EMBEDDED_SCHEDULE is valid JSON")
        print(f"  Talks: {len(data['talks'])}")
        print(f"  Day 1: {len([t for t in data['talks'] if t['day'] == 1])}")
        print(f"  Day 2: {len([t for t in data['talks'] if t['day'] == 2])}")
        
        # Check for required fields
        sample = data['talks'][0]
        required = ['id', 'title', 'speakers', 'track', 'day', 'date', 'start_time', 'end_time', 'room']
        missing = [f for f in required if f not in sample]
        if missing:
            print(f"  WARNING: Missing fields: {missing}")
        else:
            print(f"  ✓ All required fields present")
    except json.JSONDecodeError as e:
        print(f"ERROR: Invalid JSON in EMBEDDED_SCHEDULE: {e}")
        exit(1)
else:
    print("ERROR: Could not find EMBEDDED_SCHEDULE pattern")
    exit(1)

# Check for reload button
if 'id="reloadBtn"' in content:
    print(f"✓ Reload button found")
else:
    print(f"WARNING: Reload button not found")

print("\nFile is ready to use!")
