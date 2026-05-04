SET search_path TO football_analysis;

-- Cleaning documentation:
-- 1. Conversion ratios like 60-201 were converted into decimals like 0.2985.
-- 2. Time of possession values like 30:01 were converted into decimal minutes like 30.0167.
-- 3. Column names and team labels were standardized across the four source Excel files.
-- 4. Wins, losses, ties, and win_pct were merged from team_records.csv.

SELECT 'raw rows' AS check_name, COUNT(*) AS result FROM football_stats_raw
UNION ALL
SELECT 'teams', COUNT(*) FROM teams
UNION ALL
SELECT 'seasons', COUNT(*) FROM seasons
UNION ALL
SELECT 'team_stats', COUNT(*) FROM team_stats
UNION ALL
SELECT 'opponent_stats', COUNT(*) FROM opponent_stats;

SELECT *
FROM seasons
WHERE win_pct < 0 OR win_pct > 1;

SELECT s.year, tm.team_name, ts.third_down_conv, ts.fourth_down_conv
FROM seasons s
JOIN teams tm ON s.team_id = tm.team_id
JOIN team_stats ts ON s.season_id = ts.season_id
WHERE ts.third_down_conv < 0
   OR ts.third_down_conv > 1
   OR ts.fourth_down_conv < 0
   OR ts.fourth_down_conv > 1;

SELECT s.year, tm.team_name, os.opp_third_down_conv, os.opp_fourth_down_conv
FROM seasons s
JOIN teams tm ON s.team_id = tm.team_id
JOIN opponent_stats os ON s.season_id = os.season_id
WHERE os.opp_third_down_conv < 0
   OR os.opp_third_down_conv > 1
   OR os.opp_fourth_down_conv < 0
   OR os.opp_fourth_down_conv > 1;

SELECT s.year, tm.team_name, ts.time_of_possession_game_min
FROM seasons s
JOIN teams tm ON s.team_id = tm.team_id
JOIN team_stats ts ON s.season_id = ts.season_id
WHERE ts.time_of_possession_game_min IS NOT NULL
  AND (
      ts.time_of_possession_game_min < 20
      OR ts.time_of_possession_game_min > 40
  );

SELECT s.year, tm.team_name
FROM seasons s
JOIN teams tm ON s.team_id = tm.team_id
JOIN team_stats ts ON s.season_id = ts.season_id
JOIN opponent_stats os ON s.season_id = os.season_id
WHERE ts.avg_yards_play IS NULL
   OR ts.avg_yards_game IS NULL
   OR os.opp_avg_yards_play IS NULL
   OR os.opp_avg_yards_game IS NULL;