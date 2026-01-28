import xml.etree.ElementTree as ET
import json
import re

tree = ET.parse('fosdem_schedule.xml')
root = tree.getroot()

talks = []
for event in root.findall('.//event'):
    try:
        room_elem = event.find('room')
        start_elem = event.find('start')
        end_elem = event.find('end')
        duration_elem = event.find('duration')
        track_elem = event.find('track')
        title_elem = event.find('title')
        desc_elem = event.find('description')
        date_elem = event.find('date')
        
        # Extract date and determine day
        date_str = "2026-01-31"
        day_num = 1
        if date_elem is not None and date_elem.text:
            # Format: 2026-01-31T09:30:00+01:00
            full_date = date_elem.text
            date_str = full_date.split('T')[0]  # Extract just the date part
            # Determine day based on date
            if date_str.startswith('2026-02'):
                day_num = 2
            else:
                day_num = 1
        
        # Extract time (just the HH:MM part)
        start_time = "09:00"
        if start_elem is not None and start_elem.text:
            start_time = start_elem.text  # Already in HH:MM format
        
        end_time = "10:00"
        if end_elem is not None and end_elem.text:
            end_time = end_elem.text  # Already in HH:MM format
        
        duration = "01:00"
        if duration_elem is not None and duration_elem.text:
            duration = duration_elem.text
        
        room = "TBD"
        if room_elem is not None and room_elem.text:
            room = room_elem.text
        
        track = "Other"
        if track_elem is not None and track_elem.text:
            track = track_elem.text
        
        title = "Untitled"
        if title_elem is not None and title_elem.text:
            title = title_elem.text
        
        abstract = ""
        if desc_elem is not None and desc_elem.text:
            abstract = desc_elem.text
        
        # Extract speakers
        speakers = []
        for person in event.findall('.//person'):
            if person.text:
                speakers.append(person.text)
        speakers_str = ', '.join(speakers) if speakers else "TBD"
        
        talk = {
            'id': event.get('id', f'talk-{len(talks)}'),
            'title': title,
            'speakers': speakers_str,
            'abstract': abstract,
            'track': track,
            'day': day_num,
            'date': date_str,
            'start_time': start_time,
            'end_time': end_time,
            'duration': duration,
            'room': room,
            'building': 'ULB'
        }
        talks.append(talk)
    except Exception as e:
        print(f"Error parsing event: {e}", file=__import__('sys').stderr)
        continue

print(f"// Total talks: {len(talks)}")
print(json.dumps(talks, indent=2))
