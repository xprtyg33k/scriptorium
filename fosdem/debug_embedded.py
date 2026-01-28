import re

with open('index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Find EMBEDDED_SCHEDULE
idx = content.find('const EMBEDDED_SCHEDULE = {')
if idx == -1:
    print("ERROR: EMBEDDED_SCHEDULE not found!")
    exit(1)

print(f"Found EMBEDDED_SCHEDULE at position {idx}")

# Find the end
end_idx = content.find('};', idx)
if end_idx == -1:
    print("ERROR: No closing }; found!")
    exit(1)

print(f"Found closing closing bracket at position {end_idx}")

# Extract the full section
section = content[idx:end_idx+2]

# Count talks array
talks_start = section.find('"talks": [')
talks_end = section.rfind(']')

if talks_start == -1:
    print("ERROR: talks array not found!")
    exit(1)

print(f"talks array found at relative position {talks_start}")

# Count opening and closing brackets
open_brackets = section.count('[')
close_brackets = section.count(']')
open_braces = section.count('{')
close_braces = section.count('}')

print(f"\nBracket balance check:")
print(f"  [ brackets: {open_brackets} open, {close_brackets} close")
print(f"  {{ braces: {open_braces} open, {close_braces} close")

if open_brackets != close_brackets:
    print(f"  ERROR: Bracket mismatch! {open_brackets} vs {close_brackets}")

# Count talk objects
talk_count = section.count('"id":')
print(f"\nTalk objects found: {talk_count}")

# Check the structure
print(f"\nFirst 300 chars:")
print(section[:300])

print(f"\nLast 300 chars:")
print(section[-300:])

# Check for common issues
if '\\u' in section:
    print("\nWARNING: Found Unicode escapes (\\u sequences)")
    
if '\\"' in section:
    print("WARNING: Found escaped quotes (\\\") - might be double-escaped")

# Try to extract just the talks array part
talks_section = section[talks_start+10:section.rfind(']')]
first_talk = talks_section[:500]
print(f"\nFirst talk (first 500 chars):")
print(first_talk)

# Check if there are any obvious syntax errors
if '} {' in section:
    print("\nWARNING: Found '} {' - missing comma between objects")

if ']{' in section:
    print("WARNING: Found ']{' - incorrect closing/opening")
    
# Try to validate by checking if we can at least parse conference
conf_start = section.find('"conference"')
conf_end = section.find('},', conf_start)
if conf_start > 0 and conf_end > 0:
    conf_section = section[conf_start:conf_end+1]
    print(f"\nConference section looks valid: {len(conf_section)} chars")
