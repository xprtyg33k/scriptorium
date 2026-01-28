# FOSDEM 2026 Schedule Planner - Quick Start

## 60-Second Setup

1. **Open the app**
   - Double-click `index.html` (or open in browser)
   - Wait for schedule to load (2-3 seconds)

2. **Start planning**
   - Type in search box (e.g., "LLM", "Rust", "performance")
   - Click checkboxes to filter by track or building
   - Click the ⭐ Rate button to rate talks

3. **Build schedule**
   - Click "+ Add" to add talks one by one, OR
   - Click "🤖 Generate Schedule" for AI-powered recommendations

4. **Export**
   - Click Export button
   - Choose Text or JSON format
   - Schedule saved to your downloads folder

## Key Features at a Glance

| Feature | How to Use |
|---------|-----------|
| **Search** | Type keywords in search box |
| **Filter** | Check boxes for tracks/buildings |
| **Rate** | Click ⭐ Rate (1-5 stars) |
| **Add** | Click "+ Add" button |
| **View Details** | Click talk card |
| **Generate** | Click "🤖 Generate Schedule" |
| **Export** | Click "Export" → choose format |
| **Print** | Click "🖨️ Print" for offline version |

## Example Workflow

### Step 1: Discover
```
Search: "rust performance"
Filter: Rust devroom, Software Performance devroom
```

### Step 2: Rate
```
Find: "Zero-Copy Protocols in Rust"
Click: ⭐ Rate → 5 stars
```

### Step 3: Build
```
Click: 🤖 Generate Schedule
Result: 14 talks auto-selected, 0 conflicts
```

### Step 4: Export
```
Click: Export → "Export as Text"
File: fosdem-schedule.txt (ready for printing)
```

## Smart Recommendations

The app auto-detects your interests from:
- **Your ratings** (5-star talks)
- **Search queries** (keywords you enter)
- **Track filters** (areas you select)

### Keyword Detection
Automatically matches talks about:
- `llm`, `agent`, `agentic` → AI talks
- `rust`, `performance`, `optimization` → Systems talks
- `ci/cd`, `devops` → Infrastructure talks

## Tips & Tricks

### ✅ Do This
- Rate your must-see talks with 5 stars
- Use "Generate Schedule" to avoid manually finding conflicts
- Export as text to print and bring to conference
- Search for specific speakers or tools by name

### ❌ Avoid This
- Don't rate talks you haven't heard of (affects recommendations)
- Don't schedule conflicting talks manually (use auto-generate)
- Don't rely solely on filters (combine with search)

## Common Tasks

### Find All Rust Talks
1. Search box: type `rust`
2. Check box: "Rust devroom"
3. See filtered results

### Get LLM Track Only
1. Check: "AI & Machine Learning devroom"
2. Uncheck other tracks
3. Search: `llm` or `language model`

### Build Sunday-Only Schedule
1. Click "Day 2" button
2. Filter by tracks of interest
3. Click "Generate Schedule"

### Print Your Schedule
1. Build your schedule
2. Click "🖨️ Print"
3. Ctrl+P (or Cmd+P) in print preview
4. Select "Save as PDF" for offline use

### Export for Calendar
1. Build your schedule
2. Click "Export" → "Export as JSON"
3. Open JSON in text editor
4. Import events to your calendar app

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Schedule won't load | Refresh page, check internet |
| Ratings not saving | Enable localStorage in browser |
| Can't find a talk | Try different search terms |
| Export won't work | Check download permissions |
| Looks weird on mobile | Try landscape orientation |

## Data Notes

- **No internet required** after first load (schedule cached)
- **Data stays local** - nothing sent to servers (except initial load)
- **Persists** - ratings and schedule saved to browser storage
- **Private** - all processing happens on your computer

## Getting Help

### Questions?
1. Check **README.md** for detailed docs
2. Search the FAQ section
3. Try sample data if schedule won't load

### Need to Reset?
```
Press F12 → Console → type:
localStorage.removeItem('fosdemSchedule')
```

## Next Steps

1. **Prepare** (now)
   - Rate talks matching your interests
   - Generate optimal schedule
   - Export for offline reference

2. **At Conference** (Jan 31 - Feb 1)
   - Keep printed schedule or PDF handy
   - Check app for real-time updates
   - Mark favorites for post-conference notes

3. **After Conference** (Feb 2+)
   - Export ratings for feedback
   - Share favorite talks with colleagues
   - Save JSON for records

---

**Ready?** Open `index.html` and start planning!

For full documentation, see [README.md](README.md)
