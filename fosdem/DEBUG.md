# Debugging "Error Loading Schedule"

If you see an error toast saying "Error loading schedule", here's how to fix it:

## Quick Diagnosis

1. **Open** `test-json.html` in your browser
   - Shows if `schedule.json` is valid and loadable
   - Lists actual talks found
   - Helpful error messages if something's wrong

2. **Open browser console** (Press F12)
   - Click "Console" tab
   - See detailed load logs
   - Look for red error messages

## Step-by-Step Troubleshooting

### Step 1: Check File Location
**The Problem**: `schedule.json` is not where the app expects it

**How to Fix**:
1. Make sure `schedule.json` exists in the same folder as `index.html`
2. Verify file name is exactly `schedule.json` (case-sensitive on some systems)
3. Not in a subfolder - should be at root level:
   ```
   fosdem/
   ├── index.html          ← Main app
   ├── schedule.json       ← Must be here
   ├── README.md
   └── ...other files
   ```

### Step 2: Check File Encoding
**The Problem**: File might be saved in wrong encoding (e.g., UTF-16 instead of UTF-8)

**How to Check**:
1. Open `schedule.json` in a text editor
2. Check "Encoding" or "Character Set" (usually in File menu)
3. Should be "UTF-8"
4. If not, re-save as UTF-8 and try again

### Step 3: Validate JSON Syntax
**The Problem**: JSON has syntax errors (missing comma, bracket, quote, etc.)

**How to Check**:
1. Visit https://jsonlint.com
2. Copy contents of `schedule.json`
3. Paste into the validator
4. It will show exact line with error
5. Or just open `test-json.html` (see below)

### Step 4: Check Browser Network Tab
**The Problem**: Fetch request is failing silently

**How to Debug**:
1. Open browser (F12) → Network tab
2. Reload page (Ctrl+R)
3. Look for `schedule.json` in the request list
4. If **red**: Shows status (404=not found, 403=forbidden, etc.)
5. If **not listed**: File path is wrong

### Step 5: Check Server/Serving
**The Problem**: Opening file locally vs. via HTTP server

**Issue**: If you just double-click `index.html`, some browsers block file access
- Works: Some scenarios
- Better: Serve via HTTP with simple server:
  ```bash
  # Python 3
  python -m http.server 8000
  
  # Python 2
  python -m SimpleHTTPServer 8000
  
  # Node.js
  npx http-server
  ```
  Then open: `http://localhost:8000`

## Detailed Console Log Reading

After opening Developer Tools (F12 → Console), you should see:

### If Everything Works:
```
Starting schedule load...
Attempting to load local schedule.json
Fetching ./schedule.json...
Fetch response status: 200 OK
Received 9234 bytes from schedule.json
JSON parsed successfully
Found 20 talks in schedule.json
Successfully converted 20 talks to internal format
Total talks in state: 20
Schedule loading complete
```

### If Local File Not Found:
```
Starting schedule load...
Attempting to load local schedule.json
Fetching ./schedule.json...
Fetch response status: 404 Not Found         ← Problem: file not found
Local schedule.json not found (404), will try FOSDEM...
Attempting to download from FOSDEM...
```

### If JSON Parse Error:
```
Fetch response status: 200 OK
Received 1234 bytes from schedule.json
Failed to parse schedule.json as JSON: SyntaxError: ...
Raw content preview: {invalid json here...
```

## Using test-json.html

This helper file validates everything:

1. **Open** `test-json.html` in browser
2. **It shows**:
   - ✓ If JSON is valid
   - ✓ How many talks loaded
   - ✓ First talk details
   - ✗ Any missing fields
   - ✗ Clear error messages if anything's wrong

## Common Errors & Fixes

### "404 Not Found"
**Cause**: File doesn't exist or is in wrong location

**Fix**:
- Put `schedule.json` in root folder (same as `index.html`)
- Check spelling: must be exactly `schedule.json`

### "SyntaxError: Unexpected token"
**Cause**: JSON is malformed

**Fix**:
- Check for missing commas between objects
- Check for unmatched quotes, brackets, braces
- Use https://jsonlint.com to validate
- Or use `test-json.html`

### "talks is not an array"
**Cause**: JSON structure is wrong

**Fix**:
- JSON must have: `{ "talks": [ ... ] }`
- Make sure `talks` is inside an object
- Check it's `[...]` (array), not `{...}` (object)

### CORS Errors (if serving via HTTP)
**Cause**: Browser blocking local file access

**Fix**:
- Serve via HTTP (see "Check Server/Serving" above)
- Don't just double-click HTML file

## If All Else Fails

**Option 1: Delete schedule.json**
- App will automatically try to download from FOSDEM
- Takes 2-3 seconds but works if internet connected

**Option 2: Use the test helper**
1. Open `test-json.html`
2. See the actual error
3. Fix based on what it shows

**Option 3: Check console carefully**
- Every step is logged
- Error messages tell you what went wrong
- Line numbers show exactly where problem is

## File Requirements

### schedule.json Format
Must be valid JSON with this structure:
```json
{
  "conference": {
    "title": "FOSDEM 2026",
    ...
  },
  "talks": [
    {
      "id": "unique-id",
      "title": "Talk Title",
      "speakers": "Name",
      "abstract": "Description",
      "track": "Track Name",
      "day": 1,
      "date": "2026-01-31",
      "start_time": "10:00",
      "end_time": "10:45",
      "duration": "00:45",
      "room": "Room Number",
      "building": "Building Letter"
    }
    ...
  ]
}
```

### Requirements:
- Valid JSON (no syntax errors)
- Must have `talks` array with at least 1 talk
- Each talk needs: id, title, speakers, track, day, date, start_time, end_time, room, building
- UTF-8 encoding
- File size should be reasonable (< 1 MB)

## Getting Help

1. **See exact error**: Open browser console (F12)
2. **Test JSON**: Open `test-json.html`
3. **Verify file**: Check file location and encoding
4. **Check syntax**: Use jsonlint.com
5. **Try FOSDEM**: Delete `schedule.json` to trigger FOSDEM download

## Log Examples

### Success Path
```
✓ Schedule loaded: 20 talks ready
```

### Fallback Path
```
Local schedule.json not found (404), will try FOSDEM...
Downloading from FOSDEM...
Downloaded FOSDEM XML, parsing...
Successfully loaded 152 talks from FOSDEM
✓ Schedule loaded: 152 talks ready
```

### Error Path
```
Error: No schedule data available. Check console for details.
=== TROUBLESHOOTING ===
1. Is schedule.json in the same folder as index.html?
2. Is schedule.json valid JSON? (check syntax)
3. Do you have internet? (needed if schedule.json missing)
4. Check browser Network tab (F12) for failed requests
```

---

**TL;DR**: 
1. Make sure `schedule.json` is in the same folder as `index.html`
2. Open browser console (F12) to see detailed logs
3. Or open `test-json.html` to validate the file
4. Check for typos, encoding, and syntax errors
