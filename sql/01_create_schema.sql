DROP SCHEMA IF EXISTS football_analysis CASCADE;
CREATE SCHEMA football_analysis;
SET search_path TO football_analysis;

CREATE TABLE teams (
    team_id SERIAL PRIMARY KEY,
    team_name TEXT NOT NULL UNIQUE
);

CREATE TABLE seasons (
    season_id SERIAL PRIMARY KEY,
    team_id INT NOT NULL REFERENCES teams(team_id),
    year INT NOT NULL,
    wins INT NOT NULL,
    losses INT NOT NULL,
    ties INT NOT NULL DEFAULT 0,
    win_pct NUMERIC(6,4) NOT NULL,
    UNIQUE(team_id, year),
    CHECK (year BETWEEN 2015 AND 2025),
    CHECK (wins >= 0),
    CHECK (losses >= 0),
    CHECK (ties >= 0),
    CHECK (win_pct BETWEEN 0 AND 1)
);

CREATE TABLE team_stats (
    stat_id SERIAL PRIMARY KEY,
    season_id INT NOT NULL UNIQUE REFERENCES seasons(season_id),
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
    CHECK (third_down_conv IS NULL OR third_down_conv BETWEEN 0 AND 1),
    CHECK (fourth_down_conv IS NULL OR fourth_down_conv BETWEEN 0 AND 1)
);

CREATE TABLE opponent_stats (
    opp_stat_id SERIAL PRIMARY KEY,
    season_id INT NOT NULL UNIQUE REFERENCES seasons(season_id),
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
    opp_avg_penalty_yards_game NUMERIC,
    CHECK (opp_third_down_conv IS NULL OR opp_third_down_conv BETWEEN 0 AND 1),
    CHECK (opp_fourth_down_conv IS NULL OR opp_fourth_down_conv BETWEEN 0 AND 1)
);