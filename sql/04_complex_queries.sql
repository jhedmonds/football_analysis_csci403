-- Trends Query

SET search_path TO football_analysis;

WITH yearly_stats AS (
  SELECT
    s.year,
    AVG(ts.rush_yards) AS avg_rush_yards,
    AVG(ts.pass_yards) AS avg_pass_yards,
    AVG(ts.avg_yards_play) AS avg_yards_play,
    AVG(ts.third_down_conv) AS avg_third_down_conv,
    AVG(ts.fourth_down_conv) AS avg_fourth_down_conv,
    AVG(os.opp_avg_yards_play) AS avg_opp_yards_play,
    AVG(os.points_allowed) AS avg_points_allowed,
    AVG(ts.rush_yards + ts.pass_yards) AS avg_total_yards -- total offense for share calcs
  FROM seasons s
  JOIN team_stats ts ON s.season_id = ts.season_id
  JOIN opponent_stats os ON s.season_id = os.season_id
  GROUP BY s.year
),

with_shares AS (
  SELECT
    year,
    avg_rush_yards,
    avg_pass_yards,
    avg_yards_play,
    avg_third_down_conv,
    avg_fourth_down_conv,
    avg_opp_yards_play,
    avg_points_allowed,
    avg_rush_yards / avg_total_yards AS rush_share, -- rush and pass derived metrics
    avg_pass_yards / avg_total_yards AS pass_share
  FROM yearly_stats
),

with_lag AS (
  SELECT
    *,
    avg_rush_yards - LAG(avg_rush_yards) OVER (ORDER BY year) AS rush_yards_change,
    avg_pass_yards - LAG(avg_pass_yards) OVER (ORDER BY year) AS pass_yards_change,
    avg_yards_play - LAG(avg_yards_play) OVER (ORDER BY year) AS efficiency_change
  FROM with_shares
)

SELECT *
FROM with_lag
ORDER BY year;

\copy (
  WITH yearly_stats AS (
    SELECT
      s.year,
      AVG(ts.rush_yards) AS avg_rush_yards,
      AVG(ts.pass_yards) AS avg_pass_yards,
      AVG(ts.avg_yards_play) AS avg_yards_play,
      AVG(ts.third_down_conv) AS avg_third_down_conv,
      AVG(ts.fourth_down_conv) AS avg_fourth_down_conv,
      AVG(os.opp_avg_yards_play) AS avg_opp_yards_play,
      AVG(os.points_allowed) AS avg_points_allowed,
      AVG(ts.rush_yards + ts.pass_yards) AS avg_total_yards -- total offense for share calcs
    FROM seasons s
    JOIN team_stats ts ON s.season_id = ts.season_id
    JOIN opponent_stats os ON s.season_id = os.season_id
    GROUP BY s.year
  ),

  with_shares AS (
    SELECT
      year,
      avg_rush_yards,
      avg_pass_yards,
      avg_yards_play,
      avg_third_down_conv,
      avg_fourth_down_conv,
      avg_opp_yards_play,
      avg_points_allowed,
      avg_rush_yards / avg_total_yards AS rush_share, -- rush and pass derived metrics
      avg_pass_yards / avg_total_yards AS pass_share
    FROM yearly_stats
  ),

  with_lag AS (
    SELECT
      *,
      avg_rush_yards - LAG(avg_rush_yards) OVER (ORDER BY year) AS rush_yards_change,
      avg_pass_yards - LAG(avg_pass_yards) OVER (ORDER BY year) AS pass_yards_change,
      avg_yards_play - LAG(avg_yards_play) OVER (ORDER BY year) AS efficiency_change
    FROM with_shares
  )

  SELECT *
  FROM with_lag
  ORDER BY year
)
TO 'data/outputs/game_trends_2015_2025.csv'
CSV HEADER;
