#!/usr/bin/env python3
# Script to update all gifUrl references

with open('lib/services/mock_data_service.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace all occurrences
old_pattern = "'gifUrl': gifUrl,"
new_pattern = "'gifUrl': getRandomGifUrl(),"

content = content.replace(old_pattern, new_pattern)

with open('lib/services/mock_data_service.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('✓ Successfully updated all gifUrl references to use getRandomGifUrl()')
