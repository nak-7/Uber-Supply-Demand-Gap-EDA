# 🚗 Uber Supply Demand Gap — DA/BA Case Study

![Python](https://img.shields.io/badge/Python-3.8+-blue)
![SQL](https://img.shields.io/badge/SQL-SQLite-orange)
![Excel](https://img.shields.io/badge/Excel-Dashboard-green)
![EDA](https://img.shields.io/badge/Type-EDA-purple)

---

## 📌 Project Overview

This project is a Data Analytics / Business Analytics case study on Uber ride request data. The goal is to identify and analyze the **Supply-Demand Gap** — situations where customer ride requests go unfulfilled either because no cars are available or because drivers cancel — and to provide actionable recommendations to improve Uber's trip completion rate.

**Project Type:** EDA / Business Analytics
**Contribution:** Individual
**Author:** Nakshatra Devkar

---

## 🎯 Business Objective

> *"Why are more than half of all Uber ride requests going unfulfilled, and what can be done about it?"*

1. Identify time periods and pickup locations where the supply-demand gap is highest
2. Determine root causes — driver cancellations vs no cars available
3. Analyze patterns by hour of day and time slot to find peak problem windows
4. Provide actionable recommendations to reduce unfulfilled requests and increase revenue

---

## 📂 Project Structure

```
Uber-Supply-Demand-Gap/
│
├── Nakshatra_Uber_Supply_Demand_Gap_EDA.ipynb  # Python EDA notebook (20 charts)
├── Nakshatra_Uber_Python_Analysis.pdf           # PDF of executed notebook
├── Nakshatra_Uber_SQL_Analysis.sql              # SQL queries (25+ queries)
├── Nakshatra_Uber_SQL_Analysis.pdf              # SQL report PDF
├── Nakshatra_Uber_Excel_Dashboard.xlsx          # Excel dashboard (5 sheets)
├── Nakshatra_Uber_Insights_Report.pdf           # Combined insights PDF (all 3 tools)
├── uber_supply_demand.db                        # SQLite database
│
└── data/
    └── Uber_Request_Data.csv
```

---

## 📊 Dataset

| Property | Value |
|---|---|
| Source | Uber Ride Request Data |
| Records | 6,745 ride requests |
| Pickup Points | Airport / City |
| Status Types | Trip Completed / Cancelled / No Cars Available |
| Period | Monday – Friday (5 weekdays) |

### Variables

| Column | Description |
|---|---|
| Request id | Unique identifier for each ride request |
| Pickup point | Airport or City |
| Driver id | Assigned driver ID (NaN if no driver) |
| Status | Trip Completed / Cancelled / No Cars Available |
| Request timestamp | Date and time of request |
| Drop timestamp | Date and time of drop-off (NaN if not completed) |

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| **Python 3.8+** | Core programming |
| **Pandas & NumPy** | Data manipulation |
| **Matplotlib & Seaborn** | Static visualizations |
| **Plotly** | Interactive treemap |
| **SQLite** | Database and SQL queries |
| **Excel (openpyxl)** | Dashboard creation |

---

## 🔄 Project Architecture

```
Raw CSV Data
     ↓
Data Cleaning (Excel + Python)
     ↓
Feature Engineering
  (Hour, TimeSlot, IsGap, Weekday)
     ↓
EDA & Visualization (20 Charts)
     ↓
SQL Analysis (25+ queries)
     ↓
Excel Dashboard (6 charts, 5 sheets)
     ↓
Combined Insights Report (PDF)
     ↓
Business Recommendations
```

---

## 📈 Key Findings

### Overall Statistics
| Metric | Value |
|---|---|
| Total Requests | 6,745 |
| Trip Completed | 2,831 (41.97%) |
| No Cars Available | 2,650 (39.29%) |
| Cancelled | 1,264 (18.74%) |
| Overall Gap Rate | **58.03%** |

### The Core Problem
- More than **half of all Uber requests go unfulfilled**
- No Cars Available nearly equals Trip Completed — Uber is losing almost as much revenue as it earns

### Root Causes by Location
| Location | Primary Problem | Count |
|---|---|---|
| **Airport** | No Cars Available | 1,713 |
| **City** | Cancellations | 1,066 |

These are **opposite problems requiring different solutions.**

### Worst Time Slots
| Time Slot | Unfulfilled | Gap Rate |
|---|---|---|
| Night (9PM–11PM) | 509 | ~63% |
| Early Morning (5AM–8AM) | 991 | ~59% |
| Evening (5PM–8PM) | 1,251 | ~66% |

### Worst Single Combination
**Airport + Evening + No Cars Available = 1,067 instances** — the single biggest failure point in the entire dataset

---

## 💡 Business Recommendations

| Priority | Recommendation | Addresses |
|---|---|---|
| P1 | **Airport Night Shift Program** — guaranteed hourly pay 5PM–midnight | Airport No Cars Evening/Night |
| P1 | **Early Morning Cancellation Policy** — penalty + completion bonus 5-9AM | City Early Morning Cancellations |
| P2 | **Location-Specific Surge Pricing** — Airport evening + City morning | Both pickup points |
| P2 | **Minimum Car Guarantee at Airport** — 50-100 reserved drivers | Airport structural supply gap |
| P3 | **Driver Earnings Transparency** — show fare estimate before cancel | All cancellations |
| P3 | **Real-time Demand Alerts** — 30-min advance notifications with bonuses | Off-peak supply shortage |

**Expected Impact:** Implementing P1 recommendations could improve overall completion rate from **41.97% to 60-65%** — a 45-55% increase in fulfilled rides.

---

## 📋 Engineered Features

| Feature | Source | Description |
|---|---|---|
| Hour | Request timestamp | Hour of day (0-23) |
| TimeSlot | Hour | Late Night / Early Morning / Morning / Afternoon / Evening / Night |
| IsGap | Status | 1 = unfulfilled request, 0 = completed |
| Weekday | Request timestamp | Day name (Monday–Friday) |

---

## 📊 Charts in the Notebook

| Chart | Type | Key Insight |
|---|---|---|
| 1 | Count Plot | Trip status distribution |
| 2 | Bar Chart | Pickup point distribution |
| 3 | Bar Chart | Requests by hour of day |
| 4 | Pie Chart | TimeSlot distribution |
| 5 | Dual-axis | Gap by TimeSlot |
| 6 | Grouped Bar | Status by pickup point |
| 7 | Grouped Bar | Cancellations vs No Cars by TimeSlot |
| 8 | Heatmap | Requests: Pickup Point × TimeSlot |
| 9 | Heatmap | Status × TimeSlot |
| 10 | Stacked Bar | Status composition by TimeSlot (%) |
| 11 | Dual-line | Hourly requests: Airport vs City |
| 12 | Line Chart | Cancellation rate by hour |
| 13 | Area Chart | No Cars Available rate by hour |
| 14 | Treemap | Status × Pickup × TimeSlot (Plotly) |
| 15 | Dual-line | Gap rate: Airport vs City by hour |
| 16 | Horizontal Bar | Top 15 most active drivers |
| 17 | Grouped Bar | Completion rate: Pickup × TimeSlot |
| 18 | Dual-axis | Weekday request volume and gap rate |
| 19 | Histogram | Trip duration: Airport vs City |
| 20 | Faceted Bar | Full gap breakdown: Location × Time × Status |

---

## 📋 SQL Analysis Sections

1. Data Integrity Check
2. Time Slot Analysis (with reusable View)
3. Pickup Point Analysis
4. Combined Location × Time Analysis
5. Hourly Analysis
6. Driver Analysis
7. Summary Insights

---

## 📊 Excel Dashboard Sheets

| Sheet | Contents |
|---|---|
| Raw Data | Original CSV data with formatting |
| Cleaned Data | Cleaned data + cleaning log table |
| Pivot Tables | 7 pivot tables for all analyses |
| Dashboard | 6 charts with KPI cards |
| Insights Summary | Key findings + recommendations table |

---

## 🚀 How to Run

### Python Notebook
```bash
pip install pandas numpy matplotlib seaborn plotly missingno imbalanced-learn
jupyter notebook Nakshatra_Uber_Supply_Demand_Gap_EDA.ipynb
```

### SQL Queries
```bash
# Open DB Browser for SQLite
# File → Open Database → uber_supply_demand.db
# Run queries from Nakshatra_Uber_SQL_Analysis.sql
# Note: Run the CREATE VIEW query first (Section 2.1)
```

### Excel Dashboard
```bash
# Open Nakshatra_Uber_Excel_Dashboard.xlsx in Microsoft Excel
# Navigate to the Dashboard sheet
# Use slicers to filter by Pickup Point, TimeSlot, Status
```

---

## 📁 Submission Files

| File | Description |
|---|---|
| `.ipynb` | Python EDA notebook |
| `_Python_Analysis.pdf` | PDF of executed notebook |
| `_SQL_Analysis.sql` | SQL file |
| `_SQL_Analysis.pdf` | SQL report PDF |
| `_Excel_Dashboard.xlsx` | Excel dashboard |
| `_Insights_Report.pdf` | Combined insights PDF (all 3 tools) |
| `.db` | SQLite database |

---

*Project completed as part of Data Analytics Internship — Nakshatra Devkar*
