# FOSDEM 2026 Schedule Planner - Test Instructions

## What Changed
1. **Fixed date parsing**: Talks are now correctly split between Day 1 (Jan 31) and Day 2 (Feb 1)
   - Day 1: 545 talks
   - Day 2: 513 talks
   - Total: 1,058 talks across 71 tracks

2. **Added Reload Button**: New "🔄 Reload" button in the Actions panel to:
   - Force reload the entire schedule
   - Clear all filters and selections
   - Reset the schedule to fresh state

3. **Enhanced Debugging**: Browser console now shows:
   - Number of talks loaded
   - Breakdown by day (Day 1 vs Day 2)
   - Any errors with detailed stack traces

## How to Test

### 1. Open the Page
Simply open `index.html` in your web browser. The schedule should load automatically with all 1,058 talks.

### 2. Verify Data Loaded
- Check the **Talks** panel:  
  Should show "Total: 1058"
  Should show breakdown by day in console (F12 > Console)

- Check the **Day** filter buttons:
  - "Day 1" should show ~545 talks
  - "Day 2" should show ~513 talks

### 3. Verify Dates Are Correct
- Look at talk dates in the cards
- They should be either "2026-01-31" (Day 1) or "2026-02-01" (Day 2)
- Sample talks:
  - "Welcome to FOSDEM 2026" → Jan 31, Day 1
  - "Free as in Burned Out..." → Feb 1, Day 2

### 4. Test the Reload Button
- Click the 🔄 **Reload** button
- All talks should reload fresh from EMBEDDED_SCHEDULE
- Filters should reset
- Console should show loading progress

### 5. Enable Debug Output
Open browser Developer Tools (F12), go to Console tab:
- You'll see detailed loading information
- Total talks count
- Day 1/Day 2 split
- Any errors with full stack traces

## If Page Doesn't Display

1. **Open Developer Tools** (F12)
2. **Check the Console** tab for errors
3. **Click the Reload button** to force refresh
4. **Try hard refresh** (Ctrl+Shift+R on Windows/Linux, Cmd+Shift+R on Mac)

## File Structure
- `index.html` - Complete app with all 1,058 talks embedded
- No external files needed
- No network requests
- Fully offline-capable

## Data Format
Each talk includes:
- `id`: Unique identifier
- `title`: Talk name
- `speakers`: Speaker(s) name(s)
- `abstract`: Description
- `track`: Devroom/track name
- `day`: 1 or 2
- `date`: ISO format (2026-01-31 or 2026-02-01)
- `start_time`: HH:MM format
- `end_time`: HH:MM format
- `duration`: HH:MM format
- `room`: Room number/name
- `building`: ULB campus building

## Features
- ✓ Search by title/speaker/keyword
- ✓ Filter by track, building, day
- ✓ 5-star rating system (saves to localStorage)
- ✓ Build personal schedule
- ✓ Conflict detection for overlapping times
- ✓ Auto-generate schedule with recommendations
- ✓ Export schedule as text or JSON
- ✓ Print schedule
- ✓ Force reload capability

Ready to explore the full FOSDEM 2026 schedule!
