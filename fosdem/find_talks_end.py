#!/usr/bin/env python3

with open('index.html', 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

# Find where "talks" starts
talks_idx = content.find('"talks": [')
print('talks start at char:', talks_idx)

# Find the next major structure after talks
# Look for the pattern ]  followed by spaces/newlines and }
pos = talks_idx + len('"talks": [')

# Count brackets from this point
depth = 1  # We're inside [
while depth > 0 and pos < len(content):
    if content[pos] == '[':
        depth += 1
    elif content[pos] == ']':
        depth -= 1
    pos += 1

print('talks array closes at char:', pos-1)
print('That character is:', repr(content[pos-1]))

# Show context
print('\nContext (last 200 chars of talks, next 200 after):')
print('Before:', repr(content[pos-200:pos]))
print('After:', repr(content[pos:pos+200]))

# Look for what comes next in the file
# Should be }\n then };
next_content = content[pos:pos+50]
print('\nNext 50 chars:', repr(next_content))
