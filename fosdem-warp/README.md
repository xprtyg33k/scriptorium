# FOSDEM 2026 Schedule Planner

An interactive single-page web application to help you plan your attendance at FOSDEM 2026 in Brussels, Belgium. Discover talks, rate them, get personalized recommendations, and build an optimized schedule.

![FOSDEM 2026 Schedule Planner](https://img.shields.io/badge/FOSDEM-2026-blue)
![Status](https://img.shields.io/badge/status-ready-green)

## 🚀 Features

### 📋 Talk Discovery & Filtering
- **Real-time search** by title, speaker, keyword, or track
- **Smart filtering** by tracks, buildings, days, and time slots
- **Priority track highlighting** for AI/ML, Rust, Performance, and CI/CD topics
- **Location-aware grouping** to minimize walking between buildings
- **Visual rating system** with 1-5 star ratings

### 🧠 Smart Recommendations
- **Keyword-based suggestions** matching: LLM, agent, agentic, Rust, performance, optimization, CI/CD, DevOps
- **Track-based recommendations** from priority topics
- **Similarity engine** suggesting talks based on your highly-rated selections
- **Real-time updates** as you rate more talks

### 📅 Schedule Builder
- **Auto-generate schedules** prioritizing highest-rated talks without conflicts
- **Conflict detection** with visual warnings for overlapping talks
- **Timeline view** showing day-by-day schedule with times and locations
- **Manual management** - add/remove talks from schedule
- **Visual priority coding** - color-coded by rating level

### 💾 Export & Persistence
- **Text export** - Clean, printable format with all talk details
- **JSON export** - Full data for external processing
- **localStorage** - Automatic saving of ratings and schedules
- **Print-friendly view** - Optimized for paper backup

### 🎨 User Experience
- **Responsive design** - Works on desktop, tablet, and mobile
- **Fast performance** - Client-side processing, no backend needed
- **Smooth animations** - Polished transitions and interactions
- **Empty states** - Helpful guidance when no data is available
- **Modal details** - Click any talk for full information

## 🏁 Quick Start

### Prerequisites
- A modern web browser (Chrome, Firefox, Safari, Edge)
- Internet connection (to fetch FOSDEM schedule)

### Installation

1. **Download the files**
   ```powershell
   # Clone or download this repository
   git clone https://github.com/yourusername/fosdem-2026-planner.git
   cd fosdem-2026-planner
   ```

2. **Run the server**
   
   The easiest way is to use the included `serve.py` script, which automatically:
   - Downloads the full FOSDEM 2026 schedule (if not already cached)
   - Serves it locally to avoid CORS issues
   - Caches the schedule for 1 hour
   
   ```powershell
   python serve.py
   ```
   
   Then open your browser to: **http://localhost:8000**
   
   **Alternative methods:**
   ```powershell
   # Manual approach (download schedule first)
   curl -o schedule.xml https://fosdem.org/2026/schedule/xml
   python -m http.server 8000
   
   # Or with Node.js
   npx serve
   ```

3. **Start planning!**
   - The app will automatically fetch the FOSDEM 2026 schedule
   - Begin rating talks and exploring recommendations

## 📖 Usage Guide

### 1. Discover Talks

**Search & Filter**
- Use the search bar to find talks by keywords
- Click track tags to filter by topic (priority tracks highlighted in purple)
- Filter by building to group nearby talks
- Filter by day for focused planning

**Rate Talks**
- Click stars to rate talks 1-5 (click same star to unrate)
- Color-coded borders show priority:
  - 🔴 Red = 5 stars (Must See)
  - 🟠 Orange = 3-4 stars (Interested)
  - 🟢 Green = 1-2 stars (Maybe)

**View Details**
- Click any talk card to see full abstract and description
- Add to schedule directly from detail modal
- View links to FOSDEM website for more info

### 2. Get Recommendations

Navigate to the **Recommendations** tab to see personalized suggestions:

- **Priority keyword matches**: Talks containing LLM, agent, Rust, performance, etc.
- **Similar content**: Talks in same tracks as your highly-rated selections
- **Reason indicators**: See why each talk was recommended
- Rate recommendations directly to refine suggestions

### 3. Build Your Schedule

**Auto-Generate** (Recommended)
1. Rate at least 10-20 talks
2. Click **🤖 Auto-Generate Schedule**
3. Algorithm optimizes for:
   - Highest-rated talks first
   - No time conflicts
   - Minimal building transitions

**Manual Management**
- Click talks to add/remove from schedule
- View schedule in **My Schedule** tab
- Conflicts highlighted with ⚠️ warning badges

**Schedule View**
- Side-by-side day layout
- Time-ordered talks with durations
- Building and room locations
- Star ratings displayed

### 4. Export Your Schedule

From the **My Schedule** tab:

- **📄 Export as Text**: Printable format with all details
  ```
  ═══════════════════════════════════════════════
    FOSDEM 2026 - Personal Schedule
    Brussels, Belgium
  ═══════════════════════════════════════════════
  
  ━━━ DAY 1 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  09:00 - H.2215 (Building H)
  Building Large Language Models from Scratch
  Speaker(s): Jane Doe
  Track: AI, Machine Learning & Data
  Rating: ★★★★★
  Duration: 00:50
  ```

- **📊 Export as JSON**: Full data structure
- **🖨️ Print Schedule**: Browser print dialog for paper copy

## 🎯 Priority Topics

The app is pre-configured to prioritize:

### Tracks
- AI, Machine Learning & Data
- Rust
- Go (performance topics)
- Continuous Integration and Deployment

### Keywords
- LLM, Large Language Model
- Agent, Agentic systems
- Rust programming
- Performance, Optimization, Profiling
- CI/CD, DevOps, Automation
- Machine Learning, AI

These can be modified in the JavaScript code (lines 638-639).

## 🏗️ Technical Details

### Architecture
- **Single-file application**: All HTML, CSS, and JavaScript in one file
- **No dependencies**: Pure vanilla JavaScript, no frameworks
- **Client-side only**: No backend required
- **Data source**: FOSDEM 2026 XML schedule at https://fosdem.org/2026/schedule/xml

### Browser Storage
- **localStorage** used for:
  - Talk ratings (key: `fosdem-ratings`)
  - Schedule selections (key: `fosdem-schedule`)
- Data persists across browser sessions
- Clear browser data to reset

### Performance
- Initial load: < 3 seconds (depends on FOSDEM XML size)
- Real-time filtering: < 100ms
- Supports 500+ talks without performance degradation

### Browser Compatibility
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## 📊 Example Workflow

Here's a recommended workflow for first-time users:

1. **Initial Exploration** (5 minutes)
   - Let schedule load
   - Browse all talks without filters
   - Get familiar with UI

2. **Focused Discovery** (15 minutes)
   - Apply priority track filters
   - Search for specific keywords (e.g., "rust", "llm")
   - Rate 15-20 interesting talks

3. **Check Recommendations** (5 minutes)
   - Review suggested talks
   - Rate recommendations to refine

4. **Generate Schedule** (5 minutes)
   - Click auto-generate
   - Review for conflicts
   - Manually adjust if needed

5. **Export & Prepare** (2 minutes)
   - Export as text for offline reference
   - Print schedule as backup
   - Save JSON for later analysis

## 🔧 Customization

### Change Priority Keywords
Edit line 638 in `index.html`:
```javascript
priorityKeywords: ['your', 'custom', 'keywords', 'here'],
```

### Change Priority Tracks
Edit line 639 in `index.html`:
```javascript
priorityTracks: ['Your Track Name', 'Another Track'],
```

### Modify Styling
All CSS is in the `<style>` section (lines 7-525). CSS variables at the top (lines 14-30) control colors:
```css
--primary: #3b82f6;    /* Main blue color */
--secondary: #8b5cf6;  /* Purple for recommendations */
--success: #10b981;    /* Green for confirmations */
```

## 🐛 Troubleshooting

**Schedule won't load**
- **Most common issue**: CORS restrictions when opening file directly
  - ✅ **Solution**: Serve from a local web server (see Quick Start)
  - Run: `python -m http.server 8000` and open `http://localhost:8000`
- Check internet connection
- Verify FOSDEM XML URL is accessible
- Try clicking "📊 Load Demo Data" to test with sample data
- Check browser console (F12) for detailed errors

**Ratings disappeared**
- Check if browser cleared localStorage
- Don't use incognito/private mode
- Export schedule regularly as backup

**Conflicts not detected**
- Ensure talks are on the same day
- Check time format is correct
- Conflicts only shown in Schedule tab

**Export button not working**
- Ensure you have at least one talk scheduled
- Check browser allows downloads
- Try different export format

## 📝 Sample Export Format

### Text Export
```
═══════════════════════════════════════════════
  FOSDEM 2026 - Personal Schedule
  Brussels, Belgium
═══════════════════════════════════════════════

━━━ DAY 1 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

10:00 - H.1301 (Building H)
Rust Performance Optimization Techniques
Speaker(s): John Smith
Track: Rust
Rating: ★★★★★
Duration: 00:50
URL: https://fosdem.org/2026/schedule/event/1234

11:00 - H.1301 (Building H)
Building Agentic Systems with LLMs
Speaker(s): Alice Johnson
Track: AI, Machine Learning & Data
Rating: ★★★★☆
Duration: 00:45
```

### JSON Export
```json
[
  {
    "id": "1234",
    "title": "Rust Performance Optimization Techniques",
    "track": "Rust",
    "type": "Talk",
    "abstract": "Learn advanced techniques...",
    "persons": ["John Smith"],
    "day": "1",
    "start": "10:00",
    "duration": "00:50",
    "room": "H.1301",
    "building": "Building H",
    "url": "https://fosdem.org/2026/schedule/event/1234"
  }
]
```

## 🚀 Future Enhancements

Potential features for future versions:

- [ ] Dark mode toggle
- [ ] iCal/ICS export for calendar apps
- [ ] Share schedule via URL encoding
- [ ] Historical comparison with FOSDEM 2025
- [ ] Weather widget for Brussels
- [ ] Venue map integration
- [ ] Collaborative features (share with friends)
- [ ] Mobile app version
- [ ] Offline PWA support
- [ ] CSV export option

## 📄 License

This project is provided as-is for personal use. FOSDEM schedule data is © FOSDEM and used under their terms.

## 🙏 Acknowledgments

- **FOSDEM** for the amazing conference and open schedule data
- **FOSDEM organizers** for making this possible
- Built with ❤️ for the open source community

## 📧 Support

For issues or questions:
1. Check the Troubleshooting section
2. Review the Usage Guide
3. Open an issue on GitHub (if applicable)

---

**Happy planning! See you at FOSDEM 2026! 🎉**
