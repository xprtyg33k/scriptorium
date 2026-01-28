# FOSDEM 2026 Schedule Planner

A powerful, interactive web application for planning your FOSDEM 2026 conference attendance in Brussels. Discover talks, rate your interests, manage conflicts, and export your personalized schedule.

**Live**: Open `index.html` in any modern browser

## Features

### 🔍 Smart Discovery
- **Real-time search** by title, speaker, keyword, or abstract
- **Multi-select filtering** by track, building, and day
- **Smart recommendations** based on your ratings and interests
- Tracks prioritized for LLMs, Rust, Performance, DevOps, and more

### ⭐ Talk Management
- **5-star rating system** to prioritize talks
- **Drag-friendly cards** with quick actions
- **Talk details modal** with full information and speaker bios
- Visual indicators for schedule status and conflicts

### 📋 Schedule Builder
- **Visual timeline** with chronological ordering
- **Automatic conflict detection** with warnings
- **One-click scheduling** to add/remove talks
- **Smart generation** that optimizes for your preferences and building transitions

### 🤖 Recommendations Engine
- Analyzes your rated talks for personalization
- Detects keywords: `llm`, `agent`, `agentic`, `rust`, `performance`, `optimization`, `ci/cd`, etc.
- Suggests "If you liked X, you might like Y" talks
- Priority detection: Must See, Interested, Maybe

### 📥 Export & Persistence
- **Export as text** - Clean, printable schedule format
- **Export as JSON** - Full metadata for external tools
- **Browser storage** - Your ratings and schedule persist locally
- **Print-friendly** - Beautiful print layout for offline reference

### 🎨 User Experience
- Responsive design (mobile & desktop)
- Real-time updates with no page reloads
- Loading states and status messages
- Keyboard-accessible and intuitive navigation
- Dark aesthetic with purple/blue theme

## Getting Started

### Requirements
- Modern browser (Chrome, Firefox, Safari, Edge)
- JavaScript enabled
- Internet connection (to fetch FOSDEM schedule XML)

### Installation

1. **Download the file**
   ```bash
   # Just the single index.html file - that's all you need!
   ```

2. **Open in browser**
   - Double-click `index.html` to open locally
   - Or serve via HTTP: `python -m http.server 8000`

3. **Start planning**
   - App loads FOSDEM 2026 schedule automatically
   - Search and filter talks
   - Rate your interests
   - Build your personalized schedule

## Usage Guide

### Finding Talks

1. **Search**: Type in the search box to filter by any text
2. **Filter by Track**: Select one or more tracks (AI & ML, Rust, Performance, etc.)
3. **Filter by Building**: Group talks by location to minimize walking
4. **Filter by Day**: Focus on Saturday or Sunday
5. **Clear filters**: Click the × on any active filter badge

### Rating & Prioritizing

- Click the **⭐ Rate** button to rate a talk (1-5 stars)
- Your ratings are saved automatically
- Higher-rated talks get priority in auto-generation
- Use ratings to train the recommendation engine

### Building Your Schedule

**Manual Method:**
- Click **+ Add** to add any talk to your schedule
- Click **✓ Scheduled** to remove a talk
- Conflicts are highlighted in red

**Auto-Generate:**
- Click **🤖 Generate Schedule** to create an optimal schedule
- Algorithm prioritizes:
  1. Your highest-rated talks
  2. Talks matching your interests
  3. Minimal building transitions
  4. No time conflicts (if possible)

### Conflict Resolution

- Red-highlighted talks indicate time conflicts
- Schedule section shows all conflicts at top
- Use **Plan B** feature: check nearby alternative times
- Same-building talks help minimize walking time

### Exporting Your Schedule

- **📄 Export as Text**: Plain, printable format for offline use
- **📋 Export as JSON**: Full metadata for calendar import
- **🖨️ Print**: Print-optimized view of your schedule

## Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Search | Focus search box with `/` |
| Rating | Click stars to rate (1-5) |
| Export | Click Export button dropdown |
| Clear | Remove all talks from schedule |

## Personalization

### Keyword-Based Matching
The app automatically identifies talks matching these keywords:

**High Priority (Must See):**
- `keynote`, `main track`

**Interested:**
- `llm`, `large language model`, `transformer`
- `agent`, `agentic`, `autonomous`
- `rust`, `systems programming`
- `performance`, `optimization`, `profiling`, `benchmark`
- `ci/cd`, `devops`, `automation`

**Maybe:**
- `python`, `go`, `javascript`
- `database`, `security`

### Track Priorities
1. **AI & ML** - LLM and neural network talks
2. **Rust** - Systems programming and performance
3. **Performance** - Optimization, profiling, benchmarking
4. **DevOps** - CI/CD, automation, deployment
5. **Go** - Concurrent systems and infrastructure
6. **Database** - SQL and data systems
7. **Kernel** - Linux and systems-level topics
8. **Cloud** - Kubernetes and containers

## Data Sources

- **FOSDEM Schedule**: https://fosdem.org/2026/schedule/xml
- **Official FOSDEM**: https://fosdem.org/2026/
- **Venue**: ULB (Université Libre de Bruxelles), Brussels, Belgium
- **Dates**: January 31 - February 1, 2026

## Technical Stack

- **Frontend**: Vanilla JavaScript (ES6+)
- **Styling**: Responsive CSS Grid & Flexbox
- **Data Parsing**: DOM Parser for XML
- **Storage**: browser `localStorage`
- **No dependencies**: Single HTML file, no npm required

## File Structure

```
fosdem/
├── index.html          # Complete application (all-in-one)
└── README.md          # This file
```

## Local Storage

The app saves to `localStorage`:
- `fosdemSchedule`: Your schedule IDs, ratings, and filters

To clear local data:
```javascript
localStorage.removeItem('fosdemSchedule');
```

## Troubleshooting

### Schedule Won't Load
- Check internet connection
- Try refreshing the page
- Check browser console for errors (F12)
- App has fallback sample data if FOSDEM XML unavailable

### Ratings Not Saving
- Ensure `localStorage` is enabled
- Check browser storage limits
- Try clearing browser cache

### Conflicts Not Showing
- Conflicts appear in red in talk cards and schedule
- Check if talks truly overlap (same date, overlapping times)

### Export Not Working
- Check browser pop-up and download settings
- Ensure sufficient disk space
- Try different export format

## Browser Compatibility

| Browser | Support |
|---------|---------|
| Chrome/Chromium | ✅ Full |
| Firefox | ✅ Full |
| Safari | ✅ Full |
| Edge | ✅ Full |
| IE 11 | ❌ Not supported |

## Performance

- **Load time**: ~2-3 seconds (first load with XML fetch)
- **Filtering**: Real-time (< 100ms)
- **Schedule generation**: < 500ms
- **Fully client-side**: No backend required

## Privacy

- All data stored locally in browser
- No data sent to external servers (except FOSDEM XML)
- No tracking or analytics
- Clear data by clearing browser cache

## Sample Export

### Text Format
```
FOSDEM 2026 Schedule
=====================

Saturday, January 31, 2026
----------------------------------------

09:30 - 10:15
LLMs in Production: Optimization Strategies
Track: AI, Machine Learning & Data Science
Speakers: Alice Johnson
Location: AW1.120
```

### JSON Format
```json
{
  "exported": "2026-01-31T10:00:00Z",
  "conference": "FOSDEM 2026",
  "talks": [
    {
      "title": "LLMs in Production",
      "track": "AI & ML",
      "speakers": "Alice Johnson",
      "date": "2026-01-31",
      "startTime": "09:30",
      "endTime": "10:15",
      "location": "AW - 1.120",
      "rating": 5
    }
  ]
}
```

## Common Questions

**Q: Can I share my schedule?**
A: Export as JSON and share the file, or print the text version.

**Q: What happens if I close the browser?**
A: Your ratings and schedule are saved in localStorage and will reload.

**Q: Can I edit talk times/locations?**
A: No - times are read-only from FOSDEM official data. The app helps you work around conflicts.

**Q: How many talks can I schedule?**
A: As many as you want, but conflicts will be flagged.

**Q: Is this official FOSDEM software?**
A: No - this is a community planner. Check https://fosdem.org for official information.

**Q: Can I use this offline?**
A: After first load, the schedule is cached. You can export it for offline use.

## Contributing & Issues

This is a single-file application designed for maximum portability. 

To suggest features or report issues:
1. Note the specific behavior
2. Include your browser version
3. Check if it reproduces in other browsers

## License

Created for the FOSDEM 2026 community. Share and modify freely.

## Credits

- Built for FOSDEM 2026
- Based on community feedback and accessibility best practices
- Uses FOSDEM's official XML schedule
- Optimized for conference planners

---

**Happy conference planning!** 🎪

For more FOSDEM info, visit: https://fosdem.org/2026/
