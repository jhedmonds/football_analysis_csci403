import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

# creating paths to directories
OUTPUT_DIR = Path("data/outputs")
FIGURE_DIR = Path("figures")
FIGURE_DIR.mkr(exist_ok=True)

correlation_file = OUTPUT_DIR / "stat_win_correlation.csv"
trends_file = OUTPUT_DIR / "game_trends_2015_2025.csv"

# checking if correlation file exists
if not correlation_file.exists():
  print("Missing stat_win_correlation.csv. Waiting on SQL output.") # missing file message
else:
  # reading CSV
  corr = pd.read_csv(correlation_file)

  # top 10 correlations
  top_corr = corr.head(10)

  # creating visual for stats correlated to winning
  plt.figure(figsize=(10, 6))
  plt.barh(top_corr["stat_name"], top_corr["correlation"])
  plt.xlabel("Correlation with Win Percentage")
  plt.ylabel("Statistic")
  plt.title("Top Stats Correlated with Winning")
  plt.tight_layout()
  plt.savefig(FIGURE_DIR / "top_stats_correlated_with_winning.png")
  plt.close()

if not trends_file.exists():
  print("Missing game_trends_2015_2025.csv. Waiting on SQL output.")
else:
  trends = pd.read_csv(trends_file)

  # visual for run/pass yards per game over time
  plt.figure(figsize=(10, 6))
  plt.plot(trends["year"], trends["avg_rush_yards_game"], label="Rush Yards/Game")
  plt.plot(trends["year"], trends["avg_pass_yards_game"], label="Pass Yards/Game")
  plt.xlabel("Year")
  plt.ylabel("Yards per Game")
  plt.title("Rush vs Pass Yards Over Time")
  plt.legend()
  plt.tight_layout()
  plt.savefig(FIGURE_DIR / "rush_vs_pass_over_time.png")
  plt.close()

  # visual for share of run and pass 
  plt.figure(figsize=(10, 6))
  plt.plot(trends["year"], trends["rush_share"], label="Rush Share")
  plt.plot(trends["year"], trends["pass_share"], label="Pass Share")
  plt.xlabel("Year")
  plt.ylabel("Share of Offense")
  plt.title("Rush/Pass Share Over Time")
  plt.legend()
  plt.tight_layout()
  plt.savefig(FIGURE_DIR / "rush_pass_share_over_time.png")
  plt.close()
