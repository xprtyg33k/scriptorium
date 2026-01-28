# Quick Troubleshooting Checklist

## Seeing "Error loading schedule"?

Follow this checklist in order:

### ✓ Step 1: Verify File Exists (30 seconds)
- [ ] Is `schedule.json` in the **same folder** as `index.html`?
  - ❌ Wrong: `fosdem/subfolder/schedule.json`
  - ✅ Right: `fosdem/schedule.json`
- [ ] Is the filename exactly `schedule.json` (case matters on some systems)?
- [ ] File is not corrupted (size ~8 KB)?

**Fix if missing**: 
- Copy `sample-schedule.json` and rename to `schedule.json`
- Or download a fresh one from source

### ✓ Step 2: Test with Helper File (30 seconds)
- [ ] Open `test-json.html` in your browser
- [ ] Does it show "✓ JSON is valid!"?
  - If YES → Problem is elsewhere, go to Step 3
  - If NO → Shows you the exact error, fix that error

### ✓ Step 3: Check Browser Console (1 minute)
- [ ] Press **F12** to open Developer Tools
- [ ] Click **Console** tab
- [ ] Scroll up to see initial logs
- [ ] Do you see "Starting schedule load..."?

**What to look for**:
```
✓ "Found X talks in schedule.json" → File is OK, problem elsewhere
✗ "404 Not Found" → File not in right location
✗ "SyntaxError" → JSON has errors
✗ "Failed to parse" → File encoding wrong
```

### ✓ Step 4: Check Network Tab (1 minute)
- [ ] Press **F12** → **Network** tab
- [ ] Reload page (**Ctrl+R** or **Cmd+R**)
- [ ] Look for `schedule.json` in the list
- [ ] Is it **green** (loaded) or **red** (failed)?

**If green**: File downloaded fine, check console error
**If red**: File not found - check file location
**If not in list**: Fetch path might be wrong

### ✓ Step 5: Try the Fallback (30 seconds)
- [ ] Delete `schedule.json` (or rename to backup)
- [ ] Reload `index.html`
- [ ] App will try to download from FOSDEM
- [ ] This confirms if the problem is the local file

### ✓ Step 6: Check File Encoding (1 minute)
- [ ] Open `schedule.json` in text editor
- [ ] Find encoding setting (File menu usually)
- [ ] Is it "UTF-8"?
  - If NO: Save as UTF-8 and try again
  - If YES: Go to next step

### ✓ Step 7: Validate JSON Syntax (1 minute)
- [ ] Visit https://jsonlint.com
- [ ] Copy contents of `schedule.json`
- [ ] Paste into validator
- [ ] Does it say "Valid"?
  - If YES: File is OK, problem elsewhere
  - If NO: Shows error line, fix it

### ✓ Step 8: Try HTTP Server (2 minutes)

**If just double-clicking HTML file**:
Some browsers block local file access.

**Fix - serve via HTTP**:
```bash
# Python 3
python -m http.server 8000

# Then visit: http://localhost:8000
```

- [ ] Open http://localhost:8000 in browser
- [ ] Does it work now?

### ✓ Step 9: Clear Browser Cache (1 minute)
- [ ] Press **Ctrl+Shift+Delete** (or Cmd+Shift+Delete)
- [ ] Select "All time"
- [ ] Clear cache
- [ ] Reload page

### ✓ Step 10: Try Different Browser
- [ ] Try Chrome, Firefox, Safari, or Edge
- [ ] Same error? → Problem with file
- [ ] Different browser works? → Browser-specific issue

---

## Common Solutions

### "File not found (404)"
**Fastest fix**:
1. Delete `schedule.json`
2. Reload page
3. App downloads from FOSDEM (takes 3 seconds, works if internet connected)

### "Invalid JSON"
**Fastest fix**:
1. Copy `sample-schedule.json`
2. Rename to `schedule.json`
3. Reload page

### "Still doesn't work"
1. Open `test-json.html` - shows exact problem
2. Open console (F12 → Console) - shows all logs
3. See `DEBUG.md` for detailed help

---

## What to Tell Support

If you still have problems, provide:

1. **Screenshot of error**
2. **Browser console output** (F12 → Console → all red text)
3. **Output from test-json.html**
4. **Your file structure**:
   ```
   fosdem/
   ├── index.html
   ├── schedule.json  ← Is this here?
   └── ...
   ```
5. **How you're opening the file**:
   - [ ] Double-click in file explorer?
   - [ ] Via http://localhost?
   - [ ] On a web server?

---

## TL;DR Quick Fixes (in order)

1. **Is `schedule.json` in the right folder?** → Move it to root
2. **Open `test-json.html`** → See what's wrong
3. **Open console (F12)** → Look for errors
4. **Delete `schedule.json`, reload** → Forces FOSDEM download
5. **Serve via HTTP** → Use python -m http.server 8000
6. **Clear cache** → Ctrl+Shift+Delete

---

## Success Indicators

When loading works, you should see:

✓ Loading spinner animates  
✓ Status changes: "Loading..." → "Parsing..." → "Rendering..."  
✓ Success toast: "✓ Schedule loaded: 20 talks ready"  
✓ App shows talks immediately  
✓ No red error messages in console  

---

See `DEBUG.md` for more detailed troubleshooting.
