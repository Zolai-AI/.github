---
title: "Zolai Syllable Annotation Guide"
description: "Syllable annotation instructions for human annotators"
created: 2026-09-04
last_updated: 2026-09-04
status: current
category: guide
---

# Zolai Syllable Annotation Guide

## Purpose
Create a gold-standard syllable segmentation dataset for Zolai (Tedim Chin) language evaluation.

## Background
- Zolai uses (C)(C)V(C) syllable structure
- Digraphs: kh, ph, th, ng, ny, hl, hm, hn, hr, hw
- Diphthongs: aw, ai, ei, ou, ia, ua, ui
- 4 tones: T1 (high), T2 (high falling), T3 (low), T4 (creaky)
- Written Zolai does not mark tones

## Annotation Rules

### 1. Syllable Boundaries
- Each syllable must have exactly one vowel nucleus
- Onset: 0-2 consonants (including digraphs)
- Nucleus: 1 vowel or diphthong
- Coda: 0-1 consonant (k, t, p, m, n, ng, l, r)

### 2. Compound Words
- Known compounds should be segmented: `vantung` → `van tung`, `laisiangtho` → `lai siang tho`
- Proper names from Bible: `pasian` → `pa sian`, `kumpipa` → `kum pipa`

### 3. Tone Marks
- Written Zolai does NOT mark tones
- Do NOT add tone marks in annotation
- If source has tone marks, ignore them

### 4. Special Cases
- Reduplication: `mahmah` → `mah mah`, `peuhpeuh` → `peuh peuh`
- Bible names: Use standard Zolai spellings
- Loan words: Segment by Zolai phonotactics

## Annotation Format

### JSONL Format
```json
{
  "word": "vantung",
  "expected_syllable_count": 2,
  "reference_syllables": ["van", "tung"],
  "source": "bible",
  "annotated_syllables": ["van", "tung"],
  "notes": ""
}
```

### CSV Format
| word | expected_syllable_count | reference_syllables | source | annotated_syllables | notes |
|------|------------------------|---------------------|--------|---------------------|-------|
| vantung | 2 | van tung | bible | van tung | |

## How to Annotate

1. Open `data/syllable/gold_human_annotation.csv`
2. For each word:
   - Say the word aloud (use Zolai pronunciation)
   - Count the syllables
   - Write syllables in `annotated_syllables` column (space-separated)
   - Add any notes in `notes` column
3. Save the file

## Quality Checks

- Each syllable must have a vowel
- Total characters in `annotated_syllables` must equal word length
- No empty syllables
- Match reference syllable count when possible

## Priority Words (Bible/High Frequency)
These are most important for evaluation:
- Bible compounds: `laisiangtho`, `vantung`, `leitung`, `pasian`, `nuntakna`, `suahtakna`, `hehpihna`, `lungdam`, `guahzu`, `khempeuh`
- High frequency: `amaute`, `ciangin`, `hangin`, `bangin`, `panin`, `sungah`, `dingin`, `kumpipa`, `zongin`, `biakna`

## Submission
Save annotated CSV and submit for review. Multiple annotators should annotate independently for inter-annotator agreement (Cohen's kappa).
