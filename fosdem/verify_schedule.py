import json
import re

with open('index.html', 'r', encoding='utf-8') as f:
    content = f.read()
    
# Count talk IDs in the JSON
count = content.count('"id": "')
print(f"Total talk ID entries: {count}")

# Find the first few talks
first_talks = re.findall(r'"title": "([^"]+)"', content)[0:5]
print(f"\nFirst 5 talks found:")
for i, title in enumerate(first_talks, 1):
    print(f"  {i}. {title}")

# Count unique days
if '"day": 1' in content:
    day1_count = content.count('"day": 1')
    print(f"\nDay 1 talks: {day1_count}")
    
if '"day": 2' in content:
    day2_count = content.count('"day": 2')
    print(f"Day 2 talks: {day2_count}")

# Check for tracks
tracks = set(re.findall(r'"track": "([^"]+)"', content))
print(f"\nTotal unique tracks: {len(tracks)}")
print("Sample tracks:")
for track in list(tracks)[:10]:
    print(f"  - {track}")

print(f"\nHTML file size: {len(content)} bytes")
