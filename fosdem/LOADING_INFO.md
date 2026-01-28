# Loading & Data Management

## How Data Loading Works

The FOSDEM 2026 Schedule Planner uses a smart three-tier loading strategy:

### Priority Order

1. **Local `schedule.json` (fastest)** ✅
   - Loads from the included `schedule.json` file
   - ~20 talks with full metadata
   - Instant load (< 100ms)
   - **This is what loads by default**

2. **FOSDEM Official XML (fallback)**
   - If `schedule.json` not found, fetches from FOSDEM
   - Full FOSDEM 2026 schedule (~150+ talks)
   - Download + parsing takes 2-3 seconds
   - Happens automatically if needed

3. **Error Handling**
   - If both sources fail, shows error message
   - No stuck spinner or blank screen
   - Clear feedback on what went wrong

### Loading Progress Indicator

The app now shows **real-time status updates**:
- "Loading schedule..." (starting)
- "Loading local schedule..." (checking local file)
- "Downloading FOSDEM schedule..." (fetching if needed)
- "Parsing data..." (processing)
- "Rendering interface..." (building UI)

Each status is displayed with a spinner so you know it's working.

## For Development/Customization

### Using Local Data
The default `schedule.json` contains 20 sample talks. To add more:

1. **Edit `schedule.json`**
   - Add more talk objects to the `talks` array
   - Follow the existing format:
     ```json
     {
       "id": "talk-xyz",
       "title": "Talk Title",
       "speakers": "Speaker Name",
       "abstract": "Description here",
       "track": "Track Name",
       "day": 1,
       "date": "2026-01-31",
       "start_time": "10:00",
       "end_time": "10:45",
       "duration": "00:45",
       "room": "Room 101",
       "building": "AW"
     }
     ```

2. **Reload the app**
   - App automatically loads updated `schedule.json`
   - New talks appear immediately

### Updating From FOSDEM

To refresh with the latest official FOSDEM schedule:

1. **Delete `schedule.json`** (or rename it)
2. **Open the app**
3. App will:
   - Detect missing local file
   - Download from FOSDEM official XML
   - Parse and display all talks
   - Optionally cache the data

### Performance

| Source | Load Time | Talks |
|--------|-----------|-------|
| Local `schedule.json` | < 100ms | 20 (sample) |
| FOSDEM XML (online) | 2-3 seconds | 150+ |
| Cached (localStorage) | instant | varies |

## No More "Stuck" Spinner

### What Changed
- ✅ **Async loading**: UI stays responsive
- ✅ **Progress updates**: Shows what's happening
- ✅ **Fast fallback**: Local data loads instantly
- ✅ **Error messages**: Clear feedback if something fails
- ✅ **No blocking**: Can interact while loading

### If You See the Spinner
It's updating status. Wait a few seconds:
1. Check browser console (F12) for any errors
2. Verify `schedule.json` exists (or will download)
3. Make sure internet connection works (if using FOSDEM)

### Timeout Handling
If FOSDEM takes too long (> 10 seconds):
- Fetch times out automatically
- App shows error message
- You can still use with local data or try again

## Troubleshooting

### "Loading schedule..." spinner never ends
**Cause**: File not found, slow internet, or browser issue

**Fix**:
1. Check browser console: Open F12 → Console
2. Look for error messages
3. Refresh page (Ctrl+R)
4. Try different browser
5. Check internet connection

### "Error loading schedule"
**Cause**: `schedule.json` missing AND internet unavailable

**Fix**:
1. Download official FOSDEM XML and save as `schedule.json`
2. Or add `schedule.json` back to folder
3. Ensure internet connection for FOSDEM fallback

### App loads but no talks visible
**Cause**: `schedule.json` empty or malformed

**Fix**:
1. Check `schedule.json` file is valid JSON
2. Verify `talks` array exists and has objects
3. Use sample `sample-schedule.json` as template
4. Restart browser

## Data File Format

The `schedule.json` file structure:

```json
{
  "conference": {
    "title": "FOSDEM 2026",
    "venue": "ULB Brussels",
    "start_date": "2026-01-31",
    "end_date": "2026-02-01"
  },
  "talks": [
    {
      "id": "unique-id",
      "title": "Talk Title",
      "speakers": "John Doe, Jane Smith",
      "abstract": "Talk description",
      "track": "AI & ML",
      "day": 1,
      "date": "2026-01-31",
      "start_time": "10:00",
      "end_time": "10:45",
      "duration": "00:45",
      "room": "Room 101",
      "building": "AW"
    }
  ]
}
```

## Local vs. Remote

### Local `schedule.json` Advantages
✅ Instant load (no network needed)
✅ Predictable (no server downtime)
✅ Easy to customize
✅ Works offline

### FOSDEM XML Advantages
✅ Official complete schedule
✅ More talks (150+)
✅ Auto-updates if FOSDEM changes
✅ No file management needed

## Caching

The app also uses **browser localStorage** to cache:
- Your ratings (1-5 stars)
- Your schedule (selected talks)
- Your filters/preferences

This is separate from the schedule data source.

---

**TL;DR**: The app loads fast from local `schedule.json` by default. If you delete that file, it downloads from FOSDEM automatically. No more stuck spinners!
