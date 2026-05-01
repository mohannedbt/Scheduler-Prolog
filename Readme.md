# University Timetable Scheduling System (Prolog + Python)

This project generates a **conflict-free university timetable** using **constraint solving in Prolog**, then optionally turns the result into **HTML timetables** using a small Python script.

The codebase is intentionally **consult-only Prolog** (no Prolog modules) to keep it simple to load and run in SWI-Prolog.

## Requirements

- SWI-Prolog (tested with `swipl` on Windows)
- Python 3 (only needed for HTML generation)

## Quick start (recommended)

From the project root:

```bash
swipl -q -s io/main.pl
```

You should see a “PROJECT LOADED SUCCESSFULLY” message.

Then in the Prolog prompt:

```prolog
?- solve(S).
```

`S` is a schedule list of terms like:

```prolog
assign(Course, Room, Slot)
```

## What you can run

### 1) Generate a valid schedule

```prolog
?- solve(S).
```

### 2) Export a schedule to text / simple HTML

Text format (`course -> room @ slot`):

```prolog
?- export_txt('io/schedule.txt').
```

Simple HTML table (course/room/slot):

```prolog
?- export_html('io/timetable.html').
```

### 3) Pick the “best” schedule (scored)

The optimizer generates multiple valid schedules and selects the best one using a weighted score (energy + gaps + fairness + etc.):

```prolog
?- best_schedule(Best).
```

To see the score breakdown for a schedule:

```prolog
?- solve(S), explain_score(S).
```

### 4) Get a small “Pareto-like” view

```prolog
?- pareto_top3(P).
```

Returns three schedules: best by energy, best by fairness, and best balanced.

## Generate the “by filière” HTML timetable (Python)

1) First export a schedule to `io/schedule.txt` (see above).

2) Run the Python script from the `io/` folder (important, because the script reads/writes relative filenames):

```bash
cd io
python txt_to_timetable.py
```

This generates:

- `io/timetable_by_filiere.html`

Open that HTML file in a browser.

## Project structure (what each file does)

### Core (data + CSP search)

- `core/domain.pl`: all facts (filieres, groups, teachers, courses, rooms, slots)
- `core/helpers.pl`: helper predicates (group sizes, filière groups, disjoint checks)
- `core/search.pl`: MRV and random variable selection utilities
- `core/solver.pl`: backtracking solver and consistency checks

### Rules (hard constraints + metrics)

- `rules/room_constraints.pl`: equipment + capacity + maintenance constraints
- `rules/energy.pl`: building/day energy constraints + energy total for scoring
- `rules/fairness.pl`: teacher workload fairness metric for scoring

### Engine (optimization/scoring)

- `engine/evaluation_engine.pl`: computes scores (energy, gaps, fairness, compactness, travel, peak)
- `engine/optimizer.pl`: generates multiple solutions and selects the best by score

### IO (loading + exporting + generated artifacts)

- `io/main.pl`: single entrypoint; consults the entire project in the right order
- `io/exports.pl`: `export_txt/1` and `export_html/1`
- `io/schedule.txt`: example/generated solver output
- `io/timetable.html`: generated simple HTML table
- `io/timetable_by_filiere.html`: generated per-filière timetable
- `io/txt_to_timetable.py`: converts `schedule.txt` → `timetable_by_filiere.html`

## Customization

- To change the dataset (courses/rooms/slots), edit `core/domain.pl`.
- To add constraints:
  - hard room constraints → `rules/room_constraints.pl`
  - energy constraints / limits → `rules/energy.pl`
- To change what “best” means, edit the weights in `engine/evaluation_engine.pl`.

## Troubleshooting

- If you see “predicate not found” errors, always load via `swipl -s io/main.pl` (it consults files in the correct order).
- If Python can’t find `schedule.txt`, run the script from inside `io/` as shown above.