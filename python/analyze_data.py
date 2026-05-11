import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

# Paths
OUTPUT_DIR = Path("data/outputs")
FIGURE_DIR = Path("figures")
FIGURE_DIR.mkdir(exist_ok=True)

advanced_metrics_file = OUTPUT_DIR / "advanced_team_metrics.csv"
team_summary_file = OUTPUT_DIR / "team_identity_summary.csv"
threshold_file = OUTPUT_DIR / "efficiency_threshold_analysis.csv"

# Load data
advanced = pd.read_csv(advanced_metrics_file)
summary = pd.read_csv(team_summary_file)
thresholds = pd.read_csv(threshold_file)

# Graph 1:Efficiency Differential vs Win Percentage
plt.figure(figsize=(9, 6))

for team in advanced["team_name"].unique():
    team_df = advanced[advanced["team_name"] == team]

    plt.scatter(
        team_df["efficiency_differential"],
        team_df["win_pct"],
        s=90,
        alpha=0.85,
        label=team,
        edgecolors="black"
    )

plt.xlabel("Efficiency Differential (Team YPP - Opponent YPP)")
plt.ylabel("Win Percentage")
plt.title("Efficiency Differential vs Winning")
plt.grid(True, linestyle="--", alpha=0.4)
plt.legend()
plt.tight_layout()

plt.savefig(
    FIGURE_DIR / "efficiency_differential_vs_winning.png",
    dpi=300
)

plt.close()

# Graph 2: Offensive Identity vs Average Win Percentage
identity_summary = (
    advanced.groupby("offensive_identity")["win_pct"]
    .mean()
    .sort_values()
)

plt.figure(figsize=(8, 6))

plt.bar(
    identity_summary.index,
    identity_summary.values
)

plt.ylabel("Average Win Percentage")
plt.xlabel("Offensive Identity")
plt.title("Offensive Identity vs Winning")
plt.grid(True, linestyle="--", alpha=0.4)

plt.tight_layout()

plt.savefig(
    FIGURE_DIR / "offensive_identity_vs_winning.png",
    dpi=300
)

plt.close()


# Graph 3: Team Efficiency Differential Over Time
plt.figure(figsize=(10, 6))

for team in advanced["team_name"].unique():
    team_df = advanced[advanced["team_name"] == team]

    plt.plot(
        team_df["year"],
        team_df["efficiency_differential"],
        marker="o",
        linewidth=2,
        label=team
    )

plt.axhline(
    y=1.0,
    linestyle="--",
    linewidth=1.5
)

plt.xlabel("Year")
plt.ylabel("Efficiency Differential")
plt.title("Program Efficiency Differential Over Time")
plt.grid(True, linestyle="--", alpha=0.4)
plt.legend()

plt.tight_layout()

plt.savefig(
    FIGURE_DIR / "efficiency_differential_over_time.png",
    dpi=300
)

plt.close()

# Graph 4: Threshold Success Rates
threshold_plot = thresholds.copy()

plt.figure(figsize=(12, 6))

plt.bar(
    threshold_plot["threshold_group"],
    threshold_plot["success_rate"]
)

plt.xticks(rotation=15)
plt.ylabel("Successful Season Rate")
plt.xlabel("Threshold Group")
plt.title("Football Performance Thresholds and Success")

plt.grid(True, linestyle="--", alpha=0.4)

plt.tight_layout()

plt.savefig(
    FIGURE_DIR / "threshold_success_rates.png",
    dpi=300
)

plt.close()

# Graph 5: Team Identity Heatmap
heatmap_metrics = summary[
    [
        "team_name",
        "avg_win_pct",
        "avg_efficiency_differential",
        "avg_scoring_efficiency",
        "avg_td_differential",
        "avg_balance_score",
        "avg_discipline_score"
    ]
].copy()

heatmap_metrics = heatmap_metrics.set_index("team_name")

# normalize columns independently
heatmap_normalized = (
    heatmap_metrics - heatmap_metrics.min()
) / (
    heatmap_metrics.max() - heatmap_metrics.min()
)

plt.figure(figsize=(10, 6))

plt.imshow(
    heatmap_normalized,
    aspect="auto"
)

plt.colorbar(label="Relative Strength")

plt.xticks(
    range(len(heatmap_normalized.columns)),
    heatmap_normalized.columns,
    rotation=20
)

plt.yticks(
    range(len(heatmap_normalized.index)),
    heatmap_normalized.index
)

plt.title("Program Identity Heatmap")

plt.tight_layout()

plt.savefig(
    FIGURE_DIR / "program_identity_heatmap.png",
    dpi=300
)

plt.close()

print("Finished creating advanced football analytics figures.")
