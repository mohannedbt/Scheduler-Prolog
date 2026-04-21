# 📅 University Timetable Scheduling System

## 📌 Project Overview

This project implements a **constraint-based university timetable generator** using **Prolog**, combined with a **Python post-processing layer** to visualize results as structured HTML timetables.

The system models:
- multiple filières (study programs)
- groups of students
- teachers with workload constraints
- rooms with capacity and equipment requirements
- time slots across a weekly schedule

The goal is to automatically generate a **valid, conflict-free timetable** and present it in a **readable web format per filière**.

---

## ⚙️ System Architecture

The project is divided into three main layers:

### 1. 📚 Knowledge Base (Prolog DB)
Defines the academic structure:
- Filieres (CS, AI, ING, DS, SE, MATH)
- Student groups per filière
- Teachers with workload limits
- Courses with type, priority, and constraints
- Rooms with capacity and equipment
- Time slots across multiple days

---

### 2. 🧠 Constraint Solver (Prolog)
Implements:
- **Domain generation per course**
- **Hard constraint checking**
  - room capacity
  - equipment compatibility
  - teacher conflicts
  - group overlaps
- **MRV (Minimum Remaining Values) heuristic**
- **Backtracking search**
- **Progress tracking (node counter)**

Output format:
course -> room @ slot

This ensures a **valid global schedule assignment** for all courses.

---

### 3. 🎨 Visualization Layer (Python + HTML)
A Python script:
- parses Prolog output
- maps slot IDs → (day, time)
- groups courses by filière
- generates a **multi-table HTML dashboard**

Each filière gets its own timetable view with:
- weekly grid layout
- styled cells
- course + room display

---

## 🚀 Key Achievements

### ✅ Constraint Modeling
- Successfully modeled a real academic scheduling system
- Integrated multiple constraint types:
  - resource constraints (rooms, equipment)
  - human constraints (teachers)
  - group conflicts

---

### ✅ Search Optimization
- Implemented MRV-based selection strategy
- Reduced search space significantly
- Added forward-checking style pruning
- Added runtime progress monitoring

---

### ✅ Scalability Improvements
- Expanded dataset to include:
  - multiple filières
  - large number of groups
  - extended room and slot availability
  - increased course diversity

---

### ✅ Visualization System
- Built automated HTML generator
- Implemented:
  - structured weekly grids
  - multi-filière separation
  - dynamic slot mapping
- Converted raw solver output into a readable interface

---

## 🧩 Current Limitations

Despite working functionality, some improvements are still needed:

### ⚠️ Solver Completeness
- In some configurations, not all courses are guaranteed to appear
- Search may terminate early depending on constraint tightness
- No explicit “full coverage guarantee” enforcement

---

### ⚠️ Optimization Quality
- No global optimal scheduling (only first valid solution)
- No cost function balancing (e.g., workload fairness, spacing quality)

---

### ⚠️ Scalability Boundaries
- Backtracking becomes expensive with very large datasets
- No caching or memoization of partial states

---

### ⚠️ Visualization Enhancements
- HTML output is static
- No interactive filtering or drag-and-drop editing
- No real-time conflict highlighting

---

## 🔮 Future Improvements

### 🧠 Solver Enhancements
- Add constraint propagation (AC-3 style filtering)
- Introduce backjumping or conflict-directed backtracking
- Guarantee full course coverage via validation loop
- Add the energy constraints and exapand the DB

---

### 📊 Optimization Layer
- Add scoring function for schedule quality:
  - teacher workload balance
  - room utilization efficiency
  - gap minimization for students
- Implement best-solution search instead of first-solution

---

### 🌐 Web Interface Upgrade
- Convert HTML output into interactive dashboard
- Add:
  - filière filters
  - course search
  - hover-based details
- Optional React-based UI

---

### 🔄 System Integration
- Direct Prolog → JSON export (remove intermediate parsing step)
- Live schedule regeneration pipeline
- API wrapper for scheduling requests

---

## 📌 Conclusion

This project demonstrates a full pipeline combining:
- symbolic AI (Prolog constraint solving)
- algorithmic optimization (search heuristics)
- data transformation (Python parsing)
- UI generation (HTML visualization)

It forms a solid foundation for a **real-world academic scheduling system**, with clear paths toward scalability, optimization, and interactive deployment.