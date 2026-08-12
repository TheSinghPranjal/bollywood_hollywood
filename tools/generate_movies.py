#!/usr/bin/env python3
"""Generate assets/data/movies.json with 500 Bollywood + 500 Hollywood movies.

Curated source data lives in tools/movie_catalog.json (title, year, cast, genre, plot).
This script selects era-balanced subsets, builds about/hints, validates, and writes JSON.
"""

from __future__ import annotations

import json
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = Path(__file__).resolve().parent / "movie_catalog.json"
OUT = ROOT / "assets" / "data" / "movies.json"

STOPWORDS = {
    "a", "an", "the", "of", "in", "on", "at", "to", "for", "and", "or", "but",
    "with", "from", "by", "is", "it", "as", "into", "about", "over", "under",
    "my", "your", "our", "their", "his", "her", "its", "me", "we", "you", "be",
    "are", "was", "were", "this", "that", "these", "those", "not", "no", "yes",
    "up", "down", "out", "off", "all", "so", "if", "than", "then", "too", "very",
    "just", "only", "also", "can", "will", "do", "does", "did", "have", "has",
    "had", "who", "what", "when", "where", "why", "how", "le", "la", "les", "des",
    "du", "de", "el", "los", "las", "un", "une", "na", "ki", "ka", "ke", "se",
    "hai", "ho", "ko", "ne", "aur", "ek", "vs", "vol", "part", "chapter", "episode",
    "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
}

WORD_RE = re.compile(r"[A-Za-z]+")
DIGIT_RE = re.compile(r"\d")

QUOTAS = {
    "bollywood": {
        "1990-1999": 60,
        "2000-2009": 160,
        "2010-2019": 190,
        "2020-2026": 90,
    },
    "hollywood": {
        "1990-1999": 60,
        "2000-2009": 140,
        "2010-2019": 190,
        "2020-2026": 110,
    },
}

# Prefer recognizable titles when trimming era buckets.
PRIORITY = {
    t.casefold()
    for t in [
        # Bollywood
        "Dilwale Dulhania Le Jayenge", "Kuch Kuch Hota Hai", "Lagaan", "Dil Chahta Hai",
        "Kal Ho Naa Ho", "Veer-Zaara", "Rang De Basanti", "Jab We Met", "Rockstar",
        "Zindagi Na Milegi Dobara", "Barfi", "Yeh Jawaani Hai Deewani", "Queen", "PK",
        "Bajrangi Bhaijaan", "Dangal", "Andhadhun", "Gully Boy", "Pathaan", "Jawan",
        "Saiyaara", "Laapataa Ladies", "Taare Zameen Par", "Swades", "Munna Bhai M.B.B.S.",
        "Lage Raho Munna Bhai", "Chak De India", "Om Shanti Om", "Ghajini", "3 Idiots",
        "Wake Up Sid", "Love Aaj Kal", "Dev D", "Kahaani", "Gangs of Wasseypur",
        "English Vinglish", "Haider", "Bajirao Mastani", "Pink", "Udta Punjab", "Raazi",
        "Stree", "Article 15", "Uri: The Surgical Strike", "Tanhaji", "Shershaah",
        "Gangubai Kathiawadi", "Animal", "Rocky Aur Rani Kii Prem Kahaani", "Dunki",
        "12th Fail", "Chhaava", "Sky Force", "Fighter", "Kill", "Crew", "Shaitaan",
        "Baahubali", "Kabhi Khushi Kabhie Gham", "Mohabbatein", "Hum Aapke Hain Koun",
        "Border", "Sarfarosh", "Satya", "Company", "Black", "Don", "Guru", "Jaane Tu Ya Jaane Na",
        "Rab Ne Bana Di Jodi", "My Name Is Khan", "Dabangg", "Singham Returns", "Barfi",
        "Vicky Donor", "Piku", "Masaan", "Newton", "Badhaai Ho", "Super 30", "Chhichhore",
        "Tumbbad", "Mimi", "Jersey", "Drishyam", "Brahmastra", "Jigra", "Merry Christmas",
        # Hollywood
        "Titanic", "The Matrix", "Gladiator", "Inception", "Interstellar", "Avatar",
        "The Dark Knight", "Iron Man", "Black Panther", "Oppenheimer", "Barbie", "Dune",
        "Top Gun: Maverick", "La La Land", "Get Out", "Frozen", "Inside Out", "The Batman",
        "Forrest Gump", "Pulp Fiction", "The Shawshank Redemption", "Jurassic Park",
        "The Lion King", "Fight Club", "The Sixth Sense", "American Beauty", "Saving Private Ryan",
        "The Lord of the Rings: The Fellowship of the Ring", "Shrek", "Spider-Man",
        "Pirates of the Caribbean: The Curse of the Black Pearl", "Finding Nemo",
        "The Incredibles", "Batman Begins", "Casino Royale", "No Country for Old Men",
        "Wall-E", "Up", "The Social Network", "Toy Story", "The Avengers", "Gravity",
        "Her", "Whiplash", "Mad Max: Fury Road", "The Martian", "Deadpool", "Wonder Woman",
        "Coco", "A Quiet Place", "Parasite", "Joker", "Knives Out", "Soul", "Dune: Part Two",
        "Everything Everywhere All at Once", "Spider-Man: No Way Home", "The Whale",
        "Guardians of the Galaxy", "John Wick", "Mission: Impossible – Fallout",
        "Blade Runner", "Bohemian Rhapsody", "A Star Is Born", "Once Upon a Time in Hollywood",
        "Tenet", "Nomadland", "CODA", "Don't Look Up", "Elvis", "Nope", "The Fabelmans",
        "Avatar: The Way of Water", "Poor Things", "Killers of the Flower Moon", "Wonka",
        "Wicked", "Anora", "Conclave", "The Substance", "Challengers", "Civil War",
        "Deadpool and Wolverine", "Alien: Romulus", "The Wild Robot", "Nosferatu",
        "Furiosa: A Mad Max Saga", "Mickey Seventeen", "Superman", "F1", "Sinners",
    ]
}


def era_for(year: int) -> str:
    if year < 2000:
        return "1990-1999"
    if year < 2010:
        return "2000-2009"
    if year < 2020:
        return "2010-2019"
    return "2020-2026"


def title_words(title: str) -> set[str]:
    words = {w.lower() for w in WORD_RE.findall(title)}
    return {w for w in words if w not in STOPWORDS and len(w) > 2}


def cast_phrase(cast: list[str]) -> str:
    if len(cast) == 1:
        return cast[0]
    if len(cast) == 2:
        return f"{cast[0]} and {cast[1]}"
    return f"{', '.join(cast[:-1])} and {cast[-1]}"


def cast_name_words(cast: list[str]) -> set[str]:
    words: set[str] = set()
    for name in cast:
        words.update(w.lower() for w in WORD_RE.findall(name))
    return words


def leaked_title_words(title: str, text: str, allow: set[str] | None = None) -> set[str]:
    allow = set(allow or set())
    allow.update({"bollywood", "hollywood"})
    blob = text.lower()
    leaked: set[str] = set()
    for w in title_words(title):
        if w in allow:
            continue
        if re.search(rf"\b{re.escape(w)}\b", blob):
            leaked.add(w)
    return leaked


def safe_genre(title: str, genre: str, cast: list[str]) -> str:
    allow = cast_name_words(cast)
    if not leaked_title_words(title, genre, allow=allow):
        return genre
    # Strip leaked tokens from genre phrase when possible.
    parts = []
    for token in genre.split():
        tw = token.lower().strip(",")
        if tw in title_words(title) and tw not in allow:
            continue
        parts.append(token)
    cleaned = " ".join(parts).strip() or "drama"
    return cleaned


def safe_plot(title: str, plot: str, genre: str, cast: list[str]) -> str:
    plot = plot.strip().rstrip(".")
    allow = cast_name_words(cast)
    genre = safe_genre(title, genre, cast)
    if not leaked_title_words(title, plot, allow=allow):
        return plot
    # Genre-based fallback that avoids distinctive title tokens.
    return f"A compelling story that left a lasting mark with audiences"


def make_about(plot: str) -> str:
    return f"{plot.strip().rstrip('.')}."


def make_hints(cast: list[str], plot: str, year: int, genre: str, industry: str) -> list[str]:
    ind = "Bollywood" if industry == "bollywood" else "Hollywood"
    plot = plot.strip().rstrip(".")
    return [
        f"It stars {cast_phrase(cast)}.",
        f"{plot}.",
        f"It was released in {year}.",
        f"It is a {ind} {genre}.",
    ]


def select_era_balanced(movies: list, quotas: dict[str, int]) -> list:
    buckets: dict[str, list] = defaultdict(list)
    for m in movies:
        buckets[era_for(m[1])].append(m)

    selected: list = []
    for era, need in quotas.items():
        bucket = buckets.get(era, [])
        bucket.sort(key=lambda m: (0 if m[0].casefold() in PRIORITY else 1, m[1], m[0]))
        if len(bucket) < need:
            raise RuntimeError(f"Need {need} for {era}, have {len(bucket)}")
        selected.extend(bucket[:need])
    return selected


def build_entry(raw: list, industry: str, index: int) -> dict:
    title, year, cast, genre, plot = raw
    genre = safe_genre(title, genre, cast)
    plot = safe_plot(title, plot, genre, cast)
    about = make_about(plot)
    hints = make_hints(cast, plot, year, genre, industry)
    entry = {
        "id": f"{industry}_{index:03d}",
        "title": title,
        "industry": industry,
        "year": int(year),
        "cast": list(cast),
        "about": about,
        "hints": hints,
        "era": era_for(int(year)),
    }
    validate_entry(entry)
    return entry


def validate_entry(m: dict) -> None:
    title = m["title"]
    if DIGIT_RE.search(title):
        raise ValueError(f"Digit in title: {title}")
    if not (1990 <= m["year"] <= 2026):
        raise ValueError(f"Bad year for {title}: {m['year']}")
    if not (2 <= len(m["cast"]) <= 4):
        raise ValueError(f"Cast size for {title}: {m['cast']}")
    if len(m["hints"]) != 4:
        raise ValueError(f"Hints != 4 for {title}")
    # Cast hint may legally contain shared surname tokens (e.g. Singh).
    allow = cast_name_words(m["cast"])
    # Full title string must never appear as a whole phrase/word.
    # Skip ultra-short / stopword titles ("It", "Her", "Up") — those appear in normal English.
    full = title.strip()
    full_key = full.casefold()
    if len(full) >= 3 and full_key not in STOPWORDS:
        for text in m["hints"] + [m["about"]]:
            if re.search(rf"(?i)(?<![A-Za-z]){re.escape(full)}(?![A-Za-z])", text):
                raise ValueError(f"Full title leaked for {title}")
    # Distinctive title words must not appear outside allowed cast-name overlaps.
    non_cast_blob = " ".join([m["about"], m["hints"][1], m["hints"][2], m["hints"][3]])
    leaked = leaked_title_words(title, non_cast_blob, allow=allow)
    if leaked:
        raise ValueError(f"Title word(s) {sorted(leaked)} leaked for {title}")
    if m["era"] != era_for(m["year"]):
        raise ValueError(f"Era mismatch for {title}")


def main() -> int:
    if not CATALOG.exists():
        print(f"Missing catalog: {CATALOG}", file=sys.stderr)
        return 1

    catalog = json.loads(CATALOG.read_text())
    movies_out: list[dict] = []

    for industry in ("bollywood", "hollywood"):
        raw_list = catalog[industry]
        # Pre-filter hard rules
        cleaned = []
        seen = set()
        for row in raw_list:
            title, year, cast, genre, plot = row
            if DIGIT_RE.search(title):
                continue
            if not (1990 <= int(year) <= 2025):
                continue
            if not (2 <= len(cast) <= 4):
                continue
            key = title.casefold()
            if key in seen:
                continue
            seen.add(key)
            cleaned.append([title, int(year), list(cast), genre, plot])

        chosen = select_era_balanced(cleaned, QUOTAS[industry])
        # Stable order within industry: by year then title, then assign IDs
        chosen.sort(key=lambda m: (m[1], m[0].casefold()))
        for i, raw in enumerate(chosen, start=1):
            movies_out.append(build_entry(raw, industry, i))

    # Global duplicate titles within industry already enforced; also ensure exact counts
    by_ind = Counter(m["industry"] for m in movies_out)
    if by_ind["bollywood"] != 500 or by_ind["hollywood"] != 500:
        raise RuntimeError(f"Count mismatch: {dict(by_ind)}")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps({"movies": movies_out}, indent=2, ensure_ascii=False) + "\n")

    print(f"Wrote {OUT}")
    print(f"Total movies: {len(movies_out)}")
    for industry in ("bollywood", "hollywood"):
        subset = [m for m in movies_out if m["industry"] == industry]
        eras = Counter(m["era"] for m in subset)
        print(f"\n{industry}: {len(subset)}")
        for era in ("1990-1999", "2000-2009", "2010-2019", "2020-2026"):
            print(f"  {era}: {eras[era]}")

    # Extra sanity
    for industry in ("bollywood", "hollywood"):
        titles = [m["title"].casefold() for m in movies_out if m["industry"] == industry]
        if len(titles) != len(set(titles)):
            raise RuntimeError(f"Duplicate titles in {industry}")
        ids = [m["id"] for m in movies_out if m["industry"] == industry]
        expected = [f"{industry}_{i:03d}" for i in range(1, 501)]
        if ids != expected:
            raise RuntimeError(f"ID sequence mismatch for {industry}")

    print("\nValidation: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
