import json
import re

# Read the full FOSDEM schedule
with open('talks_data.json', 'r', encoding='utf-8') as f:
    content = f.read()
    json_start = content.index('[')
    talks = json.loads(content[json_start:])

print(f"Loaded {len(talks)} talks from FOSDEM 2026 XML")

# Convert to the expected format (with startTime, endTime camelCase)
formatted_talks = []
for talk in talks:
    formatted_talks.append({
        "id": talk["id"],
        "title": talk["title"],
        "speakers": talk["speakers"],
        "abstract": talk["abstract"],
        "track": talk["track"],
        "day": talk["day"],
        "date": talk["date"],
        "start_time": talk["start_time"],
        "end_time": talk["end_time"],
        "duration": talk["duration"],
        "room": talk["room"],
        "building": talk["building"]
    })

# Read the original HTML
with open('index.html', 'r', encoding='utf-8') as f:
    html_content = f.read()

# Find the EMBEDDED_SCHEDULE object
pattern = r'const EMBEDDED_SCHEDULE = \{.*?\n          \]'
match = re.search(pattern, html_content, re.DOTALL)

if match:
    old_schedule = match.group(0)
    print(f"Found old EMBEDDED_SCHEDULE ({len(old_schedule)} chars)")
    
    # Create the new EMBEDDED_SCHEDULE
    new_schedule = '''const EMBEDDED_SCHEDULE = {
          "conference": {
            "title": "FOSDEM 2026",
            "venue": "ULB (Université Libre de Bruxelles)",
            "city": "Brussels, Belgium",
            "start_date": "2026-01-31",
            "end_date": "2026-02-01",
            "days": 2,
            "start_hour": "09:00",
            "end_hour": "17:00"
          },
          "talks": ''' + json.dumps(formatted_talks, ensure_ascii=False) + '''
          ]'''
    
    # Replace in HTML
    new_html = html_content.replace(old_schedule, new_schedule)
    
    # Write back
    with open('index.html', 'w', encoding='utf-8') as f:
        f.write(new_html)
    
    print(f"Updated index.html with {len(formatted_talks)} talks")
    print(f"New HTML file size: {len(new_html)} bytes")
    print("Done!")
else:
    print("ERROR: Could not find EMBEDDED_SCHEDULE pattern in HTML")
