#!/usr/bin/env python3
"""Build frequency dictionary combining Bible and zomidaily data.

Reads Bible word frequencies and zomidaily word frequencies, combines them,
and creates a comprehensive frequency dictionary.
"""

import json
from pathlib import Path

# Paths
DATA_DIR = Path("/home/peter/Documents/Projects/zolai-ai/data")
BIBLE_FREQ_PATH = DATA_DIR / "bible/ALL_WORDS_WITH_FREQUENCY.jsonl"
ZOMIDAILY_FREQ_PATH = DATA_DIR / "raw/zomidaily/vocabulary/words_frequency.jsonl"
MASTER_DICT_PATH = DATA_DIR / "dictionary/processed/dict_zo_en_master_v1.jsonl"
OUTPUT_PATH = Path("/home/peter/Documents/Projects/zolai-ai/zolai-wiki/vocabulary/frequency_dictionary.md")


def load_jsonl(path: Path) -> list[dict]:
    """Load JSONL file."""
    data = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                data.append(json.loads(line))
    return data


def build_dict_index(dict_data: list[dict]) -> dict[str, str]:
    """Build index of English translations."""
    index = {}
    for entry in dict_data:
        word = entry.get("zolai", "").strip().lower()
        en = entry.get("english_clean", "")
        if word and en and word not in index:
            index[word] = en
    return index


def infer_pos(word: str) -> str:
    """Simple POS inference."""
    particles = {
        "hi", "hen", "un", "in", "vo", "lo", "kei", "hiam", "leh",
        "tawh", "ah", "te", "pen", "na", "ki", "ci", "hong", "va",
        "khia", "lut", "kik", "ta", "zo", "khin", "lai", "ding",
        "ka", "a", "i", "ki", "kami", "nang", "amah", "mahmah",
    }
    if word in particles or len(word) <= 2:
        return "particle"
    if word.endswith(("na", "tak")):
        return "noun"
    if word.endswith(("hi", "ta", "zo", "ding")):
        return "verb"
    return "noun"


def build_frequency_dict(top_n: int = 1000) -> None:
    """Build frequency dictionary."""
    # Load data
    bible_freq = load_jsonl(BIBLE_FREQ_PATH)
    zomidaily_freq = load_jsonl(ZOMIDAILY_FREQ_PATH)
    master_dict = load_jsonl(MASTER_DICT_PATH)

    print(f"Loaded {len(bible_freq)} Bible words")
    print(f"Loaded {len(zomidaily_freq)} zomidaily words")
    print(f"Loaded {len(master_dict)} dictionary entries")

    # Build dictionary index
    dict_index = build_dict_index(master_dict)
    print(f"Dictionary index: {len(dict_index)} entries")

    # Build Bible frequency index
    bible_index = {}
    for entry in bible_freq:
        word = entry.get("word", "").strip().lower()
        freq = entry.get("frequency", 0)
        if word and freq > 0:
            bible_index[word] = freq

    # Build zomidaily frequency index
    zomidaily_index = {}
    for entry in zomidaily_freq:
        word = entry.get("word", "").strip().lower()
        count = entry.get("count", 0)
        if word and count > 0:
            zomidaily_index[word] = count

    print(f"Bible words with frequency: {len(bible_index)}")
    print(f"Zomidaily words with frequency: {len(zomidaily_index)}")

    # Combine frequencies
    combined = {}
    for word in set(list(bible_index.keys()) + list(zomidaily_index.keys())):
        bible_f = bible_index.get(word, 0)
        modern_f = zomidaily_index.get(word, 0)
        total = bible_f + modern_f
        if total > 0:
            combined[word] = {
                "zo": word,
                "bible_freq": bible_f,
                "modern_freq": modern_f,
                "total": total,
            }

    # Sort by total frequency
    sorted_words = sorted(combined.values(), key=lambda x: x["total"], reverse=True)[:top_n]

    # Add English translations and POS
    for entry in sorted_words:
        word = entry["zo"]
        en = dict_index.get(word, "")
        if not en:
            # Try to find partial match
            for key, val in dict_index.items():
                if word in key or key in word:
                    en = val
                    break
        if not en:
            en = f"[to be translated]"
        entry["en"] = en
        entry["pos"] = infer_pos(word)

    # Generate markdown
    lines = []
    lines.append("# Zolai Frequency Dictionary")
    lines.append("")
    lines.append("## Overview")
    lines.append("")
    lines.append(f"- **Total words:** {len(sorted_words)}")
    lines.append("- **Sources:** Bible (31,102 verses) + Zomidaily (12,966 articles)")
    lines.append("- **Format:** Rank | Zolai | English | Bible Freq | Modern Freq | Total")
    lines.append("- **Date:** 2026-09-10")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## Top 1000 Most Frequent Zolai Words")
    lines.append("")
    lines.append("| Rank | Zolai | English | Bible Freq | Modern Freq | Total | POS |")
    lines.append("|------|-------|---------|------------|-------------|-------|-----|")

    for i, entry in enumerate(sorted_words, 1):
        lines.append(
            f"| {i} | {entry['zo']} | {entry['en']} | {entry['bible_freq']:,} | {entry['modern_freq']:,} | {entry['total']:,} | {entry['pos']} |"
        )

    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## Frequency Distribution")
    lines.append("")

    # Count by POS
    pos_counts = {}
    for entry in sorted_words:
        pos = entry["pos"]
        pos_counts[pos] = pos_counts.get(pos, 0) + 1

    lines.append("| POS | Count | Percentage |")
    lines.append("|-----|-------|------------|")
    for pos, count in sorted(pos_counts.items(), key=lambda x: x[1], reverse=True):
        pct = count / len(sorted_words) * 100
        lines.append(f"| {pos} | {count} | {pct:.1f}% |")

    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## Top 50 by Bible Frequency")
    lines.append("")
    lines.append("| Rank | Zolai | English | Bible Freq |")
    lines.append("|------|-------|---------|------------|")

    bible_sorted = sorted(sorted_words, key=lambda x: x["bible_freq"], reverse=True)[:50]
    for i, entry in enumerate(bible_sorted, 1):
        lines.append(
            f"| {i} | {entry['zo']} | {entry['en']} | {entry['bible_freq']:,} |"
        )

    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## Top 50 by Modern Frequency")
    lines.append("")
    lines.append("| Rank | Zolai | English | Modern Freq |")
    lines.append("|------|-------|---------|-------------|")

    modern_sorted = sorted(sorted_words, key=lambda x: x["modern_freq"], reverse=True)[:50]
    for i, entry in enumerate(modern_sorted, 1):
        lines.append(
            f"| {i} | {entry['zo']} | {entry['en']} | {entry['modern_freq']:,} |"
        )

    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## Example Sentences (Top 20)")
    lines.append("")

    example_sentences = [
        ("hi", "be/exist", "Ka om hi. (I exist.)"),
        ("in", "[ergative]", "Pasian in piangsak hi. (God created.)"),
        ("ding", "[future]", "Ka pai ding hi. (I will go.)"),
        ("leh", "and/with", "Ka leh na. (I and you.)"),
        ("ah", "[emphasis]", "Ka ah hi. (It is I.)"),
        ("hong", "come/arrive", "A hong hi. (He comes.)"),
        ("na", "[possessive]", "Na kam. (Your word.)"),
        ("pen", "is/are", "Tua pen ka kam. (That is my word.)"),
        ("tawh", "together", "Tawh ka pai hi. (Together we go.)"),
        ("khat", "one", "Mi khat. (One person.)"),
        ("ka", "I/me", "Ka pai hi. (I go.)"),
        ("zong", "help", "Ka zong hi. (I help.)"),
        ("tua", "that", "Tua ka gen hi. (That I know.)"),
        ("ci", "say", "A ci hi. (He says.)"),
        ("om", "exist/be", "Ka om hi. (I exist.)"),
        ("lo", "[negation]", "Pai lo hi. (Goes not.)"),
        ("ki", "[reflexive]", "Ki pai hi. (Themselves go.)"),
        ("thei", "know", "Ka thei hi. (I know.)"),
        ("ahih", "but/however", "Ahih ka pai hi. (But I go.)"),
        ("mahmah", "very/greatly", "Mahmah pi hi. (Very good.)"),
    ]

    for word, en, example in example_sentences:
        lines.append(f"- **{word}** ({en}): {example}")

    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## Notes")
    lines.append("")
    lines.append("1. **Bible frequency** counts occurrences across all 66 books (31,102 verses)")
    lines.append("2. **Modern frequency** counts occurrences in zomidaily.com articles (12,966 articles)")
    lines.append("3. **Total** is the sum of Bible and Modern frequencies")
    lines.append("4. Words appearing in both sources indicate established vocabulary")
    lines.append("5. High modern frequency but low Bible frequency may indicate loan words or new coinages")
    lines.append("6. High Bible frequency but low modern frequency may indicate archaic or religious vocabulary")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("*Generated from Bible + zomidaily corpus analysis*")

    # Write output
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    print(f"\nOutput written to: {OUTPUT_PATH}")
    print(f"Total words: {len(sorted_words)}")


if __name__ == "__main__":
    build_frequency_dict(top_n=1000)
