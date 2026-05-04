import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

# creating paths to directories
OUTPUT_DIR = Path("data/outputs")
CLEANED_DIR = Path("data/cleaned")
FIGURE_DIR = Path("figures")
FIGURE_DIR.mkdir(exist_ok=True)

correlation_file = OUTPUT_DIR / "stat_win_correlation.csv"
trends_file = OUTPUT_DIR / "game_trends_2015_2025.csv"
cleaned_file = CLEANED_DIR / "football_stats_combined.csv"


# ------------------------------------------------------------
# Graph 1: Top 10 stats correlated with winning
# ------------------------------------------------------------
if not correlation_file.exists():
    print("Missing stat_win_correlation.csv. Waiting on SQL output.")
else:
    corr = pd.read_csv(correlation_file)

    top_corr = corr.head(10).copy()
    top_corr = top_corr.sort_values("abs_correlation")

    plt.figure(figsize=(10, 6))
    plt.barh(top_corr["stat_name"], top_corr["abs_correlation"])
    plt.xlabel("Absolute Correlation with Win Percentage")
    plt.ylabel("Statistic")
    plt.title("Top Stats Correlated with Winning")
    plt.grid(True, linestyle="--", alpha=0.4)
    plt.tight_layout()
    plt.savefig(FIGURE_DIR / "top_stats_correlated_with_winning.png", dpi=300)
    plt.close()

    # ------------------------------------------------------------
    # Graph 2: Top 5 stats correlated with winning
    # ------------------------------------------------------------
    top_5 = corr.head(5).copy()
    top_5 = top_5.sort_values("abs_correlation")

    plt.figure(figsize=(9, 5))
    plt.barh(top_5["stat_name"], top_5["abs_correlation"])
    plt.xlabel("Absolute Correlation with Win Percentage")
    plt.ylabel("Statistic")
    plt.title("Top 5 Stats Correlated with Winning")
    plt.grid(True, linestyle="--", alpha=0.4)
    plt.tight_layout()
    plt.savefig(FIGURE_DIR / "top_5_stats_correlated_with_winning.png", dpi=300)
    plt.close()


# ------------------------------------------------------------
# Graph 3: Rush vs pass yards over time
# ------------------------------------------------------------
if not trends_file.exists():
    print("Missing game_trends_2015_2025.csv. Waiting on SQL output.")
else:
    trends = pd.read_csv(trends_file)

    plt.figure(figsize=(10, 6))
    plt.plot(
        trends["year"],
        trends["avg_rush_yards_game"],
        marker="o",
        label="Rush Yards/Game",
    )
    plt.plot(
        trends["year"],
        trends["avg_pass_yards_game"],
        marker="o",
        label="Pass Yards/Game",
    )
    plt.xlabel("Year")
    plt.ylabel("Yards per Game")
    plt.title("Rush vs Pass Yards Over Time")
    plt.legend()
    plt.grid(True, linestyle="--", alpha=0.4)
    plt.tight_layout()
    plt.savefig(FIGURE_DIR / "rush_vs_pass_yards_over_time.png", dpi=300)
    plt.close()


# ------------------------------------------------------------
# Graphs based on cleaned team-season data
# ------------------------------------------------------------
if not cleaned_file.exists():
    print("Missing football_stats_combined.csv. Run combine_data.py first.")
else:
    df = pd.read_csv(cleaned_file)

    # ------------------------------------------------------------
    # Graph 4: Win percentage vs offensive efficiency
    # ------------------------------------------------------------
    plt.figure(figsize=(8, 6))
    plt.scatter(
        df["avg_yards_play"],
        df["win_pct"],
        alpha=0.85,
        s=70,
        edgecolors="black",
    )
    plt.xlabel("Average Yards per Play")
    plt.ylabel("Win Percentage")
    plt.title("Win Percentage vs Offensive Efficiency")
    plt.grid(True, linestyle="--", alpha=0.4)
    plt.tight_layout()
    plt.savefig(FIGURE_DIR / "winpct_vs_yards_per_play.png", dpi=300)
    plt.close()

    # ------------------------------------------------------------
    # Graph 5: Offense vs defense comparison, colored by win %
    # ------------------------------------------------------------
    plt.figure(figsize=(10, 6))

    scatter = plt.scatter(
        df["avg_yards_game"],
        df["opp_avg_yards_game"],
        c=df["win_pct"],
        cmap="RdYlGn",
        edgecolors="black",
        alpha=0.85,
        s=70,
    )

    plt.xlabel("Team Yards per Game")
    plt.ylabel("Opponent Yards per Game")
    plt.title("Offense vs Defense: Yards per Game (Colored by Win %)")

    cbar = plt.colorbar(scatter)
    cbar.set_label("Win Percentage")

    plt.grid(True, linestyle="--", alpha=0.4)
    plt.tight_layout()
    plt.savefig(FIGURE_DIR / "offense_vs_defense_yards_game.png", dpi=300)
    plt.close()

    # ------------------------------------------------------------
    # Graph 6: Touchdowns vs winning
    # ------------------------------------------------------------
    plt.figure(figsize=(8, 6))
    plt.scatter(
        df["tds_scored"],
        df["win_pct"],
        alpha=0.85,
        s=70,
        edgecolors="black",
    )
    plt.xlabel("Touchdowns Scored")
    plt.ylabel("Win Percentage")
    plt.title("Touchdowns Scored vs Win Percentage")
    plt.grid(True, linestyle="--", alpha=0.4)
    plt.tight_layout()
    plt.savefig(FIGURE_DIR / "tds_scored_vs_winning.png", dpi=300)
    plt.close()

    # ------------------------------------------------------------
    # Graph 7: Scoring efficiency vs winning
    # ------------------------------------------------------------
    df["tds_per_100_yards"] = (df["tds_scored"] / df["avg_yards_game"]) * 100

    plt.figure(figsize=(8, 6))
    plt.scatter(
        df["tds_per_100_yards"],
        df["win_pct"],
        alpha=0.85,
        s=70,
        edgecolors="black",
    )
    plt.xlabel("Touchdowns per 100 Yards")
    plt.ylabel("Win Percentage")
    plt.title("Scoring Efficiency vs Win Percentage")
    plt.grid(True, linestyle="--", alpha=0.4)
    plt.tight_layout()
    plt.savefig(FIGURE_DIR / "scoring_efficiency_vs_winning.png", dpi=300)
    plt.close()


print("Finished creating figures.")