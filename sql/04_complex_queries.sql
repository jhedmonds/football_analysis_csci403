SET search_path TO football_analysis;

DROP VIEW IF EXISTS advanced_team_metrics;
DROP VIEW IF EXISTS team_identity_summary;
DROP VIEW IF EXISTS efficiency_threshold_analysis;


CREATE VIEW advanced_team_metrics AS
SELECT
    tm.team_name,
    s.year,
    s.wins,
    s.losses,
    s.ties,
    s.win_pct,

    ts.avg_yards_play,
    os.opp_avg_yards_play,
    ts.avg_yards_game,
    os.opp_avg_yards_game,
    ts.avg_rush_yards_game,
    ts.avg_pass_yards_game,
    ts.tds_scored,
    os.opp_tds_scored,
    ts.interceptions_thrown,
    ts.sacks_taken,
    ts.total_penalties,
    os.sacks,
    os.interceptions,

    -- Main efficiency metric
    ts.avg_yards_play - os.opp_avg_yards_play AS efficiency_differential,

    -- How efficiently yards turn into touchdowns
    ts.tds_scored / NULLIF(ts.avg_yards_game, 0) AS scoring_efficiency,

    -- Offensive identity
    ts.avg_rush_yards_game
        / NULLIF(ts.avg_rush_yards_game + ts.avg_pass_yards_game, 0) AS rush_yard_share,

    ts.avg_pass_yards_game
        / NULLIF(ts.avg_rush_yards_game + ts.avg_pass_yards_game, 0) AS pass_yard_share,

    ABS(
        ts.avg_rush_yards_game
            / NULLIF(ts.avg_rush_yards_game + ts.avg_pass_yards_game, 0)
        -
        ts.avg_pass_yards_game
            / NULLIF(ts.avg_rush_yards_game + ts.avg_pass_yards_game, 0)
    ) AS offensive_balance_score,

    -- Offense + defense dominance
    ts.tds_scored - os.opp_tds_scored AS td_differential,

    -- Mistake/discipline metric
    ts.interceptions_thrown + ts.sacks_taken + ts.total_penalties AS discipline_score,

    CASE
        WHEN s.win_pct >= 0.7000 THEN 'Successful'
        WHEN s.win_pct >= 0.5000 THEN 'Average'
        ELSE 'Struggling'
    END AS success_tier,

    CASE
        WHEN ts.avg_yards_play - os.opp_avg_yards_play >= 1.0 THEN 'Strong Positive Differential'
        WHEN ts.avg_yards_play - os.opp_avg_yards_play >= 0.0 THEN 'Slight Positive Differential'
        ELSE 'Negative Differential'
    END AS efficiency_group,

    CASE
        WHEN ABS(
            ts.avg_rush_yards_game
                / NULLIF(ts.avg_rush_yards_game + ts.avg_pass_yards_game, 0)
            -
            ts.avg_pass_yards_game
                / NULLIF(ts.avg_rush_yards_game + ts.avg_pass_yards_game, 0)
        ) <= 0.15 THEN 'Balanced'
        WHEN ts.avg_rush_yards_game > ts.avg_pass_yards_game THEN 'Run Heavy'
        ELSE 'Pass Heavy'
    END AS offensive_identity

FROM seasons s
JOIN teams tm ON s.team_id = tm.team_id
JOIN team_stats ts ON s.season_id = ts.season_id
JOIN opponent_stats os ON s.season_id = os.season_id;


CREATE VIEW team_identity_summary AS
SELECT
    team_name,
    COUNT(*) AS seasons_analyzed,
    ROUND(AVG(win_pct), 4) AS avg_win_pct,
    ROUND(AVG(efficiency_differential), 3) AS avg_efficiency_differential,
    ROUND(AVG(scoring_efficiency), 4) AS avg_scoring_efficiency,
    ROUND(AVG(offensive_balance_score), 4) AS avg_balance_score,
    ROUND(AVG(td_differential), 2) AS avg_td_differential,
    ROUND(AVG(discipline_score), 2) AS avg_discipline_score,

    COUNT(*) FILTER (WHERE success_tier = 'Successful') AS successful_seasons,

    ROUND(
        COUNT(*) FILTER (WHERE success_tier = 'Successful')::numeric
        / NULLIF(COUNT(*), 0),
        4
    ) AS successful_season_rate

FROM advanced_team_metrics
GROUP BY team_name
ORDER BY avg_win_pct DESC;


CREATE VIEW efficiency_threshold_analysis AS
WITH threshold_flags AS (
    SELECT
        *,
        CASE
            WHEN efficiency_differential >= 1.0 THEN 'YPP Differential >= 1.0'
            ELSE 'YPP Differential < 1.0'
        END AS ypp_diff_threshold,

        CASE
            WHEN avg_yards_play >= 5.5 THEN 'Offensive YPP >= 5.5'
            ELSE 'Offensive YPP < 5.5'
        END AS offensive_ypp_threshold,

        CASE
            WHEN opp_avg_yards_game <= 350 THEN 'Defense Allows <= 350 YPG'
            ELSE 'Defense Allows > 350 YPG'
        END AS defense_yards_threshold,

        CASE
            WHEN tds_scored >= 40 THEN 'TDs Scored >= 40'
            ELSE 'TDs Scored < 40'
        END AS td_threshold
    FROM advanced_team_metrics
),
unpivoted_thresholds AS (
    SELECT 'Efficiency Differential' AS threshold_type, ypp_diff_threshold AS threshold_group, win_pct, success_tier
    FROM threshold_flags

    UNION ALL

    SELECT 'Offensive Efficiency', offensive_ypp_threshold, win_pct, success_tier
    FROM threshold_flags

    UNION ALL

    SELECT 'Defensive Resistance', defense_yards_threshold, win_pct, success_tier
    FROM threshold_flags

    UNION ALL

    SELECT 'Touchdown Production', td_threshold, win_pct, success_tier
    FROM threshold_flags
)
SELECT
    threshold_type,
    threshold_group,
    COUNT(*) AS team_seasons,
    ROUND(AVG(win_pct), 4) AS avg_win_pct,
    COUNT(*) FILTER (WHERE success_tier = 'Successful') AS successful_seasons,
    ROUND(
        COUNT(*) FILTER (WHERE success_tier = 'Successful')::numeric
        / NULLIF(COUNT(*), 0),
        4
    ) AS success_rate
FROM unpivoted_thresholds
GROUP BY threshold_type, threshold_group
ORDER BY threshold_type, avg_win_pct DESC;


-- Export outputs for Python visualizations
\copy (SELECT * FROM advanced_team_metrics) TO 'data/outputs/advanced_team_metrics.csv' CSV HEADER
\copy (SELECT * FROM team_identity_summary) TO 'data/outputs/team_identity_summary.csv' CSV HEADER
\copy (SELECT * FROM efficiency_threshold_analysis) TO 'data/outputs/efficiency_threshold_analysis.csv' CSV HEADER
