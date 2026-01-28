import json
import re

with open('talks_data_v2.json', 'r', encoding='utf-8') as f:
    lines = f.readlines()
    json_lines = ''.join(lines[1:])
    talks = json.loads(json_lines)

print(f"Loaded {len(talks)} talks with correct dates")

# Read index.html
with open('index.html', 'r', encoding='utf-8') as f:
    html = f.read()

# Build the new schedule JSON with all talks
pattern = r'const EMBEDDED_SCHEDULE = \{.*?\n          \]'
match = re.search(pattern, html, re.DOTALL)

if match:
    talks_json = json.dumps(talks, ensure_ascii=False)
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
          "talks": ''' + talks_json + '''
          }'''
    
    new_html = html.replace(match.group(0), new_schedule)
    
    with open('index.html', 'w', encoding='utf-8') as f:
        f.write(new_html)
    
    print("Updated index.html with corrected dates")
    print(f"New file size: {len(new_html)} bytes")
else:
    print("ERROR: Could not find pattern")
