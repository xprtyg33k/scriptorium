# Output 5: HTML + CSS Artifact Recommendations

These artifacts are designed to be simple, functional, and immediately useful. Each one should be buildable in plain HTML + CSS (no frameworks required, no JavaScript unless optional interactivity is desired). They should work in a browser, be printable, and be embeddable in Confluence or Teams.

---

## Artifact 1: Visible Agenda Page

**Purpose:** Single-page, clean reference for participants before and during the onsite. Replaces a PDF or slide-based agenda.

**Audience:** All onsite participants.

**Content:**
- Onsite theme, dates, location
- Day 1 and Day 2 schedule with time blocks, session titles, and brief descriptions
- Prep instructions (bring evidence of wins, draft personal vision template)
- Guest schedule (Dan, Clarissa)
- Logistics (room, parking, dinner details)

**Why HTML + CSS:** A printed agenda gets lost. A shared HTML page can be updated in real-time if schedules shift, bookmarked on phones, and referenced throughout the day. Clean responsive design means it works on any device.

**Design notes:** Two-column layout for Day 1 / Day 2. Time blocks as cards. Color-coded by session type (discussion, exercise, guest, break). No images. Clean typography. Print-friendly.

---

## Artifact 2: Commitments Board

**Purpose:** Capture and display every commitment made during the onsite. Serves as the single source of truth for follow-through.

**Audience:** All onsite participants + Guillermo (for follow-through tracking).

**Content:**
- Each commitment as a card with: person name, commitment text, deadline, accountability partner, status (open / in progress / complete)
- Sections:
  - Personal 30-day commitments (from closing round)
  - Team SMART goals (from whiteboard exercise, with owners)
  - Security/engineering alignment commitments (from Dan session)
  - Product/engineering alignment commitments (from Clarissa session)
  - AI governance decisions
  - Continue/Start/Stop behavioral commitments

**Why HTML + CSS:** A Confluence table is functional but ugly and hard to scan. A purpose-built commitments board with card layout, color-coded status, and clear ownership makes follow-through visible and public. Can be embedded in Teams as a tab.

**Design notes:** Card grid layout. Each card shows name, commitment, deadline, partner, status badge. Filter/sort by person or status (optional JS). Print as a wall poster for the conference room.

---

## Artifact 3: Personal Vision and Goals Tracker

**Purpose:** Collect and display each leader's personal vision statement and quarterly goals in a format that can be revisited at the next onsite.

**Audience:** All onsite participants.

**Content:**
- One section per leader with:
  - Name and role
  - Vision statement for the remainder of 2026
  - 2-3 quarterly goals
  - Alignment to collective goals (one sentence)
  - Named gap between intent and current behavior
  - Date of last update

**Why HTML + CSS:** The BYB template is a PDF. Personal vision statements written on paper get filed and forgotten. An HTML tracker keeps them visible, shareable, and revisitable. At the next onsite, pull this up and compare stated vision to actual behavior.

**Design notes:** Accordion or card layout. One card per person. Expandable to show full detail. Print-friendly for wall display. Option to include a "progress note" field that gets updated monthly.

---

## Artifact 4: Continue / Start / Stop Board

**Purpose:** Display the Continue/Start/Stop outputs from the onsite in a format that stays visible and can be referenced in weekly meetings.

**Audience:** All onsite participants.

**Content:**
- Three columns: Continue / Start / Stop
- Each item as a card with: behavior description, vote count (from the exercise), owner (if assigned), status
- Top 3-5 items per column highlighted as priority commitments

**Why HTML + CSS:** Sticky notes on a wall are powerful in the moment but gone by the next day. An HTML board preserves the output, keeps it visible in Teams, and can be referenced when someone drifts back to a "stop" behavior.

**Design notes:** Three-column Kanban-style layout. Cards with brief text. Priority items have a visual highlight (bold border, different background). Fits on a single screen. Printable as a poster.

---

## Artifact 5: Onsite Recap Page

**Purpose:** Single-page summary of the onsite for anyone who needs to understand what happened and what was decided. Useful for Saji, peers outside SEL, and future reference.

**Audience:** Onsite participants, Saji, adjacent leaders.

**Content:**
- Theme and dates
- Attendees
- Key outcomes (5-7 bullet summary)
- Evidence-backed wins (top 5 from retrospective)
- Team SMART goals (the full list with owners)
- Key decisions made (security, product, AI governance)
- Personal commitments summary (one line per person)
- Follow-through cadence
- Photos of wall artifacts (optional)

**Why HTML + CSS:** A Confluence page works but tends to be long and unstructured. A purpose-built recap page with clean sections, visual hierarchy, and printability serves as both a communication tool (send to Saji) and a reference document (pull up at next onsite).

**Design notes:** Single long page with clear section headers. Summary at top, detail below. Printable as a 2-3 page document. Include a "last updated" timestamp.

---

## Artifact 6: Metrics and Outcomes Dashboard (Optional, Higher Effort)

**Purpose:** Display the team's agreed metrics, baselines, current values, and targets in a single view. Updated weekly or monthly.

**Audience:** SEL team, Saji.

**Content:**
- Metrics organized by the Q425 three-tier model:
  1. Outcome signals (customer-facing: NPS, retention, uptime)
  2. Flow signals (team-controlled: cycle time, deployment frequency, sprint commitment accuracy)
  3. Quality signals (trust-protecting: escape defect rate, change failure rate, MTTR)
- Each metric shows: name, owner, baseline, current value, target, trend indicator (up/down/flat)

**Why HTML + CSS:** Scott Seely built a KPI dashboard. Rafael built a Sprint health dashboard. But these are separate tools pulling from different sources. A simple, manually-updated HTML dashboard that shows the agreed-upon shortlist of metrics in one view creates shared visibility. It doesn't need to be automated; manual weekly update is sufficient if the metrics are the right ones.

**Design notes:** Table layout with sparkline-style trend indicators (CSS-only or simple SVG). Green/yellow/red status colors. Fits on one screen. Printable. This is the highest-effort artifact on the list and should only be built if the team agrees on the metrics during the onsite.

---

## Priority Order for Building

| Priority | Artifact | Effort | Impact |
|----------|----------|--------|--------|
| 1 | Visible Agenda Page | Low (2-3 hours) | High (immediate use before onsite) |
| 2 | Commitments Board | Medium (4-6 hours) | High (drives follow-through) |
| 3 | Onsite Recap Page | Low (2-3 hours) | High (communication and reference) |
| 4 | Continue/Start/Stop Board | Low (2-3 hours) | Medium (behavioral reference) |
| 5 | Personal Vision Tracker | Medium (4-6 hours) | Medium (quarterly revisit) |
| 6 | Metrics Dashboard | Higher (8-12 hours) | High if metrics are agreed, low if not |
