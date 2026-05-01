import re
from collections import defaultdict

# =====================================================
# SLOT MAP
# =====================================================

slots = {
    "s1": ("mon", 8),
    "s2": ("mon", 10),
    "s3": ("mon", 14),
    "s4": ("tue", 8),
    "s5": ("tue", 10),
    "s6": ("tue", 14),
    "s7": ("wed", 8),
    "s8": ("wed", 10),
    "s9": ("wed", 14),
    "s10": ("thu", 8),
    "s11": ("thu", 10),
    "s12": ("thu", 14),
    "s13": ("fri", 8),
    "s14": ("fri", 10),
    "s15": ("fri", 14),
    "s16": ("mon", 16),
    "s17": ("tue", 16),
    "s18": ("wed", 16),
    "s19": ("thu", 16),
    "s20": ("fri", 16),
}

days = ["mon", "tue", "wed", "thu", "fri"]
times = sorted({t for _, t in slots.values()})

# =====================================================
# EXTRACT FILIERE FROM COURSE NAME
# =====================================================

def get_filiere(course):
    return course.split("_")[0]   # cs_algo → cs

# =====================================================
# PARSE INTO STRUCTURE: filiere → grid
# =====================================================

def parse(file):
    data = defaultdict(lambda: defaultdict(list))

    with open(file, "r", encoding="utf-8") as f:
        for line in f:
            m = re.match(r"(\w+)\s*->\s*(\w+)\s*@\s*(\w+)", line.strip())
            if not m:
                continue

            course, room, slot = m.groups()

            if slot in slots:
                day, time = slots[slot]
                filiere = get_filiere(course)

                data[filiere][(day, time)].append(
                    f"{course}<br><small>{room}</small>"
                )

    return data

# =====================================================
# HTML GENERATOR (MULTI TABLE)
# =====================================================

def generate_html(data):

    html = """
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Timetable by Filière</title>

<style>
body {
    font-family: Arial;
    background: #0f172a;
    color: white;
    text-align: center;
}

h2 {
    margin-top: 40px;
    color: #38bdf8;
}

table {
    margin: auto;
    border-collapse: collapse;
    width: 95%;
    margin-bottom: 50px;
}

th, td {
    border: 1px solid #334155;
    padding: 10px;
    min-width: 120px;
    height: 80px;
    vertical-align: top;
}

th {
    background: #1e293b;
}

td {
    background: #0b1220;
}

.cell {
    background: #2563eb;
    padding: 6px;
    border-radius: 8px;
    margin-bottom: 5px;
}
</style>
</head>
<body>

<h1>📅 Timetable by Filière</h1>
"""

    # =================================================
    # ONE TABLE PER FILIERE
    # =================================================

    for filiere, timetable in data.items():

        html += f"<h2>{filiere.upper()}</h2>"
        html += "<table>"
        html += "<tr><th>Day / Time</th>"

        for t in times:
            html += f"<th>{t}:00</th>"

        html += "</tr>"

        for d in days:
            html += f"<tr><th>{d.upper()}</th>"

            for t in times:
                items = timetable.get((d, t), [])

                if items:
                    content = "".join(
                        f"<div class='cell'>{x}</div>" for x in items
                    )
                else:
                    content = ""

                html += f"<td>{content}</td>"

            html += "</tr>"

        html += "</table>"

    html += """
</body>
</html>
"""

    return html

# =====================================================
# MAIN
# =====================================================

INPUT_FILE = "schedule.txt"
OUTPUT_FILE = "timetable_by_filiere.html"

data = parse(INPUT_FILE)
html = generate_html(data)

with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    f.write(html)

print("✅ Generated:", OUTPUT_FILE)