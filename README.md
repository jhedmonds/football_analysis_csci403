RMAC FOOTBALL STATS FINAL PROJECT PLAN

PROJECT GOAL
Which football statistics are most strongly correlated with winning, and how did RMAC football change from 2015–2025?

PROJECT TYPE
Component 2: Data Science and Analysis

COMPONENT 3 OUTPUTS
1. Data loading and cleaning
2. Database schema design
3. Interesting / complex SQL queries
4. Statistical / data analysis
5. Data visualization


============================================================
WORK SPLIT CHECKLIST
============================================================

Baylor — Data Pipeline + Database
[ ] Finish/verify the 4 raw Excel files in data/raw/
[ ] Move scraper code into football_stats_scraper/
[ ] Create python/combine_data.py
[ ] Generate data/cleaned/football_stats_combined.csv
[ ] Add/verify wins, losses, win_pct
[ ] Create SQL schema in sql/01_create_schema.sql
[ ] Create SQL loading script in sql/02_load_data.sql
[ ] Create SQL cleaning/validation script in sql/03_clean_data.sql
[ ] Create the 2 main complex SQL queries in sql/04_complex_queries.sql
[ ] Export query outputs into data/outputs/

Teammate — Analysis + Presentation
[ ] Create python/analyze_data.py
[ ] Generate charts into figures/
[ ] Create schema diagram in figures/
[ ] Help write README.md
[ ] Help write Artifact Self-Assessment answers
[ ] Build lightning talk slides
[ ] Verify charts match the SQL results

Both
[ ] Decide final project conclusions
[ ] Review missing/null data
[ ] Practice 5-minute lightning talk
[ ] Confirm all required artifacts are included
[ ] Zip final submission folder


============================================================
EXPECTED DIRECTORY STRUCTURE
============================================================

football_analysis_csci403/
│
├── data/
│   ├── raw/
│   │   ├── csup_football_stats.xlsx
│   │   ├── mesa_football_stats.xlsx
│   │   ├── mines_football_stats.xlsx
│   │   └── western_football_stats.xlsx
│   │
│   ├── cleaned/
│   │   └── football_stats_combined.csv
│   │
│   └── outputs/
│       ├── stat_win_correlation.csv
│       └── game_trends_2015_2025.csv
│
├── figures/
│   ├── schema_diagram.png
│   ├── top_stats_correlated_with_winning.png
│   ├── rush_vs_pass_yards_over_time.png
│   └── rush_pass_share_over_time.png
│
├── football_stats_scraper/
│   ├── scraper.py
│   ├── requirements.txt
│   └── tests/
│       ├── conftest.py
│       └── test_scraper.py
│
├── python/
│   ├── combine_data.py
│   └── analyze_data.py
│
├── sql/
│   ├── 01_create_schema.sql
│   ├── 02_load_data.sql
│   ├── 03_clean_data.sql
│   └── 04_complex_queries.sql
│
├── src/
├── README.md
└── csci403_finalproject_updated.pdf


============================================================
STEP 1 — VERIFY SCRAPER
============================================================

Go into the scraper folder:

cd football_stats_scraper
source venv/Scripts/activate
pytest -v

Expected:
17 passed

Then return to the main repo:

cd ..


============================================================
STEP 2 — VERIFY RAW EXCEL FILES
============================================================

Raw Excel files should be in:

data/raw/

Expected files:

csup_football_stats.xlsx
mesa_football_stats.xlsx
mines_football_stats.xlsx
western_football_stats.xlsx

Check that each file includes:

Year
Wins
Losses
Win Pct
Rush Yards
Rush Yards Gained
Rush Yards Lost
Rush Attempts
Avg Rush Yards/Attempt
Avg Rush Yards/Game
Rush TDs
Pass Attempts
Avg Pass Yards/Attempt
Avg Pass Yards/Game
Pass TDs
Total Offensive Plays
Avg Yards/Play
Avg Yards/Game
3rd Down Conv.
4th Down Conv.
Sacks Taken
TDs Scored
Time of Possession/Game (min)
Total Penalties
Avg Penalty Yards/Game
Opponent stats columns

If Wins, Losses, or Win Pct are missing, add them manually.


============================================================
STEP 3 — CREATE python/combine_data.py
============================================================

Create:

python/combine_data.py

Purpose:
Combine all 4 Excel files into one cleaned CSV.

Expected output:

data/cleaned/football_stats_combined.csv

Run:

pip install pandas openpyxl
python python/combine_data.py


============================================================
STEP 4 — CHECK CLEANED CSV
============================================================

Open:

data/cleaned/football_stats_combined.csv

Confirm these columns exist:

team
year
wins
losses
win_pct
rush_yards
avg_rush_yards_game
avg_yards_play
third_down_conv
fourth_down_conv
opp_avg_yards_play

If any column names are wrong, fix the Excel headers and rerun:

python python/combine_data.py


============================================================
STEP 5 — CREATE DATABASE SCHEMA
============================================================

Create:

sql/01_create_schema.sql

Schema should include:

teams
- team_id primary key
- team_code
- team_name

seasons
- season_id primary key
- team_id foreign key
- year
- wins
- losses
- win_pct

team_stats
- stat_id primary key
- season_id foreign key
- offensive/team stats

opponent_stats
- opp_stat_id primary key
- season_id foreign key
- opponent/defensive stats

Run:

psql -f sql/01_create_schema.sql


============================================================
STEP 6 — CREATE DATA LOADING SCRIPT
============================================================

Create:

sql/02_load_data.sql

This should:

1. Create football_stats_raw staging table
2. Load data/cleaned/football_stats_combined.csv
3. Insert distinct teams into teams
4. Insert years and win/loss data into seasons
5. Insert offensive stats into team_stats
6. Insert opponent stats into opponent_stats

Run:

psql -f sql/02_load_data.sql


============================================================
STEP 7 — VERIFY DATABASE LOAD
============================================================

In psql:

SET search_path TO football_project;

SELECT COUNT(*) FROM football_stats_raw;
SELECT COUNT(*) FROM teams;
SELECT COUNT(*) FROM seasons;
SELECT COUNT(*) FROM team_stats;
SELECT COUNT(*) FROM opponent_stats;

Expected:

teams = 4
seasons = same number as team-year rows
team_stats = same number as seasons
opponent_stats = same number as seasons


============================================================
STEP 8 — CREATE CLEANING / VALIDATION SQL
============================================================

Create:

sql/03_clean_data.sql

This file should document and validate cleaning work:

Cleaning operation 1:
Conversion ratios like 60-201 were converted into decimal percentages like 0.2985.

Cleaning operation 2:
Time of possession values like 30:01 were converted into decimal minutes like 30.02.

Cleaning operation 3:
Team labels and column names were standardized across four source files.

Validation queries:

- Check third/fourth down conversions are decimals between 0 and 1.
- Check time of possession totals are near 60 minutes.
- Check major stat fields are not unexpectedly null.

Run:

psql -f sql/03_clean_data.sql


============================================================
STEP 9 — CREATE COMPLEX SQL QUERIES
============================================================

Create:

sql/04_complex_queries.sql

QUERY 1:
Which stats are most strongly correlated with winning?

Purpose:
Aggregate all team-season stats and rank which metrics have the strongest correlation with win percentage.

Required SQL features:
- CTEs
- UNION ALL unpivoting
- aggregation
- CORR()
- RANK() window function

QUERY 2:
How did RMAC football change from 2015–2025?

Purpose:
Analyze year-by-year changes in rushing, passing, efficiency, scoring, penalties, and defensive stats.

Required SQL features:
- CTEs
- GROUP BY aggregation
- derived rush/pass share metrics
- LAG() window functions
- year-over-year change calculations


============================================================
STEP 10 — EXPORT QUERY RESULTS
============================================================

Export Query 1 to:

data/outputs/stat_win_correlation.csv

Export Query 2 to:

data/outputs/game_trends_2015_2025.csv

These files will be used by the Python chart script.


============================================================
STEP 11 — CREATE CHART SCRIPT
============================================================

Create:

python/analyze_data.py

This script should read:

data/outputs/stat_win_correlation.csv
data/outputs/game_trends_2015_2025.csv

And generate:

figures/top_stats_correlated_with_winning.png
figures/rush_vs_pass_yards_over_time.png
figures/rush_pass_share_over_time.png

Run:

pip install matplotlib pandas
python python/analyze_data.py


============================================================
STEP 12 — CREATE SCHEMA DIAGRAM
============================================================

Create:

figures/schema_diagram.png

Diagram should show:

teams → seasons → team_stats
                → opponent_stats

Include:
- primary keys
- foreign keys
- relationships

Use draw.io, Lucidchart, Google Slides, or another diagram tool.


============================================================
STEP 13 — UPDATE README.md
============================================================

README should include:

# RMAC Football Statistics Database Project

## Project Question
Which football statistics are most strongly correlated with winning, and how did RMAC football change from 2015–2025?

## Dataset
The dataset contains team-season football statistics for CSU Pueblo, Colorado Mesa, Colorado School of Mines, and Western Colorado.

## Pipeline
1. Scrape PDFs and athletics webpages.
2. Store team files in data/raw.
3. Combine files into data/cleaned/football_stats_combined.csv.
4. Load data into PostgreSQL.
5. Normalize into teams, seasons, team_stats, and opponent_stats.
6. Run SQL analysis queries.
7. Export query results and create charts.

## Main SQL Analyses
1. Correlation of team statistics with win percentage.
2. Year-over-year changes in rushing, passing, efficiency, and defensive statistics.

## Outputs
- Cleaned CSV
- PostgreSQL schema
- SQL cleaning validation
- Complex SQL queries
- Query result CSVs
- Visualizations


============================================================
STEP 14 — ARTIFACT SELF-ASSESSMENT LANGUAGE
============================================================

Dataset:
Our dataset is composed of public RMAC football team statistics from four teams across multiple seasons. We decomposed the data into four related tables: teams, seasons, team_stats, and opponent_stats.

Application:
We selected Data Science and Analysis. We used PostgreSQL to load, normalize, clean, aggregate, and analyze football statistics. Our two main questions were which stats are most strongly correlated with winning and how the game changed from 2015–2025.

Data Loading and Cleaning:
We performed non-trivial cleaning by scraping semi-structured PDF and HTML sources, parsing conversion ratios into decimal percentages, converting time of possession into decimal minutes, and standardizing columns/team labels across four source files.

Schema Design:
Our schema separates team identity, season outcome data, team performance statistics, and opponent performance statistics. This reduces repeated team data and maintains relationships using primary and foreign keys.

Complex Queries:
Query 1 uses CTEs, UNION ALL unpivoting, aggregation, CORR(), and RANK() to identify which statistics are most correlated with winning. Query 2 uses CTEs, GROUP BY aggregation, derived rush/pass share metrics, and LAG() window functions to analyze how football changed from 2015–2025.

Visualization:
Our visualizations show the top statistics associated with winning and how rushing versus passing production changed over time.


============================================================
STEP 15 — LIGHTNING TALK SLIDES
============================================================

Create 6 slides:

Slide 1:
Main question
Which football statistics are most strongly correlated with winning, and how did RMAC football change from 2015–2025?

Slide 2:
Dataset and scraping pipeline
Show raw Excel/PDF/website sources and cleaned CSV.

Slide 3:
Database schema
Show teams → seasons → team_stats / opponent_stats.

Slide 4:
Query 1 results
Show top statistics correlated with winning.

Slide 5:
Query 2 results
Show rush/pass trends over time.

Slide 6:
Conclusions and limitations
Example conclusions:
- Efficiency metrics appear more useful than raw volume.
- Defensive/opponent stats may explain winning better than offensive totals alone.
- Rush/pass balance changed over time based on year-level averages.
- Dataset is limited to four teams and archived sources.


============================================================
FINAL SUBMISSION CHECKLIST
============================================================

[ ] data/raw contains all 4 Excel files
[ ] data/cleaned/football_stats_combined.csv exists
[ ] data/outputs/stat_win_correlation.csv exists
[ ] data/outputs/game_trends_2015_2025.csv exists
[ ] figures/schema_diagram.png exists
[ ] figures/top_stats_correlated_with_winning.png exists
[ ] figures/rush_vs_pass_yards_over_time.png exists
[ ] figures/rush_pass_share_over_time.png exists
[ ] football_stats_scraper/scraper.py included
[ ] python/combine_data.py included
[ ] python/analyze_data.py included
[ ] sql/01_create_schema.sql included
[ ] sql/02_load_data.sql included
[ ] sql/03_clean_data.sql included
[ ] sql/04_complex_queries.sql included
[ ] README.md updated
[ ] Artifact Self-Assessment completed
[ ] Lightning talk slides completed
[ ] Final zip created