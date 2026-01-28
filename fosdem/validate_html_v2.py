import json
import re

with open('index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Check for basic structure
if 'const EMBEDDED_SCHEDULE' not in content:
    print("ERROR: EMBEDDED_SCHEDULE not found")
    exit(1)

# Extract the embedded schedule to validate JSON
# Pattern: const EMBEDDED_SCHEDULE = { ... }; with proper nesting
pattern = r'const EMBEDDED_SCHEDULE = (\{.*?\n        \});'
match = re.search(pattern, content, re.DOTALL)

if match:
    try:
        # The match group already has the complete JSON object
        json_str = match.group(1)
        data = json.loads(json_str)
        print(f"✓ EMBEDDED_SCHEDULE is valid JSON")
        print(f"  Conference: {data.get('conference', {}).get('title', 'N/A')}")
        print(f"  Talks: {len(data.get('talks', []))}")
        day1 = len([t for t in data.get('talks', []) if t.get('day') == 1])
        day2 = len([t for t in data.get('talks', []) if t.get('day') == 2])
        print(f"  Day 1: {day1} talks")
        print(f"  Day 2: {day2} talks")
        
        # Check for required fields
        if data.get('talks'):
            sample = data['talks'][0]
            required = ['id', 'title', 'speakers', 'track', 'day', 'date', 'start_time', 'end_time', 'room']
            missing = [f for f in required if f not in sample]
            if missing:
                print(f"  WARNING: Missing fields in first talk: {missing}")
            else:
                print(f"  ✓ All required fields present")
                
            # Show sample
            print(f"\n  Sample talk (first):")
            print(f"    Title: {sample.get('title')}")
            print(f"    Date: {sample.get('date')} Day {sample.get('day')}")
            print(f"    Time: {sample.get('start_time')} - {sample.get('end_time')}")
    except json.JSONDecodeError as e:
        print(f"ERROR: Invalid JSON in EMBEDDED_SCHEDULE")
        print(f"  Line {e.lineno}, Col {e.colno}: {e.msg}")
        exit(1)
else:
    print("ERROR: Could not find EMBEDDED_SCHEDULE pattern")
    print("\nSearching for EMBEDDED_SCHEDULE location...")
    idx = content.find('const EMBEDDED_SCHEDULE')
    if idx >= 0:
        sample = content[idx:idx+200]
        print(sample[:150])
    exit(1)

# Check for reload button
if 'id="reloadBtn"' in content:
    print(f"✓ Reload button found")
else:
    print(f"WARNING: Reload button not found")

print("\n✓ File is ready to use!")
