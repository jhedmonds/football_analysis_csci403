# RMAC Football Statistics Database Project

## Project Question

Which football statistics are most strongly correlated with winning, and how did RMAC football change from 2015–2025?

## Project Type

Component 2: Data Science and Analysis

This project uses PostgreSQL and Python to clean, organize, analyze, and visualize RMAC football statistics. The main goal is to identify which team statistics are most related to winning and to understand how offensive style changed over time.

## Dataset

This project uses team-season football statistics for four RMAC football programs:

- CSU Pueblo
- Colorado Mesa
- Colorado School of Mines
- Western Colorado

The dataset covers the 2015–2025 seasons, excluding 2020 because the COVID season was not played normally across the conference.

The original data is stored in four Excel files, one for each team. A separate `team_records.csv` file was added to include wins, losses, ties, and win percentage for each team-season.

## Dataset Sources

The football statistics were collected from public team and athletics statistics pages/PDFs for the four selected RMAC teams.

Raw source files used in this project:

```text
data/raw/csup_football_stats.xlsx
data/raw/mesa_football_stats.xlsx
data/raw/mines_football_stats.xlsx
data/raw/western_football_stats.xlsx
data/raw/team_records.csv