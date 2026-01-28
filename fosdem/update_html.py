import json
import re

# Read the talks data
with open('talks_data.json', 'r', encoding='utf-8') as f:
    content = f.read()
    # Remove the comment line and parse JSON
    json_start = content.index('[')
    talks = json.loads(content[json_start:])

print(f"Total talks loaded: {len(talks)}")

# Read index.html
with open('index.html', 'r', encoding='utf-8') as f:
    html = f.read()

# Find the EMBEDDED_SCHEDULE constant and extract the conference part
# We'll replace just the talks array
pattern = r'("talks":\s*)\[.*?\]'

# Create the replacement with all talks
replacement = f'"talks": {json.dumps(talks, ensure_ascii=False)}'

new_html = re.sub(pattern, replacement, html, flags=re.DOTALL, count=1)

# Write back
with open('index_updated.html', 'w', encoding='utf-8') as f:
    f.write(new_html)

print("Updated index_updated.html with 1058 talks")
print(f"New HTML size: {len(new_html)} bytes")
