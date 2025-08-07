import requests
import base64
import os
import sys
from datetime import datetime
from pathlib import Path
from jinja2 import Template

# ----------------------
# Configuration Section
# ----------------------

EMAIL = "guillermo.salas@experityhealth.com"  # << replace with your Atlassian email
API_TOKEN = "ATATT3xFfGF035cNmws1iIwwnZMh09QyY1OQLcPOACsJl7ZQEJJlQMddelXPKcVi5guOqwTMEQX72g0yx3kJuBIVdrdei0DfyAdmPihCK2LDDie3e68-zSofUEqI7Hq9h942Y147HsLiIqjsaqz5ReLs-lnNQMEu1B6c25fE6kqf9vlHd8k377g=A353CE88"  # << replace with your Atlassian API token
DEFAULT_SPACE_KEY = "DEV"              # << default space key
OUTPUT_DIR = "."                       # << output directory

# ----------------------
# Authentication Setup
# ----------------------

auth_string = f"{EMAIL}:{API_TOKEN}"
auth_header = base64.b64encode(auth_string.encode()).decode()
HEADERS = {
    "Authorization": f"Basic {auth_header}",
    "Content-Type": "application/json"
}

BASE_URL = "https://experityhealth.atlassian.net/wiki/rest/api/content"

# ----------------------
# Helper Functions
# ----------------------

def classify_age(created_date_str):
    created_date = datetime.fromisoformat(created_date_str.replace("Z", "+00:00"))
    today = datetime.now(created_date.tzinfo)
    age_days = (today - created_date).days

    if created_date.year == today.year:
        return "Within YTD"
    elif age_days <= 365:
        return "Within 1 year"
    elif age_days <= 730:
        return "Within 2 years"
    elif age_days <= 1825:
        return "Older than 3 years"
    else:
        return "Older than 5 years"

def is_deprecated_account(account_info):
    """
    Check if an account is deprecated.
    This is a placeholder implementation that should be customized based on
    how deprecated accounts are identified in your Confluence instance.
    """
    # Example criteria for deprecated accounts (customize as needed):
    # - Accounts with specific display names indicating deprecation
    # - Accounts that are no longer active in the organization
    # - Accounts with specific email domains that are no longer used
    
    display_name = account_info.get("displayName", "").lower()
    
    # Example patterns for deprecated accounts (modify as needed)
    deprecated_patterns = [
        "deprecated",
        "inactive",
        "former",
        "old user",
        "legacy"
    ]
    
    # Check if any deprecated pattern is in the display name
    for pattern in deprecated_patterns:
        if pattern in display_name:
            return True
    
    # Add more criteria as needed
    return False

def fetch_all_space_content(space_key):
    all_results = []
    start = 0
    limit = 100
    total = None
    print(f"Fetching content for space '{space_key}'...")

    while True:
        # Include ancestors in the expand parameter to get parent information
        url = f"{BASE_URL}?spaceKey={space_key}&limit={limit}&start={start}&expand=history,ancestors"
        resp = requests.get(url, headers=HEADERS)
        resp.raise_for_status()
        data = resp.json()
        results = data.get("results", [])
        if total is None:
            total = data.get("size") or data.get("total") or 0
            if total:
                print(f"Total content items to fetch: {total}")
        all_results.extend(results)
        print(f"  - Fetched {len(all_results)} items so far...")
        if len(results) < limit:
            break
        start += limit

    print(f"Finished fetching {len(all_results)} content items.")
    return all_results

def render_html_report(space_key, grouped_data, output_path):
    template_str = """
    <html>
    <head>
        <title>Confluence Report - {{ space_key }}</title>
        <style>
            :root {
                --red-pantone: #e63946ff;
                --honeydew: #f1faeeff;
                --non-photo-blue: #a8dadcff;
                --cerulean: #457b9dff;
                --berkeley-blue: #1d3557ff;
            }
            body {
                font-family: 'Segoe UI', Arial, sans-serif;
                margin: 40px;
                background: var(--honeydew);
                color: var(--berkeley-blue);
            }
            h1 {
                color: var(--berkeley-blue);
                margin-bottom: 32px;
                letter-spacing: 1px;
            }
            h2 {
                color: var(--cerulean);
                margin-top: 40px;
                cursor: pointer;
                background: var(--non-photo-blue);
                padding: 14px 20px;
                border-radius: 10px 10px 0 0;
                transition: background 0.2s, color 0.2s;
                box-shadow: 0 2px 8px rgba(69,123,157,0.07);
                font-size: 1.2em;
                user-select: none;
            }
            h2:hover, h2.expanded {
                background: var(--cerulean);
                color: var(--honeydew);
            }
            h2::before {
                content: "▶ ";
                font-size: 0.9em;
                color: var(--red-pantone);
                transition: color 0.2s;
            }
            h2.expanded::before {
                content: "▼ ";
                color: var(--honeydew);
            }
            .section-content {
                display: none;
                background: white;
                border-radius: 0 0 12px 12px;
                box-shadow: 0 4px 16px rgba(29,53,87,0.07);
                margin-bottom: 32px;
                padding: 0 0 18px 0;
                transition: max-height 0.3s ease;
            }
            .section-content.expanded {
                display: block;
                animation: fadeIn 0.3s;
            }
            @keyframes fadeIn {
                from { opacity: 0; transform: translateY(-10px);}
                to { opacity: 1; transform: translateY(0);}
            }
            table {
                width: 98%%;
                border-collapse: separate;
                border-spacing: 0;
                margin: 18px auto 0 auto;
                background: var(--honeydew);
                border-radius: 8px;
                overflow: hidden;
                box-shadow: 0 2px 12px rgba(69,123,157,0.08);
            }
            th, td {
                padding: 10px 16px;
                border-bottom: 1px solid var(--non-photo-blue);
                text-align: left;
            }
            th {
                background: var(--cerulean);
                color: var(--honeydew);
                font-weight: 600;
                border-bottom: 2px solid var(--red-pantone);
            }
            tr:last-child td {
                border-bottom: none;
            }
            tr:hover td {
                background: var(--non-photo-blue);
                transition: background 0.2s;
            }
th:nth-child(3), td:nth-child(3) {
                white-space: nowrap;
                min-width: 100px;
            }
            a {
                text-decoration: none;
                color: var(--red-pantone);
                font-weight: 500;
                transition: color 0.2s;
            }
            a:hover {
                color: var(--berkeley-blue);
                text-decoration: underline;
            }
            .no-content {
                color: var(--red-pantone);
                font-style: italic;
                padding: 18px;
            }
        </style>
        <script>
            function toggleSection(sectionId) {
                const section = document.getElementById(sectionId);
                const header = document.getElementById('header-' + sectionId);
                
                if (section.classList.contains('expanded')) {
                    section.classList.remove('expanded');
                    header.classList.remove('expanded');
                } else {
                    section.classList.add('expanded');
                    header.classList.add('expanded');
                }
            }
            
            // Expand the first section by default when page loads
            window.onload = function() {
                const firstSection = document.querySelector('.section-content');
                const firstHeader = document.querySelector('h2');
                if (firstSection && firstHeader) {
                    firstSection.classList.add('expanded');
                    firstHeader.classList.add('expanded');
                }
            };
        </script>
    </head>
    <body>
        <h1>Confluence Content Report: {{ space_key }}</h1>
        
        <!-- Render all sections except "Deprecated Accounts" first -->
        {% for group, items in grouped_data.items() %}
            {% if group != "Deprecated Accounts" %}
            <h2 id="header-section-{{ loop.index }}" onclick="toggleSection('section-{{ loop.index }}')">{{ group }}</h2>
            <div id="section-{{ loop.index }}" class="section-content">
            {% if items %}
                <table>
                    <tr>
                        <th>Title</th>
                        <th>Parent Folder</th>
                        <th>Created</th>
                        <th>Author</th>
                        <th>Link</th>
                    </tr>
                    {% for item in items %}
                    <tr>
                        <td>{{ item.title }}</td>
                        <td>{{ item.parent_folder }}</td>
                        <td>{{ item.created }}</td>
                        <td>{{ item.author }}</td>
                        <td><a href="{{ item.url }}" target="_blank">View</a></td>
                    </tr>
                    {% endfor %}
                </table>
            {% else %}
                <p class="no-content">No content in this group.</p>
            {% endif %}
            </div>
            {% endif %}
        {% endfor %}
        
        <!-- Render "Deprecated Accounts" section last -->
        {% if "Deprecated Accounts" in grouped_data %}
            {% set deprecated_items = grouped_data["Deprecated Accounts"] %}
            <h2 id="header-section-deprecated" onclick="toggleSection('section-deprecated')">Deprecated Accounts</h2>
            <div id="section-deprecated" class="section-content">
            {% if deprecated_items %}
                <table>
                    <tr>
                        <th>Title</th>
                        <th>Parent Folder</th>
                        <th>Created</th>
                        <th>Author</th>
                        <th>Link</th>
                    </tr>
                    {% for item in deprecated_items %}
                    <tr>
                        <td>{{ item.title }}</td>
                        <td>{{ item.parent_folder }}</td>
                        <td>{{ item.created }}</td>
                        <td>{{ item.author }}</td>
                        <td><a href="{{ item.url }}" target="_blank">View</a></td>
                    </tr>
                    {% endfor %}
                </table>
            {% else %}
                <p class="no-content">No content in this group.</p>
            {% endif %}
            </div>
        {% endif %}
    </body>
    </html>
    """
    template = Template(template_str)
    html = template.render(space_key=space_key, grouped_data=grouped_data)

    with open(output_path, "w", encoding="utf-8") as f:
        f.write(html)

# ----------------------
# Main Script Logic
# ----------------------

def main():
    # Accept space key as optional command-line argument
    space_key = sys.argv[1].strip() if len(sys.argv) > 1 else DEFAULT_SPACE_KEY


    content = fetch_all_space_content(space_key)

    # Group by aging category
    grouped = {
        "Within YTD": [],
        "Within 1 year": [],
        "Within 2 years": [],
        "Older than 3 years": [],
        "Older than 5 years": [],
        "Deprecated Accounts": [],
    }

    print("Processing content and grouping by age...")
    total_items = len(content)
    for idx, item in enumerate(content, 1):
        try:
            title = item["title"]
            created_date = item["history"]["createdDate"]
            author = item["history"]["createdBy"]["displayName"]
            page_id = item["id"]
            age_group = classify_age(created_date)
            created_by = item["history"]["createdBy"]
            
            # Extract parent folder information
            parent_folder = "<root>"
            if "ancestors" in item and item["ancestors"]:
                # Get the immediate parent (last ancestor in the list)
                parent = item["ancestors"][-1]
                parent_folder = parent.get("title", "<root>")

            item_data = {
                "title": title,
                "parent_folder": parent_folder,
                "created": created_date.split("T")[0],
                "created_iso": created_date,
                "author": author,
                "url": f"https://experityhealth.atlassian.net/wiki/spaces/{space_key}/pages/{page_id}"
            }

            # Check if the account is deprecated
            if is_deprecated_account(created_by):
                # We'll add these to a separate section later
                item_data["is_deprecated"] = True
                # Temporarily store in a special key
                grouped.setdefault("Deprecated Accounts", []).append(item_data)
            else:
                # Add to regular age group
                grouped[age_group].append(item_data)
        except KeyError:
            continue
        if idx % 10 == 0 or idx == total_items:
            percent = (idx / total_items) * 100
            bar_len = 30
            filled_len = int(bar_len * idx // total_items)
            bar = '=' * filled_len + '-' * (bar_len - filled_len)
            print(f"  [{bar}] {idx}/{total_items} ({percent:.1f}%)", end='\r' if idx != total_items else '\n')

    print("Grouping complete.")

    # Sort grouped items by parent folder and date (most recent first)
    # Process all groups including the new "Deprecated Accounts" section
    for group_name, items in grouped.items():
        parent_map = {}
        for item in items:
            parent_map.setdefault(item["parent_folder"], []).append(item)
        # Sort each parent's items by original ISO created date descending (most recent first)
        for p_items in parent_map.values():
            p_items.sort(key=lambda x: x.get("created_iso", x["created"]), reverse=True)
        # Define parent order: root first, then alphabetical
        ordered_parents = ["<root>"] + sorted(p for p in parent_map if p != "<root>")
        # Rebuild list in the defined order: all items from the same parent together, root first, then alphabetical
        new_list = []
        for parent in ordered_parents:
            new_list.extend(parent_map.get(parent, []))
        grouped[group_name] = new_list

    # Output file
    output_filename = f"confluence_{space_key}_content_analysis.html"
    output_path = os.path.join(OUTPUT_DIR, output_filename)

    print("Rendering HTML report...")
    render_html_report(space_key, grouped, output_path)

    print(f"✅ Report written to: {output_path}")

if __name__ == "__main__":
    main()
