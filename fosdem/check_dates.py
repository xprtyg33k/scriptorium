import json

with open('talks_data_v2.json', 'r', encoding='utf-8') as f:
    lines = f.readlines()
    json_lines = ''.join(lines[1:])
    talks = json.loads(json_lines)
    
print(f"Total talks: {len(talks)}")
day1 = [t for t in talks if t['day'] == 1]
day2 = [t for t in talks if t['day'] == 2]
print(f"Day 1: {len(day1)} talks")
print(f"Day 2: {len(day2)} talks")

print("\nSample Day 1 talks:")
for t in day1[:3]:
    print(f"  {t['title']} ({t['date']}) {t['start_time']}")

print("\nSample Day 2 talks:")
for t in day2[:3]:
    print(f"  {t['title']} ({t['date']}) {t['start_time']}")

print("\nDate distribution:")
dates = {}
for t in talks:
    d = t['date']
    if d not in dates:
        dates[d] = 0
    dates[d] += 1

for date in sorted(dates.keys()):
    print(f"  {date}: {dates[date]} talks")
