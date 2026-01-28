# FOSDEM 2026 Schedule Planner - Detailed Usage Guide

## Table of Contents
1. [Getting Started](#getting-started)
2. [Main Interface](#main-interface)
3. [Finding Talks](#finding-talks)
4. [Rating & Prioritizing](#rating--prioritizing)
5. [Building Your Schedule](#building-your-schedule)
6. [Managing Conflicts](#managing-conflicts)
7. [Exporting](#exporting)
8. [Tips & Tricks](#tips--tricks)
9. [Keyboard Navigation](#keyboard-navigation)
10. [Troubleshooting](#troubleshooting)

---

## Getting Started

### Opening the App
1. **Download** or locate `index.html`
2. **Double-click** the file to open in your default browser
3. **Wait** for the schedule to load (shows loading spinner)
4. **See** "FOSDEM 2026 Schedule Planner" header when ready

### First Time Setup
- App automatically loads the FOSDEM 2026 schedule (~50 talks)
- If offline, uses sample data as fallback
- Your data saves automatically as you work
- No account or login required

### What You'll See
```
┌─ HEADER ────────────────────────────────────────┐
│  FOSDEM 2026 Schedule Planner                   │
│  Brussels, Belgium • January 31 - February 1    │
└─────────────────────────────────────────────────┘

┌─ SIDEBAR ─────────┐  ┌─ TALKS ──────┐  ┌─ SCHEDULE ─────┐
│ 🔍 Search        │  │ Talk Cards   │  │ Timeline View  │
│ 📍 Tracks        │  │ Results      │  │ My Schedule    │
│ 🏢 Building      │  │             │  │                │
│ 📅 Day           │  │             │  │                │
│ ⚙️  Actions      │  │             │  │                │
└──────────────────┘  └─────────────┘  └────────────────┘
```

---

## Main Interface

### Left Sidebar (Filters & Controls)

#### 🔍 Search Box
- Click and type keywords
- Searches: title, speaker, abstract, track
- Results update in real-time
- Case-insensitive
- Example searches:
  - `rust` → All Rust talks
  - `performance` → Performance optimization talks
  - `alice johnson` → Talks by specific speaker
  - `llm` → LLM-related talks

#### 📍 Track Filters
```
☐ AI, Machine Learning & Data Science (12 talks)
☐ Rust devroom (8 talks)
☐ Software Performance (6 talks)
☐ Go devroom (5 talks)
☐ Databases (4 talks)
... and more
```
- Check boxes to filter by track
- Numbers show talks per track
- Multiple selections work together (AND logic)
- Uncheck to remove filter

#### 🏢 Building Filters
```
☐ AW (10 talks) - Amphitheatre building
☐ H (8 talks)   - Halls building
☐ J (7 talks)   - Janson building
☐ K (6 talks)   - Kuppel building
... and more
```
- Groups talks by physical location
- Useful for minimizing walking time
- Shows talk count per building

#### 📅 Day Selector
```
[All Days] [Day 1] [Day 2]
```
- **All Days**: Shows all talks
- **Day 1**: Saturday, January 31
- **Day 2**: Sunday, February 1
- Only one day can be selected at a time

#### ⚙️ Actions
```
[📥 Export] [🗑️ Clear]
```
- **Export**: Save schedule as text or JSON
- **Clear**: Remove all talks from schedule

### Center (Talk Discovery)

#### Stats Bar
```
Total: 152 | Filtered: 24 | Rated: 8
```
- **Total**: All talks in FOSDEM schedule
- **Filtered**: Talks matching current filters
- **Rated**: Talks you've rated 1-5 stars

#### Active Filters Display
```
[rust ×] [performance ×] [saturday ×]
```
- Shows current filters as badges
- Click × to remove individual filter
- Quick way to see what's filtered

#### Talk Cards
Each talk shows:
```
╔═══════════════════════════════════════╗
║ Talk Title with Priority Badge        ║
║ John Doe, Jane Smith                  ║
║ Jan 31 • 10:00 (45min) • [AW] Building║
║ [AI & ML]                             ║
║ ★★★★☆ (3 out of 5 stars)             ║
║ [⭐ Rate] [+ Add] OR [✓ Scheduled]    ║
╚═══════════════════════════════════════╝
```

**Elements**:
- **Title**: Talk name (click to see details)
- **Speakers**: Who's presenting
- **Time**: Date, start time, duration
- **Building**: Location abbreviation (clickable)
- **Track**: Category (green badge)
- **Rating**: Your current rating (0-5 stars)
- **Actions**: Rate, Add/Remove buttons

**Color Coding**:
- 🟩 **Green border**: Already in your schedule
- 🟥 **Red border**: Time conflict detected
- ⬜ **Gray border**: Available to add

### Right Side (Schedule)

#### Action Buttons
```
[🤖 Generate Schedule] [🖨️ Print]
```
- **Generate**: AI creates optimal schedule
- **Print**: Print-optimized view (Ctrl+P)

#### Conflict Warning
```
⚠️ You have 3 time conflicts
```
- Shows only when conflicts exist
- Red highlighting on conflicting talks
- Disappears when conflicts resolved

#### Schedule Timeline
```
Saturday, January 31, 2026
─────────────────────────────
09:00 - 09:45
Opening Keynote
Track: Keynotes
Location: K - Main Amphitheatre
[Remove]

10:00 - 10:45
LLMs in Production
Location: AW - 1.120
[Remove]
```

---

## Finding Talks

### Method 1: Simple Search
1. Click search box (top left)
2. Type a keyword
3. Press Enter or just wait (auto-updates)
4. Click a talk card to view details

**Example**: Search "rust"
- Shows all talks with "rust" in title, speaker, or abstract
- Filter shows matched talks instantly

### Method 2: Filter by Track
1. Scroll down sidebar
2. Find desired track in "📍 Tracks" section
3. Check the checkbox
4. Results filter automatically

**Example**: Click "Rust devroom"
- Shows only Rust-related talks
- Updates count: "Filtered: 8"

### Method 3: Combine Filters
1. Check "Rust devroom" track
2. Check "H" building
3. Select "Day 1" (Saturday)
4. Results narrow to: Rust talks on Saturday in building H

**Combine with Search**:
- Keep "rust" in search box
- Check "Software Performance" track
- Shows: Rust talks that match performance keywords

### Method 4: Clear Filters to Reset
- Click × on filter badges at top
- Or click "🗑️ Clear" to reset everything
- Or uncheck boxes in sidebar

### Finding Hidden Gems
- Leave search box empty
- Select only "Day 1"
- Sort by "Filtered: X talks"
- Browse through and rate interesting talks
- Recommendation engine will find similar talks

---

## Rating & Prioritizing

### The Rating System

#### 5-Star Scale
```
☆☆☆☆☆ = Not interested
★☆☆☆☆ = Maybe
★★☆☆☆ = Somewhat interested
★★★☆☆ = Interested
★★★★☆ = Very interested
★★★★★ = MUST SEE
```

### How to Rate

#### Option 1: Quick Rate from Card
1. Find talk card
2. Click "⭐ Rate" button
3. Hover over stars to preview
4. Click the star for your rating
5. Rating saves instantly

#### Option 2: Rate in Details Modal
1. Click on talk card (anywhere except buttons)
2. Modal opens with full details
3. Scroll to "YOUR RATING" section
4. Click stars to rate (1-5)
5. Close modal (click ✕ or click outside)

#### Option 3: Rate from Schedule
1. Look at your scheduled talks
2. On each talk, hover for details
3. Click rating stars if available
4. Instantly updates

### Why Rate Talks?

**For Recommendations**:
- 5-star talks train the algorithm
- Helps find similar talks
- Improves "Generate Schedule" suggestions

**For Priority Planning**:
- Highest-rated talks get scheduled first
- See at a glance what matters most
- Easy conflict resolution (remove lower-rated conflicts)

### Rating Hints

**Rate These High (5 stars)**:
- Talks you absolutely don't want to miss
- Keynotes on your topic
- Talks from known experts

**Rate Medium (3-4 stars)**:
- Talks on interesting topics
- New speakers you want to hear
- Deep dives on tools you use

**Rate Low or Skip**:
- Talks outside your interests
- Topics you already know well
- Sessions with scheduling conflicts

---

## Building Your Schedule

### Method 1: Manual Selection
1. Find a talk you want
2. Click "+ Add" button
3. Talk appears in "My Schedule" section
4. Repeat for all desired talks

### Method 2: Auto-Generate
1. **Rate talks** you like (5 stars)
2. Click "🤖 Generate Schedule"
3. App creates optimal schedule (15-25 talks)
4. Review conflicts (if any)
5. Manual adjustments as needed

**How Auto-Generate Works**:
- Prioritizes your 5-star talks
- Adds keyword-matched talks
- Avoids time conflicts
- Groups by building when possible
- Removes incompatible talks automatically

### Method 3: Hybrid Approach
1. Manually add 5-10 must-see talks
2. Click "Generate Schedule"
3. Auto-generator fills in around your selections
4. Review and tweak as needed

### Viewing Your Schedule

#### What You See
- Talks organized by date
- Grouped by day (Saturday, Sunday)
- Chronological ordering
- Each entry shows:
  - Time (10:00 - 10:45)
  - Talk title
  - Speaker name
  - Building location
  - Remove button

#### Empty Schedule
```
No talks in your schedule yet
Add talks or click "Generate Schedule"
```

### Scrolling & Organization
- Schedule scrolls if many talks
- Sticky date headers
- Easy to scan day-by-day
- Building badges for quick reference

---

## Managing Conflicts

### Understanding Conflicts

#### What's a Conflict?
Two talks at the same time on the same day:
```
❌ Conflict Example:
10:00 - 10:45: Talk A
10:15 - 11:00: Talk B  ← Overlaps with Talk A!
```

```
✅ No Conflict:
10:00 - 10:45: Talk A
10:45 - 11:30: Talk B  ← Starts when A ends
```

### Detecting Conflicts

#### Visual Indicators
1. **Red borders** on talk cards
2. **Red timeline slots** in schedule
3. **Warning banner** shows count:
   ```
   ⚠️ You have 3 time conflicts
   ```

#### Finding Conflicts
1. Look for red highlighting
2. Check schedule section for conflict warning
3. Read the exact times when clicked

### Resolving Conflicts

#### Option 1: Remove Lower Priority Talk
1. Identify both conflicting talks
2. Check ratings (which is lower?)
3. Click "Remove" on lower-rated talk
4. Conflict resolved ✓

#### Option 2: Use Plan B
1. Note the time slot
2. Search for talks in same building
3. Find alternative with better time
4. Remove original, add alternative

#### Option 3: Check Building Transitions
1. Note building for conflicting talks
2. Look at adjacent time slots
3. Find talks in same building
4. Rearrange to minimize walking

#### Option 4: Use Auto-Generate
1. Clear schedule
2. Click "🤖 Generate Schedule"
3. Algorithm avoids all conflicts
4. May suggest different talks

### Preventing Conflicts

**Manual Approach**:
1. When adding a talk, check schedule
2. Look for overlapping times
3. Adjust before clicking "Add"

**Auto-Generate Approach**:
1. Let the algorithm build schedule
2. It handles all conflict checking
3. Zero conflicts (usually)

---

## Exporting

### Export Options

#### 1️⃣ Text Format
**When to use**: Print, share via email, offline reference

**How**:
1. Click "📥 Export" button
2. Click "📄 Export as Text"
3. File saves: `fosdem-schedule.txt`

**Contents**:
```
FOSDEM 2026 Schedule
=====================

Saturday, January 31, 2026
----------------------------------------

09:00 - 09:45
Opening Keynote
Track: Keynotes
Speakers: Richard Hartmann
Location: K - Main Amphitheatre
```

**Format Benefits**:
- Human-readable
- Printable directly
- Universal compatibility
- Email-friendly

#### 2️⃣ JSON Format
**When to use**: Calendar import, data analysis, backup

**How**:
1. Click "📥 Export" button
2. Click "📋 Export as JSON"
3. File saves: `fosdem-schedule.json`

**Contents**:
```json
{
  "exported": "2026-01-30T14:30:00Z",
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

**Format Benefits**:
- Machine-readable
- Full metadata included
- Calendar app compatible
- Archival-friendly

#### 3️⃣ Print View
**When to use**: Paper backup, offline reference at venue

**How**:
1. Click "🖨️ Print"
2. Ctrl+P (or Cmd+P) to open print dialog
3. Click "Save as PDF"
4. Choose location and save

**Print Features**:
- Clean layout
- No sidebar/buttons
- Full-page schedule
- Print-optimized colors

### Importing Exported Schedules

#### Text Format
- Open `.txt` file in any text editor
- Print directly for hard copy
- Share with friends/colleagues

#### JSON Format
- **Google Calendar**: Copy/paste events
- **Outlook**: Import from file
- **Apple Calendar**: Manual entry from JSON
- **Text Editor**: Review all metadata

---

## Tips & Tricks

### Pro Tips

#### 1. Rate as You Browse
- Rate talks while searching (don't wait until end)
- Builds recommendation training data immediately
- Find similar talks as you rate

#### 2. Use Keyword Search
Instead of browsing all talks, search:
- Specific tools: `python`, `rust`, `kubernetes`
- Topics: `performance`, `ai`, `security`
- Speakers: `alice`, `bob smith`

#### 3. Combine Filters Strategically
```
Step 1: Filter "AI & ML" track
Step 2: Check "Software Performance" track  
Step 3: Search "optimization"
Result: AI talks about optimization
```

#### 4. Generate Early
1. Rate favorite talks (20+ talks)
2. Generate schedule after 30 minutes of browsing
3. Adjust as needed

#### 5. Review Conflicts Immediately
- Don't ignore red conflict indicators
- Resolve before finalizing
- Use "Generate Schedule" to auto-fix

#### 6. Note Building Locations
- Use building filters to minimize walking
- Group morning talks in same building
- Afternoon talks in different building
- Check maps before conference

#### 7. Export Multiple Versions
- Export text for printing
- Export JSON for calendar
- Keep both as backup

#### 8. Use Keyboard for Speed
- Tab to navigate
- Enter to open modals
- Escape to close modals

### Optimization Techniques

#### For Time-Constrained Attendees
1. Filter key track (e.g., "Rust devroom")
2. Select only 5-10 must-see talks
3. Use auto-generate to fill gaps
4. Print and go

#### For Comprehensive Coverage
1. Rate talks across multiple tracks
2. Generate full schedule
3. Review all day-by-day
4. Pick alternates for overlaps
5. Export both text and JSON

#### For Focused Exploration
1. Search specific keywords: `llm`, `agent`, `performance`
2. Rate all relevant talks (5 stars)
3. Generate to see all matches
4. Deep-dive into related sessions

---

## Keyboard Navigation

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `/` | Focus search box |
| `Tab` | Navigate between elements |
| `Enter` | Open talk details modal |
| `Escape` | Close any modal |
| `Ctrl+P` / `Cmd+P` | Print current view |

### Navigation Flow
1. Press `/` to jump to search
2. Type keyword
3. Press `Tab` to move to first result
4. Press `Enter` to open details
5. Press `Tab` to rate stars
6. Press `Escape` to close

---

## Troubleshooting

### Common Issues

#### Schedule Won't Load
**Problem**: "Loading..." spinner stays forever

**Solutions**:
1. Check internet connection
2. Refresh page (F5)
3. Clear browser cache (Ctrl+Shift+Delete)
4. Try different browser
5. App falls back to sample data if XML unavailable

#### Ratings Not Saving
**Problem**: Ratings disappear after refresh

**Solutions**:
1. Check browser storage: Open DevTools (F12)
2. Check if localStorage enabled: Settings > Privacy
3. Clear browser cache
4. Disable browser extensions (Privacy Badger, etc.)
5. Try incognito/private window

#### Search Not Working
**Problem**: Can't find a specific talk

**Solutions**:
1. Try different keywords (partial words)
2. Check if filters are too restrictive
3. Try searching speaker name
4. Browse all talks (remove filters)
5. Check spelling

#### Can't Find a Track
**Problem**: Expected track not showing in filters

**Solutions**:
1. Scroll sidebar to see all tracks
2. Clear filters (click 🗑️ Clear)
3. Refresh schedule (F5)
4. Check sample data note in README

#### Export Not Working
**Problem**: File won't download

**Solutions**:
1. Check browser download settings
2. Check disk space
3. Try different export format
4. Check if pop-ups are blocked
5. Try different browser

#### Schedule Not Generating
**Problem**: "Generate Schedule" button doesn't work

**Solutions**:
1. Rate at least 5 talks first
2. Check if schedule is full (clear to try again)
3. Refresh page
4. Try with fewer filter restrictions
5. Check browser console (F12) for errors

### Data & Privacy

#### My Data Isn't Saving
- Data saves to browser's localStorage
- Some browsers limit storage (~5MB)
- Some privacy modes don't support localStorage
- Try normal mode (not incognito)

#### How to Clear All Data
```
Press F12 → Console → type:
localStorage.removeItem('fosdemSchedule')
```
Then refresh page to start fresh.

#### Is My Data Safe?
✅ **Yes**:
- All data stays on YOUR computer
- No server uploads
- No external tracking
- No account needed
- Fully private

### Browser-Specific Issues

#### Chrome
- Works perfectly
- localStorage works reliably
- PDF printing works great

#### Firefox
- Works perfectly  
- localStorage works reliably
- Print to PDF works

#### Safari
- Works with minor visual differences
- Touch interactions smooth
- Print feature works

#### Edge
- Works perfectly
- Full localStorage support
- Compatible with Windows Print

#### Mobile Browsers
- Touch-friendly
- Responsive design
- May need landscape for comfort
- localStorage works on mobile

---

## Summary

**FOSDEM 2026 Schedule Planner lets you**:
1. 🔍 **Search & filter** talks by keywords, track, building, day
2. ⭐ **Rate** talks to build preference history
3. 📋 **Build schedule** manually or auto-generate
4. ⚠️ **Detect conflicts** and resolve easily
5. 📥 **Export** as text, JSON, or print-friendly PDF
6. 💾 **Persist data** automatically locally

For help, see:
- [README.md](README.md) - Full documentation
- [QUICKSTART.md](QUICKSTART.md) - 60-second guide
- [FEATURES.md](FEATURES.md) - Complete feature list

---

**Happy conference planning! 🎪**

FOSDEM 2026 • January 31 - February 1 • Brussels, Belgium
