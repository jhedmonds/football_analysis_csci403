import os
import re
import pandas as pd

RAW_DIR = "data/raw"
OUT_FILE = "data/cleaned/football_stats_combined.csv"
RECORD_FILE = "data/raw/team_records.csv"

FILES = {
    "csup_football_stats.xlsx": "CSU Pueblo",
    "mesa_football_stats.xlsx": "Colorado Mesa",
    "mines_football_stats.xlsx": "Colorado Mines",
    "western_football_stats.xlsx": "Western Colorado",
}

FINAL_COLUMNS = [
    "team",
    "year",
    "wins",
    "losses",
    "ties",
    "win_pct",

    "rush_yards",
    "rush_yards_gained",
    "rush_yards_lost",
    "rush_attempts",
    "avg_rush_yards_attempt",
    "avg_rush_yards_game",
    "rush_tds",

    "pass_attempts",
    "avg_pass_yards_attempt",
    "avg_pass_yards_game",
    "pass_tds",

    "total_offensive_plays",
    "avg_yards_play",
    "avg_yards_game",
    "interceptions_thrown",
    "third_down_conv",
    "fourth_down_conv",
    "sacks_taken",
    "tds_scored",
    "time_of_possession_game_min",
    "total_penalties",
    "avg_penalty_yards_game",

    "opp_rush_yards",
    "opp_rush_yards_gained",
    "opp_rush_yards_lost",
    "opp_rush_attempts",
    "opp_avg_rush_yards_attempt",
    "opp_avg_rush_yards_game",
    "opp_rush_tds",

    "opp_pass_attempts",
    "opp_avg_pass_yards_attempt",
    "opp_avg_pass_yards_game",
    "opp_pass_tds",

    "total_defensive_plays",
    "opp_avg_yards_play",
    "opp_avg_yards_game",
    "interceptions",
    "opp_third_down_conv",
    "opp_fourth_down_conv",
    "sacks",
    "opp_tds_scored",
    "opp_time_of_possession_game_min",
    "opp_total_penalties",
    "opp_avg_penalty_yards_game",
]


def clean_col(name):
    name = str(name).strip().lower()
    name = name.replace("opp.", "opp")
    name = name.replace("3rd", "third")
    name = name.replace("4th", "fourth")
    name = name.replace("%", "pct")
    name = name.replace("/", " ")
    name = name.replace(".", "")
    name = name.replace("&", "and")
    name = re.sub(r"[^a-z0-9]+", "_", name)
    return name.strip("_")


def parse_ratio(value):
    if pd.isna(value):
        return None

    if isinstance(value, str):
        value = value.strip()

        if value == "":
            return None

        if "-" in value:
            made, attempts = value.split("-")
            made = float(made.strip())
            attempts = float(attempts.strip())
            return made / attempts if attempts != 0 else None

        if value.endswith("%"):
            return float(value.replace("%", "")) / 100

    return float(value)


def parse_time(value):
    if pd.isna(value):
        return None

    if isinstance(value, str):
        value = value.strip()

        if value == "":
            return None

        if ":" in value:
            minutes, seconds = value.split(":")
            return int(minutes) + int(seconds) / 60

    return float(value)


def numeric_or_null(value):
    if pd.isna(value):
        return None

    if isinstance(value, str):
        value = value.strip().replace(",", "")
        if value == "":
            return None

    return float(value)


def add_missing_columns(df):
    for col in FINAL_COLUMNS:
        if col not in df.columns:
            df[col] = None
    return df


def load_team_file(filename, team_name):
    path = os.path.join(RAW_DIR, filename)

    df = pd.read_excel(path)
    df.columns = [clean_col(c) for c in df.columns]

    df["team"] = team_name

    ratio_cols = [
        "third_down_conv",
        "fourth_down_conv",
        "opp_third_down_conv",
        "opp_fourth_down_conv",
    ]

    time_cols = [
        "time_of_possession_game_min",
        "opp_time_of_possession_game_min",
    ]

    for col in ratio_cols:
        if col in df.columns:
            df[col] = df[col].apply(parse_ratio)

    for col in time_cols:
        if col in df.columns:
            df[col] = df[col].apply(parse_time)

    for col in df.columns:
        if col not in ["team"] + ratio_cols + time_cols:
            if col != "year":
                try:
                    df[col] = df[col].apply(numeric_or_null)
                except Exception:
                    pass

    df = add_missing_columns(df)

    return df[FINAL_COLUMNS]


def main():
    dfs = []

    for filename, team_name in FILES.items():
        print(f"Loading {filename}")
        dfs.append(load_team_file(filename, team_name))

    combined = pd.concat(dfs, ignore_index=True)

    records = pd.read_csv(RECORD_FILE)
    records.columns = [clean_col(c) for c in records.columns]

    combined["team"] = combined["team"].astype(str).str.strip()
    records["team"] = records["team"].astype(str).str.strip()

    combined["year"] = combined["year"].astype(int)
    records["year"] = records["year"].astype(int)

    combined = combined.drop(columns=["wins", "losses", "ties", "win_pct"], errors="ignore")
    combined = combined.merge(records, on=["team", "year"], how="left")

    missing_records = combined[combined["wins"].isna()]
    if not missing_records.empty:
        print("Missing team records for these rows:")
        print(missing_records[["team", "year"]])
        raise ValueError("Fix data/raw/team_records.csv before continuing.")

    combined["win_pct"] = (combined["wins"] + 0.5 * combined["ties"]) / (
        combined["wins"] + combined["losses"] + combined["ties"]
    )

    combined = add_missing_columns(combined)
    combined = combined[FINAL_COLUMNS]

    os.makedirs("data/cleaned", exist_ok=True)
    combined.to_csv(OUT_FILE, index=False)

    print(f"Created {OUT_FILE}")
    print(f"Rows: {len(combined)}")
    print(combined[["team", "year", "wins", "losses", "ties", "win_pct"]].head())


if __name__ == "__main__":
    main()