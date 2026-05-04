SET search_path TO football_analysis;

DROP TABLE IF EXISTS football_stats_raw;

CREATE TABLE football_stats_raw (
    team TEXT,
    year INT,
    wins INT,
    losses INT,
    ties INT,
    win_pct NUMERIC,
    rush_yards NUMERIC,
    rush_yards_gained NUMERIC,
    rush_yards_lost NUMERIC,
    rush_attempts NUMERIC,
    avg_rush_yards_attempt NUMERIC,
    avg_rush_yards_game NUMERIC,
    rush_tds NUMERIC,
    pass_attempts NUMERIC,
    avg_pass_yards_attempt NUMERIC,
    avg_pass_yards_game NUMERIC,
    pass_tds NUMERIC,
    total_offensive_plays NUMERIC,
    avg_yards_play NUMERIC,
    avg_yards_game NUMERIC,
    interceptions_thrown NUMERIC,
    third_down_conv NUMERIC,
    fourth_down_conv NUMERIC,
    sacks_taken NUMERIC,
    tds_scored NUMERIC,
    time_of_possession_game_min NUMERIC,
    total_penalties NUMERIC,
    avg_penalty_yards_game NUMERIC,
    opp_rush_yards NUMERIC,
    opp_rush_yards_gained NUMERIC,
    opp_rush_yards_lost NUMERIC,
    opp_rush_attempts NUMERIC,
    opp_avg_rush_yards_attempt NUMERIC,
    opp_avg_rush_yards_game NUMERIC,
    opp_rush_tds NUMERIC,
    opp_pass_attempts NUMERIC,
    opp_avg_pass_yards_attempt NUMERIC,
    opp_avg_pass_yards_game NUMERIC,
    opp_pass_tds NUMERIC,
    total_defensive_plays NUMERIC,
    opp_avg_yards_play NUMERIC,
    opp_avg_yards_game NUMERIC,
    interceptions NUMERIC,
    opp_third_down_conv NUMERIC,
    opp_fourth_down_conv NUMERIC,
    sacks NUMERIC,
    opp_tds_scored NUMERIC,
    opp_time_of_possession_game_min NUMERIC,
    opp_total_penalties NUMERIC,
    opp_avg_penalty_yards_game NUMERIC
);

\copy football_stats_raw FROM 'data/cleaned/football_stats_combined.csv' CSV HEADER

INSERT INTO teams (team_name)
SELECT DISTINCT team
FROM football_stats_raw
ON CONFLICT (team_name) DO NOTHING;

INSERT INTO seasons (team_id, year, wins, losses, ties, win_pct)
SELECT t.team_id, r.year, r.wins, r.losses, r.ties, r.win_pct
FROM football_stats_raw r
JOIN teams t ON r.team = t.team_name
ON CONFLICT (team_id, year) DO NOTHING;

INSERT INTO team_stats (
    season_id,
    rush_yards,
    rush_yards_gained,
    rush_yards_lost,
    rush_attempts,
    avg_rush_yards_attempt,
    avg_rush_yards_game,
    rush_tds,
    pass_attempts,
    avg_pass_yards_attempt,
    avg_pass_yards_game,
    pass_tds,
    total_offensive_plays,
    avg_yards_play,
    avg_yards_game,
    interceptions_thrown,
    third_down_conv,
    fourth_down_conv,
    sacks_taken,
    tds_scored,
    time_of_possession_game_min,
    total_penalties,
    avg_penalty_yards_game
)
SELECT
    s.season_id,
    r.rush_yards,
    r.rush_yards_gained,
    r.rush_yards_lost,
    r.rush_attempts,
    r.avg_rush_yards_attempt,
    r.avg_rush_yards_game,
    r.rush_tds,
    r.pass_attempts,
    r.avg_pass_yards_attempt,
    r.avg_pass_yards_game,
    r.pass_tds,
    r.total_offensive_plays,
    r.avg_yards_play,
    r.avg_yards_game,
    r.interceptions_thrown,
    r.third_down_conv,
    r.fourth_down_conv,
    r.sacks_taken,
    r.tds_scored,
    r.time_of_possession_game_min,
    r.total_penalties,
    r.avg_penalty_yards_game
FROM football_stats_raw r
JOIN teams tm ON r.team = tm.team_name
JOIN seasons s ON s.team_id = tm.team_id AND s.year = r.year
ON CONFLICT (season_id) DO NOTHING;

INSERT INTO opponent_stats (
    season_id,
    opp_rush_yards,
    opp_rush_yards_gained,
    opp_rush_yards_lost,
    opp_rush_attempts,
    opp_avg_rush_yards_attempt,
    opp_avg_rush_yards_game,
    opp_rush_tds,
    opp_pass_attempts,
    opp_avg_pass_yards_attempt,
    opp_avg_pass_yards_game,
    opp_pass_tds,
    total_defensive_plays,
    opp_avg_yards_play,
    opp_avg_yards_game,
    interceptions,
    opp_third_down_conv,
    opp_fourth_down_conv,
    sacks,
    opp_tds_scored,
    opp_time_of_possession_game_min,
    opp_total_penalties,
    opp_avg_penalty_yards_game
)
SELECT
    s.season_id,
    r.opp_rush_yards,
    r.opp_rush_yards_gained,
    r.opp_rush_yards_lost,
    r.opp_rush_attempts,
    r.opp_avg_rush_yards_attempt,
    r.opp_avg_rush_yards_game,
    r.opp_rush_tds,
    r.opp_pass_attempts,
    r.opp_avg_pass_yards_attempt,
    r.opp_avg_pass_yards_game,
    r.opp_pass_tds,
    r.total_defensive_plays,
    r.opp_avg_yards_play,
    r.opp_avg_yards_game,
    r.interceptions,
    r.opp_third_down_conv,
    r.opp_fourth_down_conv,
    r.sacks,
    r.opp_tds_scored,
    r.opp_time_of_possession_game_min,
    r.opp_total_penalties,
    r.opp_avg_penalty_yards_game
FROM football_stats_raw r
JOIN teams tm ON r.team = tm.team_name
JOIN seasons s ON s.team_id = tm.team_id AND s.year = r.year
ON CONFLICT (season_id) DO NOTHING;

SELECT 'teams' AS table_name, COUNT(*) FROM teams
UNION ALL
SELECT 'seasons', COUNT(*) FROM seasons
UNION ALL
SELECT 'team_stats', COUNT(*) FROM team_stats
UNION ALL
SELECT 'opponent_stats', COUNT(*) FROM opponent_stats;