# Zolai Language Knowledge Base for ChatGPT
## Last Updated: 2026-09-11

## Quick Start
Copy this entire document into ChatGPT custom instructions for accurate Zolai translation.

---

## Critical Grammar Rules (ZVS 2018)

### Word Order — SOV (Subject–Object–Verb)
- Agreement markers (ka/na/a) ALWAYS come DIRECTLY before the verb
- Adverbs (mahmah) come AFTER the verb, BEFORE hi
- Verb always comes last

**Correct:** `Amaute a siam mahmah hi.` (They are very good)
**Wrong:** `Amaute mahmah siam ahi.`

### Negation
- `kei` = standard negation for ALL persons (1st, 2nd, 3rd)
- `lo` = literary/formal negation (standalone, NO agreement marker)
- `lo` does NOT take `a` agreement: ❌ `A pai lo hi` → ✅ `Pai lo hi`

**Correct:** `Ka pai kei hi.` (I don't go)
**Correct:** `Na pai kei hi.` (You don't go)
**Correct:** `A pai kei hi.` (He doesn't go)

### Questions
- `hiam` = yes/no question marker at end of sentence
- `bang hang` = content question (why/how)
- `bang` = what, `kua` = where

**Correct:** `Na ne hiam?` (Do you eat?)
**Wrong:** `Na nek hiam?` (nek = specific eating)

### Tense & Aspect
- `khin` = past simple / experiential (completed past action)
- `ta` = completive/realized aspect (action completed in the moment)
- `ding` = future marker
- `zo` = completive (action fully finished)
- `lai` = progressive (in the middle of)

**Correct:** `A pai khin hi.` (He went.)
**Correct:** `Na dam ta in.` (Be healed now.)
**Wrong:** `A pai ta hi.` (ta is NOT past simple!)

---

## 22 Bible-Verified Word Corrections

### Pronouns
| Word | Correct Meaning | Wrong Meaning | Bible Reference |
|------|-----------------|---------------|-----------------|
| `hihte` | they (respectful/older) | — | 1CH 1:23 |
| `amaute` | they (standard) | — | 1CH 2:23 |
| `huate` | those/them (demonstrative) | — | 1CH 4:23 |
| `u` | elder brother/sister | they | 1JN 2:9 |
| `nau` | younger brother/sister | younger | 1CO 1:10 |
| `uh` | plural marker (NOT "they"!) | they | GEN 1:2 |

### Eating Verbs
| Word | Correct Meaning | Wrong Meaning | Bible Reference |
|------|-----------------|---------------|-----------------|
| `ne` | general eating/drinking | — | 1CH 12:39 |
| `nek` | specific/conditional eating | eat | 1CO 8:4 |

**Note:** "Do you eat?" = `Na ne hiam?` (use `ne`, NOT `nek`)

### Work Nouns
| Word | Correct Meaning | Wrong Meaning | Bible Reference |
|------|-----------------|---------------|-----------------|
| `nasep` | work/service | deed | 1CH 6:31-33 |
| `kammal` | deed/action/commandment | work | 1CH 16:15 |

**Note:** "The work is done" = `Nasep a mankhin ta hi`

### Tree vs Wood
| Word | Correct Meaning | Wrong Meaning | Bible Reference |
|------|-----------------|---------------|-----------------|
| `sing` | wood (material) | tree | GEN 6:14 |
| `singkung` | tree (living plant) | — | — |

### Verb: lasak (Polysemous)
| Word | Meaning 1 | Meaning 2 | Bible Reference |
|------|-----------|-----------|-----------------|
| `lasak` | sing/song | take something | 1CH 6:31-32 |

**Note:** Context determines meaning.

### Particles & Connectors
| Word | Correct Meaning | Wrong Meaning | Bible Reference |
|------|-----------------|---------------|-----------------|
| `in` | ergative marker (agent of transitive) | ! (imperative) | GEN 1:1 |
| `leh` | and (conjunction) | return to, reciprocate | GEN 1:3 |
| `na` | possessive particle (your/my), quotative | new, fresh | GEN 3:15 |
| `kei` | negation "not" (ALL persons), OR "I/me" | — | GEN 4:7 |
| `tawh` | with (comitative), key, free-hand | — | GEN 4:1 |
| `ahi` | copula is/am/are/was (context-dependent) | — | GEN 1:2 |
| `ci` | say/speak/tell (quotative verb) | — | GEN 1:3 |
| `lo` | literary negation (standalone, NO agreement) | no | GEN 4:12 |

### Tense/Aspect Words
| Word | Correct Meaning | Wrong Meaning | Bible Reference |
|------|-----------------|---------------|-----------------|
| `khin` | past simple / experiential | experiential only | 1CH 11:11 |
| `ta` | completive/realized aspect | past simple | GEN 1:31 |
| `mankhin` | truly/completed | — | EXO 39:32 |
| `kiman` | finished/completed | — | EXO 39:32 |

### Other
| Word | Correct Meaning | Wrong Meaning | Bible Reference |
|------|-----------------|---------------|-----------------|
| `siam` | good/skilled/craftsman | smooth-tongued | 1CH 5:18 |

---

## Forbidden Forms (ZVS 2018)

| Forbidden | Correct | Meaning |
|-----------|---------|---------|
| pathian | pasian | God |
| ram | gam | earth, land |
| fapa | tapa | life, son |
| bawipa | topa | Lord, master |
| siangpahrang | kumpipa | Savior |
| cu/cun | tua | that (conjunction) |
| suah | suahtakna | holiness |
| nunnak | nuntakna | life |

---

## Translation Examples (10/10 Correct)

| English | Zolai | Grammar Notes |
|---------|-------|---------------|
| He went | `A pai khin hi.` | khin = past simple |
| They went | `Amaute pai khin hi.` | amaute = they |
| Do you eat? | `Na ne hiam?` | ne = general eat, hiam = question |
| They are very good | `Amaute a siam mahmah hi.` | siam = good, mahmah = very |
| Be healed | `Na dam ta in.` | dam ta = healed (completive) |
| The work is done | `Nasep a mankhin ta hi.` | nasep = work, mankhin = completed |
| He has seen it | `A mu khin hi.` | mu = see, khin = past |
| The elder brother is good | `U a siam hi.` | u = elder brother |
| The younger sister sings | `Nau a lasak hi.` | nau = younger sister |
| They love their brother | `Amaute a u it hi.` | it = love |

---

## API Access

- **Endpoint:** `https://pcore-brain.peterlianpi.site/v1/chat/completions`
- **Auth:** `x-api-key: ***REDACTED***`
- **Task:** `task: "zolai"` selects Zolai system prompt
- **Models:** auto (mimo-v2.5-free, nemotron-3-ultra-free, etc.)

---

## Data Sources

| Source | Size | Purpose |
|--------|------|---------|
| Bible corpus | 31,649 verses | Ground truth for definitions |
| Dictionary (ZO→EN) | 84,490 entries | Zolai→English translations |
| Dictionary (EN→ZO) | 64,025 entries | English→Zolai translations |
| Vocabulary | 104,906 words | High-frequency words |
| Phrases | 10,722 multi-word | Expression database |
| Sentence patterns | 5,560 patterns | Grammar templates |

---

## How to Use This Context

1. Copy this entire document into ChatGPT custom instructions
2. Always use ZVS 2018 orthography (pasian, gam, tapa, topa)
3. Follow SOV word order with agreement before verb
4. Use `khin` for past simple, NOT `ta`
5. Use `ne` for general eating, NOT `nek`
6. Use `hihte/amaute/huate` for "they", NOT `U` or `uh`
7. Use `nasep` for work, NOT `kammal`
8. Use `singkung` for tree, NOT `sing`
