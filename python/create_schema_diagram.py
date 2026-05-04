from pathlib import Path
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle, Ellipse, Polygon

FIGURE_DIR = Path("figures")
FIGURE_DIR.mkdir(exist_ok=True)

OUTPUT_FILE = FIGURE_DIR / "schema_diagram.png"


def draw_entity(ax, x, y, w, h, name):
    ax.add_patch(Rectangle((x, y), w, h, fill=False, linewidth=2))
    ax.text(x + w / 2, y + h / 2, name, ha="center", va="center", fontsize=13)


def draw_attr(ax, x, y, w, h, text, key=False):
    ax.add_patch(Ellipse((x, y), w, h, fill=False, linewidth=1.4))
    ax.text(x, y, text, ha="center", va="center", fontsize=9)

    if key:
        ax.plot(
            [x - w * 0.25, x + w * 0.25],
            [y - h * 0.18, y - h * 0.18],
            color="black",
            linewidth=1,
        )


def draw_relationship(ax, x, y, w, h, text):
    points = [
        (x, y + h / 2),
        (x + w / 2, y + h),
        (x + w, y + h / 2),
        (x + w / 2, y),
    ]
    ax.add_patch(Polygon(points, closed=True, fill=False, linewidth=1.7))
    ax.text(x + w / 2, y + h / 2, text, ha="center", va="center", fontsize=10)


def connect(ax, x1, y1, x2, y2, label=None, lx=None, ly=None):
    ax.plot([x1, x2], [y1, y2], color="black", linewidth=1.2)

    if label is not None:
        ax.text(lx, ly, label, ha="center", va="center", fontsize=11)


def main():
    fig, ax = plt.subplots(figsize=(16, 9))
    ax.set_xlim(0, 16)
    ax.set_ylim(0, 9)
    ax.axis("off")

    ax.text(
        8,
        8.55,
        "RMAC Football Database ERD",
        ha="center",
        va="center",
        fontsize=18,
        fontweight="bold",
    )

    # =========================
    # Entities
    # =========================
    draw_entity(ax, 1.0, 5.0, 1.9, 0.8, "Team")
    draw_entity(ax, 6.2, 5.0, 1.9, 0.8, "Season")
    draw_entity(ax, 12.4, 6.2, 2.2, 0.8, "Team Stats")
    draw_entity(ax, 12.4, 3.2, 2.2, 0.8, "Opponent Stats")

    # =========================
    # Relationships
    # =========================
    draw_relationship(ax, 3.8, 4.85, 1.5, 1.1, "has")
    draw_relationship(ax, 9.5, 6.05, 1.5, 1.1, "has")
    draw_relationship(ax, 9.5, 3.05, 1.5, 1.1, "has")

    # =========================
    # Entity connections
    # =========================
    connect(ax, 2.9, 5.4, 3.8, 5.4, "1", 3.35, 5.65)
    connect(ax, 5.3, 5.4, 6.2, 5.4, "N", 5.75, 5.65)

    connect(ax, 8.1, 5.65, 9.5, 6.6, "1", 8.7, 6.28)
    connect(ax, 11.0, 6.6, 12.4, 6.6, "1", 11.7, 6.85)

    connect(ax, 8.1, 5.15, 9.5, 3.6, "1", 8.95, 4.7)
    connect(ax, 11.0, 3.6, 12.4, 3.6, "1", 11.7, 3.85)

    # =========================
    # Team attributes
    # =========================
    draw_attr(ax, 0.95, 7.0, 1.45, 0.55, "team_id", key=True)
    draw_attr(ax, 2.9, 7.0, 1.75, 0.55, "team_name")

    connect(ax, 1.65, 5.8, 0.95, 6.72)
    connect(ax, 2.25, 5.8, 2.9, 6.72)

    # =========================
    # Season attributes
    # =========================
    draw_attr(ax, 5.7, 7.35, 1.65, 0.55, "season_id", key=True)
    draw_attr(ax, 7.8, 7.35, 1.2, 0.55, "year")
    draw_attr(ax, 5.3, 3.6, 1.1, 0.55, "wins")
    draw_attr(ax, 7.0, 3.35, 1.25, 0.55, "losses")
    draw_attr(ax, 8.6, 3.6, 1.35, 0.55, "win_pct")

    connect(ax, 6.65, 5.8, 5.7, 7.08)
    connect(ax, 7.55, 5.8, 7.8, 7.08)
    connect(ax, 6.6, 5.0, 5.3, 3.88)
    connect(ax, 7.15, 5.0, 7.0, 3.63)
    connect(ax, 8.1, 5.15, 8.6, 3.88)

    # =========================
    # Team Stats attributes
    # =========================
    draw_attr(ax, 12.0, 8.0, 1.35, 0.55, "stat_id", key=True)
    draw_attr(ax, 14.7, 8.0, 1.9, 0.55, "avg_yards_play")
    draw_attr(ax, 15.0, 5.45, 1.55, 0.55, "tds_scored")
    draw_attr(ax, 12.1, 5.45, 1.65, 0.55, "rush_yards")

    connect(ax, 13.0, 7.0, 12.0, 7.73)
    connect(ax, 14.0, 7.0, 14.7, 7.73)
    connect(ax, 14.2, 6.2, 15.0, 5.72)
    connect(ax, 12.9, 6.2, 12.1, 5.72)

    # =========================
    # Opponent Stats attributes
    # =========================
    draw_attr(ax, 12.0, 2.05, 1.75, 0.55, "opp_stat_id", key=True)
    draw_attr(ax, 14.8, 2.05, 1.35, 0.55, "opp_tds")
    draw_attr(ax, 15.0, 4.75, 1.9, 0.55, "opp_yards_play")
    draw_attr(ax, 11.6, 4.75, 1.15, 0.55, "sacks")

    connect(ax, 13.0, 3.2, 12.0, 2.33)
    connect(ax, 14.0, 3.2, 14.8, 2.33)
    connect(ax, 14.25, 4.0, 15.0, 4.48)
    connect(ax, 12.8, 4.0, 11.6, 4.48)

    # =========================
    # Footer
    # =========================
    ax.text(
        8,
        0.45,
        "Entities = rectangles   |   Attributes = ovals   |   Relationships = diamonds   |   Underlined attributes = primary keys",
        ha="center",
        va="center",
        fontsize=10,
    )

    plt.tight_layout()
    plt.savefig(OUTPUT_FILE, dpi=300, bbox_inches="tight")
    plt.close()

    print(f"Created {OUTPUT_FILE}")


if __name__ == "__main__":
    main()