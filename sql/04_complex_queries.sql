SET search_path TO football_analysis;

DROP VIEW IF EXISTS stat_win_correlation;
DROP VIEW IF EXISTS game_trends_2015_2025;

CREATE VIEW stat_win_correlation AS
WITH joined_stats AS (
    SELECT
        s.win_pct,
        ts.rush_yards,
        ts.avg_rush_yards_game,
        ts.rush_tds,
        ts.pass_attempts,
        ts.avg_pass_yards_game,
        ts.pass_tds,
        ts.avg_yards_play,
        ts.avg_yards_game,
        ts.third_down_conv,
        ts.fourth_down_conv,
        ts.sacks_taken,
        ts.interceptions_thrown,
        ts.tds_scored,
        ts.avg_penalty_yards_game,
        os.opp_rush_yards,
        os.opp_avg_rush_yards_game,
        os.opp_avg_pass_yards_game,
        os.opp_avg_yards_play,
        os.opp_avg_yards_game,
        os.opp_third_down_conv,
        os.opp_fourth_down_conv,
        os.sacks,
        os.interceptions,
        os.opp_tds_scored
    FROM seasons s
    JOIN team_stats ts ON s.season_id = ts.season_id
    JOIN opponent_stats os ON s.season_id = os.season_id
),
unpivoted AS (
    SELECT 'rush_yards' AS stat_name, win_pct, rush_yards AS stat_value FROM joined_stats
    UNION ALL SELECT 'avg_rush_yards_game', win_pct, avg_rush_yards_game FROM joined_stats
    UNION ALL SELECT 'rush_tds', win_pct, rush_tds FROM joined_stats
    UNION ALL SELECT 'pass_attempts', win_pct, pass_attempts FROM joined_stats
    UNION ALL SELECT 'avg_pass_yards_game', win_pct, avg_pass_yards_game FROM joined_stats
    UNION ALL SELECT 'pass_tds', win_pct, pass_tds FROM joined_stats
    UNION ALL SELECT 'avg_yards_play', win_pct, avg_yards_play FROM joined_stats
    UNION ALL SELECT 'avg_yards_game', win_pct, avg_yards_game FROM joined_stats
    UNION ALL SELECT 'third_down_conv', win_pct, third_down_conv FROM joined_stats
    UNION ALL SELECT 'fourth_down_conv', win_pct, fourth_down_conv FROM joined_stats
    UNION ALL SELECT 'sacks_taken', win_pct, sacks_taken FROM joined_stats
    UNION ALL SELECT 'interceptions_thrown', win_pct, interceptions_thrown FROM joined_stats
    UNION ALL SELECT 'tds_scored', win_pct, tds_scored FROM joined_stats
    UNION ALL SELECT 'avg_penalty_yards_game', win_pct, avg_penalty_yards_game FROM joined_stats
    UNION ALL SELECT 'opp_rush_yards', win_pct, opp_rush_yards FROM joined_stats
    UNION ALL SELECT 'opp_avg_rush_yards_game', win_pct, opp_avg_rush_yards_game FROM joined_stats
    UNION ALL SELECT 'opp_avg_pass_yards_game', win_pct, opp_avg_pass_yards_game FROM joined_stats
    UNION ALL SELECT 'opp_avg_yards_play', win_pct, opp_avg_yards_play FROM joined_stats
    UNION ALL SELECT 'opp_avg_yards_game', win_pct, opp_avg_yards_game FROM joined_stats
    UNION ALL SELECT 'opp_third_down_conv', win_pct, opp_third_down_conv FROM joined_stats
    UNION ALL SELECT 'opp_fourth_down_conv', win_pct, opp_fourth_down_conv FROM joined_stats
    UNION ALL SELECT 'sacks', win_pct, sacks FROM joined_stats
    UNION ALL SELECT 'interceptions', win_pct, interceptions FROM joined_stats
    UNION ALL SELECT 'opp_tds_scored', win_pct, opp_tds_scored FROM joined_stats
),
correlations AS (
    SELECT
        stat_name,
        COUNT(*) AS sample_size,
        CORR(win_pct, stat_value) AS correlation,
        ABS(CORR(win_pct, stat_value)) AS abs_correlation
    FROM unpivoted
    WHERE stat_value IS NOT NULL
    GROUP BY stat_name
)
SELECT
    stat_name,
    sample_size,
    ROUND(correlation::numeric, 4) AS correlation,
    ROUND(abs_correlation::numeric, 4) AS abs_correlation,
    RANK() OVER (ORDER BY abs_correlation DESC) AS correlation_rank
FROM correlations
ORDER BY correlation_rank;

CREATE VIEW game_trends_2015_2025 AS
WITH yearly AS (
    SELECT
        s.year,
        COUNT(*) AS team_count,
        AVG(s.win_pct) AS win_pct,
        AVG(ts.avg_rush_yards_game) AS avg_rush_yards_game,
        AVG(ts.avg_pass_yards_game) AS avg_pass_yards_game,
        AVG(ts.avg_yards_game) AS avg_yards_game,
        AVG(ts.avg_yards_play) AS avg_yards_play,
        AVG(ts.tds_scored) AS avg_tds_scored,
        AVG(os.opp_avg_yards_game) AS opp_avg_yards_game,
        AVG(os.opp_avg_yards_play) AS opp_avg_yards_play,
        AVG(os.opp_tds_scored) AS avg_opp_tds_scored
    FROM seasons s
    JOIN team_stats ts ON s.season_id = ts.season_id
    JOIN opponent_stats os ON s.season_id = os.season_id
    GROUP BY s.year
),
shares AS (
    SELECT
        *,
        avg_rush_yards_game / NULLIF(avg_rush_yards_game + avg_pass_yards_game, 0) AS rush_yard_share,
        avg_pass_yards_game / NULLIF(avg_rush_yards_game + avg_pass_yards_game, 0) AS pass_yard_share
    FROM yearly
),
trends AS (
    SELECT
        *,
        avg_rush_yards_game - LAG(avg_rush_yards_game) OVER (ORDER BY year) AS yoy_rush_yards_game_change,
        avg_pass_yards_game - LAG(avg_pass_yards_game) OVER (ORDER BY year) AS yoy_pass_yards_game_change,
        avg_yards_play - LAG(avg_yards_play) OVER (ORDER BY year) AS yoy_efficiency_change,
        avg_tds_scored - LAG(avg_tds_scored) OVER (ORDER BY year) AS yoy_scoring_change,
        rush_yard_share - LAG(rush_yard_share) OVER (ORDER BY year) AS yoy_rush_share_change,
        pass_yard_share - LAG(pass_yard_share) OVER (ORDER BY year) AS yoy_pass_share_change
    FROM shares
)
SELECT *
FROM trends
ORDER BY year;

\copy (SELECT * FROM stat_win_correlation) TO 'data/outputs/stat_win_correlation.csv' CSV HEADER
\copy (SELECT * FROM game_trends_2015_2025) TO 'data/outputs/game_trends_2015_2025.csv' CSV HEADER