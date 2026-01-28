#!/usr/bin/env python3

with open('index.html', 'r', encoding='utf-8', errors='replace') as f:
    lines = f.readlines()

print(f'Total lines: {len(lines)}')
print()
print('Line 806:')
print(repr(lines[805]))
print()
print('Line 807:')
print(repr(lines[806]))
print()
print('Line 808 (first 200 and last 200 chars):')
if len(lines) > 807:
    line808 = lines[807]
    print('First 200:', repr(line808[:200]))
    print('Last 200:', repr(line808[-200:]))
print()
print('Line 809:')
if len(lines) > 808:
    print(repr(lines[808]))
print()
print('Line 810:')
if len(lines) > 809:
    print(repr(lines[809]))
