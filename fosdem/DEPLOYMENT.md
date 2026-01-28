# FOSDEM 2026 Schedule Planner - Deployment & Setup

## Quick Start
1. Open `index.html` in any web browser
2. Schedule loads automatically
3. No installation, no network required

## What You're Getting

### Complete FOSDEM 2026 Schedule
- **1,058 talks** from official FOSDEM XML schedule
- **71 tracks** across 2 days
- **Correct dates**: 
  - Day 1: Saturday, January 31, 2026 (545 talks)
  - Day 2: Sunday, February 1, 2026 (513 talks)

### File Details
- **index.html**: 390 KB (includes all data embedded)
- **Format**: Single HTML file with embedded JSON
- **Dependencies**: None (pure HTML/CSS/JavaScript)
- **Network**: No external requests needed

## Data Source
Schedule extracted from official FOSDEM 2026 XML: https://fosdem.org/2026/schedule/xml

## Installation
Just save/download `index.html` and open it. That's it.

## Browser Compatibility
- Works in all modern browsers
- Chrome/Edge/Firefox/Safari all support
- No special extensions needed
- Works offline completely

## Features Included

### Search & Filter
- Real-time search by title, speaker, keyword
- Filter by track/devroom  
- Filter by building
- Filter by day (All / Day 1 / Day 2)

### Personal Schedule
- Click "+" to add talks to your schedule
- Conflict detection (overlapping times)
- 5-star rating system per talk
- Auto-generate schedule with recommendations

### Export & Print
- Export schedule as plain text
- Export schedule as JSON
- Print-friendly view

### Force Reload
- Click "🔄 Reload" button in Actions panel
- Resets everything and reloads from embedded data
- Useful if UI gets stuck

## Data Persistence
- Ratings stored in browser localStorage
- Schedule selections saved
- Data survives page refresh
- Can be cleared with "🗑️ Clear" button

## Customization

### To update with latest data:
1. Download fresh FOSDEM XML from https://fosdem.org/2026/schedule/xml
2. Run `python parse_xml.py` to convert
3. Run `python update_html_v2.py` to rebuild index.html

### Scripts included:
- `parse_xml.py` - Convert FOSDEM XML to JSON
- `update_html_v2.py` - Embed JSON into HTML
- `check_dates.py` - Verify date distribution
- `validate_html_v2.py` - Validate JSON structure

## Troubleshooting

### Page not loading?
1. Check browser console (F12)
2. Look for error messages
3. Click "🔄 Reload" button
4. Hard refresh: Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)

### No talks showing?
1. Open browser DevTools (F12)
2. Go to Console tab
3. Check for errors
4. Click Reload button

### Data looks wrong?
- All 1,058 talks present
- Days correctly distributed (545 + 513)
- Dates should be 2026-01-31 or 2026-02-01
- If not, click "🔄 Reload" button

## Performance
- Loads 1,058 talks in ~1-2 seconds
- Renders all content client-side
- No server backend needed
- Suitable for thousands of concurrent users

## Limitations & Notes
- No user accounts or cloud sync
- Data stored only in browser localStorage
- Clearing browser data will clear ratings/schedule
- Perfect for offline use at the conference

## Support
For issues with:
- FOSDEM schedule content → contact FOSDEM organizers
- This planner app → check console logs and Reload button

---
**Version**: 1.0  
**Last Updated**: January 27, 2026  
**Data**: FOSDEM 2026 Official Schedule (1,058 talks)
