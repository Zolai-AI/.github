# Zolai Language — Master Grammar Reference

> Comprehensive sentence-by-sentence, word-by-word, and phrase-by-phrase analysis
> of Tedim Zolai (ZVS 2018). All examples use correct ZVS 2018 orthography.
> Last updated: 2026-09-10

---

## Table of Contents

1. [Language Overview](#1-language-overview)
2. [Phonology & Writing System](#2-phonology--writing-system)
3. [Word Order — SOV](#3-word-order--sov)
4. [Pronouns & Agreement Markers](#4-pronouns--agreement-markers)
5. [Nouns & Noun Phrases](#5-nouns--noun-phrases)
6. [Verbs & Verb Phrases](#6-verbs--verb-phrases)
7. [Tense, Aspect & Mood](#7-tense-aspect--mood)
8. [Negation](#8-negation)
9. [Questions](#9-questions)
10. [Ergative Construction](#10-ergative-construction)
11. [Directional Particles](#11-directional-particles)
12. [Postpositions & Locatives](#12-postpositions--locatives)
13. [Connectors & Discourse Markers](#13-connectors--discourse-markers)
14. [Sentence Types & Patterns](#14-sentence-types--patterns)
15. [ZVS 2018 Compliance](#15-zvs-2018-compliance)
16. [RAG Integration](#16-rag-integration)
17. [Glossing Conventions](#17-glossing-conventions)

---

## 1. Language Overview

### Classification

| Feature | Value |
|---------|-------|
| Language family | Sino-Tibetan → Tibeto-Burman → Kuki-Chin-Naga |
| Branch | Chin-Kuki-Mizo |
| Language name | Tedim Zolai (ZVS 2018) |
| Region | Tedim (Tiddim), Chin State, Myanmar |
| Speakers | ~500,000 (Zomi people) |
| Word order | Object–Agreement–Verb (OAV) |
| Morphology | Agglutinative (verb prefixes + suffixes) |
| Ergativity | Split ergative (ergative `in` for transitive subjects) |
| Script | Latin (ZVS 2018 orthography) |

### Key Properties

- **Object–Agreement–Verb (OAV) word order**: Object comes first, then agreement marker, then verb. Verb always comes last.
- **Head-final**: Modifiers precede heads
- **Postpositional**: Prepositions do NOT exist
- **Agglutinative**: Verbs built from stems + directional particles
- **Split ergative**: Transitive subjects take `in` marker
- **No grammatical gender**: `amah` = he/she/it
- **Rich particle system**: 50+ sentence-final particles for mood/evidentiality

---

## 2. Phonology & Writing System

### Consonants

| Letter | IPA | Example | Meaning |
|--------|-----|---------|---------|
| `p` | /p/ | `pau` | speak |
| `t` | /t/ | `tui` | water |
| `k` | /k/ | `kha` | spirit |
| `m` | /m/ | `mi` | person |
| `n` | /n/ | `ni` | day/sun |
| `ng` | /ŋ/ | `nga` | five |
| `s` | /s/ | `sing` | tree |
| `z` | /z/ | `zat` | use |
| `l` | /l/ | `lam` | way |
| `h` | /h/ | `hi` | declarative |
| `b` | /b/ | `bawl` | create |
| `d` | /d/ | `dam` | well |
| `g` | /g/ | `gam` | land |
| `c` | /ts/ | `ciangin` | then |

### Vowels

| Letter | IPA | Example | Meaning |
|--------|-----|---------|---------|
| `a` | /a/ | `an` | rice/food |
| `e` | /e/ | `eite` | we/us |
| `i` | /i/ | `inn` | house |
| `o` | /o/ | `om` | exist/be |
| `u` | /u/ | `uh` | 3PL marker |

### Consonant Clusters (initial only)

| Cluster | IPA | Example | Meaning |
|---------|-----|---------|---------|
| `kh` | /x/ or /kʰ/ | `khua` | village |
| `th` | /tʰ/ | `thu` | word/matter |
| `ph` | /pʰ/ | `phung` | clan/custom |

### Final Consonants (8 permitted)

`-p, -t, -k, -m, -n, -ng, -l, -h`

### Tone

Zolai has a **phonemic tone** system with 4 tones:

| Tone | Mark | Example | Meaning |
|------|------|---------|---------|
| High | acute (á) | `má` | — |
| Mid | unmarked | `ma` | — |
| Low | grave (à) | `mà` | — |
| Rising | circumflex (â) | `mâ` | — |

**Note:** In ZVS 2018, tone marks are often omitted in casual writing but are critical for minimal pairs.

---

## 3. Word Order

### Simple Sentences: Object First (OSV)

In simple transitive sentences, the **object comes first**, followed by the agreement marker, then the verb.

**Key rule:** The agreement marker (ka, na, a, i, ko) always comes directly before the verb.

```
Gam ka mu hi.        "I see the land." ✅
Ka gam ka mu hi.     "I see my land." ✅
Ka gam mu hi.        WRONG ❌
```

| Pattern | Example | Translation |
|---------|---------|-------------|
| O + A + V | `Gam ka mu hi.` | I see the land. |
| POSS + O + A + V | `Ka gam ka mu hi.` | I see my land. |
| S + ERG + O + A + V | `Pasian in vantung leh leitung a piangsak hi.` | God created heaven and earth. |

### Intransitive Sentences: Agreement First

When there is **no object** (intransitive verb), the agreement marker comes first.

| Pattern | Example | Translation |
|---------|---------|-------------|
| A + V | `Pai ka hi.` | I go. |
| A + V + FUT | `Pai ka ding hi.` | I will go. |
| A + V + NEG | `Pai ka kei hi.` | I don't go. |
| A + V + Q | `Pai na hiam?` | Do you go? |
| A + V + NEG + FUT | `Pai ka kei ding hi.` | I will not go. |
| V + NEG (literary) | `Pai lo ding.` | Will not go. |

### Complex Sentences: Flexible Word Order

In complex sentences with multiple clauses, word order can be more flexible. Both orders may appear:

```
Mipa kiang a a theihna ding in a pai pih hi.     ✅
A theihna ding in mipa kiang ah a pai pih hi.     ✅
```

Both mean: "He went to the man to know."

### Possessive + Object + Agreement + Verb

When using possessives, the possessive marker comes before the object, and the agreement marker comes before the verb:

| Pattern | Example | Translation |
|---------|---------|-------------|
| POSS + O + A + V | `Ka gam na mu hi.` | You see my land. |
| POSS + O + A + V | `Ka gam ka mu hi.` | I see my land. |
| POSS + O + A + V | `Na gam ka mu hi.` | I see your land. |
| POSS + O + A + V | `A gam ka mu hi.` | I see his/her land. |

**Key:** The same markers (ka, na, a) serve dual functions:
- **Before noun** = possessive (my/your/his/her)
- **Before verb** = agreement marker (I/you/he/she)

### ⚠️ WRONG Patterns

| Wrong | Correct | Why |
|-------|---------|-----|
| `Ka gam mu hi.` | `Gam ka mu hi.` | Object must come before agreement |
| `Na gam mu hi.` | `Gam na mu hi.` | Object must come before agreement |
| `A gam mu hi.` | `Gam a mu hi.` | Object must come before agreement |

#### Sentence-by-Sentence Analysis

**Example 1: Basic Transitive**

```
Gam ka mu hi.
```

| Word | Gloss | Function |
|------|-------|----------|
| gam | land | Direct object |
| ka | 1SG.AGR | Subject agreement marker |
| mu | see | Verb |
| hi | DECL | Declarative particle |

**Translation:** "I see the land."

**Word-by-word breakdown:**
- `gam` — noun, "land/earth." ZVS 2018 standard (NOT `ram`).
- `Ka` — 1st person singular agreement marker (pronoun prefix). Replaces full pronoun `kei` (I).
- `mu` — verb stem, "see."
- `hi` — sentence-final particle marking declarative mood.

---

**Example 2: Transitive with ergative (full form)**

```
Pasian in vantung leh leitung a piangsak hi.
```

| Word | Gloss | Function |
|------|-------|----------|
| Pasian | God | Subject (proper noun) |
| in | ERG | Ergative marker |
| vantung | heaven | Direct object 1 |
| leh | and | Conjunction |
| leitung | earth | Direct object 2 |
| a | 3SG.AGR | Agreement marker |
| piangsak | create | Verb |
| hi | DECL | Declarative particle |

**Translation:** "God created the heaven and earth."

**Word-by-word breakdown:**
- `Pasian` — proper noun, "God." ZVS 2018 standard (NOT `Pathian`).
- `in` — ergative marker. Used when the subject is a transitive agent performing an action on an object.
- `vantung` — noun, "heaven/sky."
- `leh` — coordinating conjunction, "and."
- `leitung` — noun, "earth/land."
- `a` — 3rd person singular agreement marker.
- `piangsak` — verb, "create/make." ZVS 2018 standard (NOT `bawl` in all contexts).
- `hi` — declarative sentence-final particle.

---

**Example 3: Negation**

```
Pai ka kei hi.
```

| Word | Gloss | Function |
|------|-------|----------|
| pai | go | Verb |
| ka | 1SG.AGR | Subject agreement |
| kei | NEG | Negation particle |
| hi | DECL | Declarative particle |

**Translation:** "I don't go."

**Word-by-word breakdown:**
- `pai` — verb stem, "go."
- `Ka` — 1st person singular agreement marker.
- `kei` — negation particle. Standard for ALL persons (NOT `lo`).
- `hi` — declarative particle.

---

**Example 4: Question**

```
Pai na hiam?
```

| Word | Gloss | Function |
|------|-------|----------|
| pai | go | Verb |
| na | 2SG.AGR | Subject agreement |
| hiam | Q | Question particle |

**Translation:** "Do you go?"

**Word-by-word breakdown:**
- `pai` — verb stem, "go."
- `Na` — 2nd person singular agreement marker.
- `hiam` — universal question particle. Replaces `ze` (which is emphatic, NOT a question marker).

---

**Example 5: Future tense**

```
Pai ka ding hi.
```

| Word | Gloss | Function |
|------|-------|----------|
| pai | go | Verb |
| ka | 1SG.AGR | Subject agreement |
| ding | FUT | Future marker |
| hi | DECL | Declarative particle |

**Translation:** "I will go."

**Word-by-word breakdown:**
- `pai` — verb stem, "go."
- `Ka` — 1st person singular agreement marker.
- `ding` — future aspect marker.
- `hi` — declarative particle.

---

**Example 6: Compound verb**

```
Laisiangtho hawmkhia ding.
```

| Word | Gloss | Function |
|------|-------|----------|
| Laisiangtho | Bible | Noun (compound) |
| hawmkhia | print+publish | Compound verb |
| ding | FUT | Future marker |

**Translation:** "The Bible will be published."

**Word-by-word breakdown:**
- `Laisiangtho` — compound noun: `lai` (book/text/document) + `siang` (clean/holy) + `tho` (suffix) = "Bible."
- `hawmkhia` — compound verb: `hawm` (print) + `khia` (go out/publish) = "publish."
- `ding` — future aspect marker.

---

**Example 7: Possessive**

```
Ka gam ka mu hi.
```

| Word | Gloss | Function |
|------|-------|----------|
| ka | 1SG.POSS | Possessive marker |
| gam | land | Direct object |
| ka | 1SG.AGR | Subject agreement marker |
| mu | see | Verb |
| hi | DECL | Declarative particle |

**Translation:** "I see my land."

**Word-by-word breakdown:**
- `ka` — 1st person singular possessive marker (before noun).
- `gam` — noun, "land/earth."
- `ka` — 1st person singular agreement marker.
- `mu` — verb stem, "see."
- `hi` — declarative particle.

---

### Sentence Templates

**Object always comes before agreement marker in transitive sentences.**

| Template | Example | Translation |
|----------|---------|-------------|
| O + A + V | `Gam ka mu hi.` | I see the land. |
| POSS + O + A + V | `Ka gam ka mu hi.` | I see my land. |
| S + ERG + O + A + V | `Pasian in vantung leh leitung a piangsak hi.` | God created heaven and earth. |
| V + A + NEG | `Pai ka kei hi.` | I don't go. |
| V + A + Q | `Pai na hiam?` | Do you go? |
| V + A + FUT | `Pai ka ding hi.` | I will go. |
| V + A + NEG + FUT | `Pai ka kei ding hi.` | I will not go. |
| O + A + V + FUT | `Gam ka pai ding hi.` | I will see the land. |
| PASSIVE | `Bu 1,000 kibawl hi.` | 1,000 copies were made. |
| DATE + V | `1914 kumin Mate zo hi.` | In 1914, Matthew was completed. |

**⚠️ WRONG:** `Ka gam mu hi` is NOT correct. Never put agreement marker before object in transitive sentences.

### Passive Constructions

Zolai uses `ki-` (REFL) prefix for passive voice when the agent is omitted:

| Pattern | Example | Translation |
|---------|---------|-------------|
| `ki-[verb] + hi` | `bu 1,000 kibawl hi` | 1,000 copies were made |
| `ki-[verb] + hi` | `India pan khenkik hi` | Was reprinted from India |
| `ki-[verb] + hi` | `Thuciam Lui a kigawm hi` | New Testament was combined |
| `ki-[verb] + hi` | `khetkik dingin kikhensat hi` | Was decided to reprint |
| `ki-[verb] + hi` | `ci-in kiciamteh hi` | Is acknowledged for that |
| `ki-[verb] + hi` | `a kiletkhia ahi hi` | It was translated |

**Agent with ergative:** `[Agent] + in + [Object] + [verb] + hi`
```
BFBS in ABFMS' phalna tawh India pan khenkik hi.
[BFBS] [ERG] [ABFMS] [permission-with] [India] [from] [reprint] [DECL]
"BFBS, with ABFMS permission, reprinted from India."
```

### Date Constructions

| Pattern | Example | Translation |
|---------|---------|-------------|
| `[year] kumin` | `1914 kumin` | in 1914 |
| `[year] kum ciangin` | `1967 kum ciangin` | after 1967 |
| `[year] kum panin` | `1972 kum panin` | from 1972 |
| `[year] kuma` | `1960 kuma` | in that year 1960 |
| `Zani + [day] + [month] + [year] + in` | `Zani 1 September 2026 in` | on 1 September 2026 |

---

## 4. Pronouns & Agreement Markers

### Subject Pronouns

| Person | Pronoun | Agreement Marker | Example | Translation |
|--------|---------|------------------|---------|-------------|
| 1SG | `kei` | `ka` | `Pai ka hi.` | I go. |
| 2SG | `nang` | `na` | `Pai na hi.` | You go. |
| 3SG | `amah` | `a` | `Pai a hi.` | He/she goes. |
| 1PL.INCL | `eite` | `i` | `Pai i hi.` | We (all) go. |
| 1PL.EXCL | `kote` | `ko` | `Pai ko hi.` | We (not you) go. |
| 2PL | `note` | `na` | `Pai na hi.` | You (all) go. |
| 3PL | `amaute` | `a` | `Amaute pai hi.` | They go. (standard) |
| 3PL | `hihte` | `a` | `Hihte pai hi.` | They go. (respectful/older) |
| 3PL | `huate` | `a` | `Huate pai hi.` | Those go. (demonstrative) |

### Family Terms (Elder/Younger)

| Term | Meaning | Bible Reference |
|------|---------|-----------------|
| `u` | elder brother/sister | 1JN 2:9: a u a nau = his brother |
| `nau` | younger brother/sister | 1CO 1:10: ute naute = brothers |
| `ute` | brothers (plural) | 1CO 1:10: 5,163x in Bible |
| `naute` | younger siblings (plural) | 1CO 1:11: 177x in Bible |

### Plural Marker

| Marker | Function | Example |
|--------|----------|---------|
| `uh` | Plural marker (NOT "they"!) | mi+te+uh = people-PL-PL |

**Note:** `uh` is a plural marker, NOT a standalone pronoun. Use `hihte/amaute/huate` for "they".

### Word-by-Word Analysis: Agreement Markers

**`ka` (1st person singular):**

```
Pai ka hi.          I go.
Pa ka               My father (possessive)
Inn ka              My house
It mahmah ka hi.    I love very much.
```

| Example | Breakdown |
|---------|-----------|
| `Pai ka hi.` | pai=go + ka=1SG.AGR + hi=DECL |
| `Pa ka` | pa=father + ka=1SG.AGR (possessive use) |
| `Inn ka` | inn=house + ka=1SG.AGR (possessive use) |
| `It mahmah ka hi.` | it=love + mahmah=very + ka=1SG.AGR + hi=DECL |

**`na` (2nd person singular):**

```
Pai na hi.          You go.
Pa na               Your father
Min kua na hiam?    What is your name?
```

| Example | Breakdown |
|---------|-----------|
| `Pai na hi.` | pai=go + na=2SG.AGR + hi=DECL |
| `Pa na` | pa=father + na=2SG.AGR (possessive use) |
| `Min kua na hiam?` | min=name + kua=what + na=2SG.AGR + hiam=Q |

**`a` (3rd person singular — multi-function):**

```
Pai a hi.           He/she goes.        [subject]
Pa a                His/her father      [possession]
Hoih a hi.          It is good.         [predicate]
```

| Example | Breakdown |
|---------|-----------|
| `Pai a hi.` | pai=go + a=3SG.AGR + hi=DECL |
| `Pa a` | pa=father + a=3SG.AGR (possessive use) |
| `Hoih a hi.` | hoih=good + a=3SG.AGR + hi=DECL |

### Pronoun Drop Rule

In informal speech, subject pronouns are dropped when the agreement marker makes person clear:

| Register | Example | Translation |
|----------|---------|-------------|
| Formal | `Kei in an ne ka hi.` | I eat food. (Full form) |
| Informal | `An ne ka hi.` | I ate food. (`kei` dropped) |
| Casual | `Ne ka hi.` | I eat. (Object also dropped) |

### Emphatic Pronouns

| Form | Meaning | Example | Translation |
|------|---------|---------|-------------|
| `Kei mah` | I myself | `Kei mah hi hi.` | I AM. |
| `nang mah` | you yourself | `Nang mah na hi hiam?` | Are you yourself? |
| `Amah mah` | he/she himself | `Amah mah pai a hi.` | HE himself goes. |

### Reflexive/Reciprocal

The prefix `ki-` on verbs creates reflexive/reciprocal forms:

| Form | Example | Translation |
|------|---------|-------------|
| `ki-` + verb | `Ki mu a hi.` | He saw himself. |
| `ki-` + verb | `Nih ki mu a hi.` | They two saw each other. |

---

## 5. Nouns & Noun Phrases

### Noun Classes

| Class | Examples | Features |
|-------|----------|----------|
| Common noun | `gam` (land), `tui` (water), `mi` (person) | No articles |
| Proper noun | `Pasian` (God), `David`, `Israel` | Capitalized |
| Compound noun | `vantung` (heaven), `laisiangtho` (Bible) | No spaces |
| Collective | `mihai` (people), `ganhingte` (creatures) | Plural suffix `-te` |

### Noun Modifiers

Zolai nouns are modified by **adjectives** (pre-nominal) and **demonstratives** (pre-nominal or post-nominal):

| Pattern | Example | Translation |
|---------|---------|-------------|
| ADJ + N | `hoih gam` | good land |
| N + ADJ | `gam hoih` | good land (emphatic) |
| DET + N | `tua mi` | that person |
| N + DET | `mi tua` | that person (emphatic) |

### Possessive Construction

Possession is marked by **agreement markers** directly before the possessed noun:

| Pattern | Example | Translation |
|---------|---------|-------------|
| `ka` + N | `ka pa` | my father |
| `na` + N | `na pa` | your father |
| `a` + N | `a pa` | his/her father |
| `i` + N | `i pa` | our father |
| `amau` + N | `amau pa` | their father |

### Plural Marking

| Form | Example | Translation |
|------|---------|-------------|
| Base (singular) | `mi` | person |
| `-te` (plural) | `mite` | people |
| `-te` (plural) | `tapa` → `tapate` | sons |

---

## 6. Verbs & Verb Phrases

### Verb Structure

Zolai verbs can include:

```
[Directional] + [Verb Stem] + [Aspect/Tense] + [Sentence Particle]
```

| Component | Examples | Function |
|-----------|----------|----------|
| Directional | `hong`, `va`, `khia`, `lut`, `kik` | Movement direction |
| Verb stem | `pai`, `mu`, `ne`, `gen`, `bawl` | Core meaning |
| Aspect | `ta`, `zo`, `khin`, `lai`, `ding` | Time/aspect marking |
| Particle | `hi`, `hen`, `un`, `in`, `vo` | Mood/evidentiality |

### Verb Stems vs Stem II

| Context | Stem | Rule |
|---------|------|------|
| Declarative | Stem I | `A pai hi.` — He goes. |
| Interrogative | Stem II | `Na muh hiam?` — Do you see? |
| Nominalization | Stem II | `dahna` from `dah` |
| After `ci` (quotative) | Stem I | `"Ka pai" ci hi.` |
| Imperative | Stem I | `Pai in.` — Go! |

### Compound Verbs

| Compound | Components | Meaning |
|----------|------------|---------|
| `hawmkhia` | `hawm` (print) + `khia` (out) | publish |
| `laisiangtho` | `lai` (book) + `siang` (clean/holy) + `tho` (suffix) | Bible |
| `paikhia` | `pai` (go) + `khia` (out) | go out |
| `pailut` | `pai` (go) + `lut` (in) | go in |
| `paikik` | `pai` (go) + `kik` (back) | go back |

### Word-by-Word: Compound Verb Analysis

```
Laisiangtho hawmkhia ding.
```

| Word | Morphemes | Gloss |
|------|-----------|-------|
| lai-siang-tho | lai=book + siang=clean/holy + tho=suffix | Bible |
| hawm-khia | hawm=print + khia=out/publish | publish |
| ding | ding=fut | will |

**Full translation:** "The Bible will be published."

---

## 7. Tense, Aspect & Mood

### Tense Markers

| Tense | Marker | Example | Translation |
|-------|--------|---------|-------------|
| Present | `hi` | `Pai a hi.` | He goes. |
| Present continuous | `laitak` | `Pai laitak a hi.` | He is going (right now). |
| Past simple | `khin` | `A pai khin hi.` | He went. (past simple / experiential) |
| Completive/Realized | `ta` | `A pai ta hi.` | It is done. (action completed/realized) |
| Present perfect | `khinzo` | `A pai khinzo hi.` | He has already gone. |
| Past perfect | `khinsa` | `A pai khinsa hi.` | He had gone. |
| Future | `ding` | `Pai ding a hi.` | He will go. |
| Future perfect | `khinzo ding` | `Pai khinzo ding a hi.` | He will have gone. |

### Aspect Markers

| Aspect | Marker | Example | Translation |
|--------|--------|---------|-------------|
| Completive | `zo` | `Pai zo a hi.` | He finished going. |
| Past simple/Experiential | `khin` | `A pai khin hi.` | He went. / He has seen [before]. |
| Completive/Realized | `ta` | `A hoih ta hi.` | It is enough/completed. `Na dam ta in.` = Be healed. |
| Habitual | `den` | `Nasem den a hi.` | He keeps working. |
| Progressive | `lai` | `Ne lai a hi.` | He is eating. |
| Immediate | `pah` | `Pai pah a hi.` | He went immediately. |
| Resumptive | `kik` | `Pai kik a hi.` | He went again. |
| Attemptive | `sawm` | `Pai sawm a hi.` | He tried to go. |
| Intensive | `mahmah` | `Hoih mahmah a hi.` | It is very good. |

### Compound Aspect

| Combination | Example | Translation |
|-------------|---------|-------------|
| experiential + completive | `Pai khin zo a hi.` | He has already finished going. |
| progressive + experiential | `Ne lai khin ka hi.` | I have been eating. |
| future + experiential | `Pai ding khin a hi.` | He was going to go. |

### Mood Markers

| Mood | Marker | Example | Translation |
|------|--------|---------|-------------|
| Declarative | `hi` | `Pai a hi.` | He goes. |
| Interrogative | `hiam` | `Pai a hiam?` | Does he go? |
| Imperative (plural) | `un` | `Pai un.` | Go! (all of you) |
| Imperative (singular) | `in` | `Pai in.` | Go! |
| Jussive | `hen` | `Khuavak om hen.` | Let there be light. |
| Hortative | `ni` | `Mihing bawl ni.` | Let us make man. |
| Prohibitive | `kei in` | `Pai kei in.` | Don't go. |
| Polite prohibition | `dih` | `Pai kei dih.` | Please don't go. |
| Mild prohibition | `vo` | `Pai kei vo.` | Don't go (mild). |

### Word-by-Word: Tense Analysis

```
Pai ka ding hi.
```

| Word | Gloss | Function |
|------|-------|----------|
| pai | go | Verb stem |
| ka | 1SG.AGR | Subject agreement |
| ding | FUT | Future aspect marker |
| hi | DECL | Declarative particle |

**Translation:** "I will go."

```
Pai khinzo a hi.
```

| Word | Gloss | Function |
|------|-------|----------|
| pai | go | Verb stem |
| khinzo | PRF+CMPL | Present perfect (khin + zo) |
| a | 3SG.AGR | Subject agreement |
| hi | DECL | Declarative particle |

**Translation:** "He has already gone."

---

## 8. Negation

### Primary Negation Particles

| Particle | Usage | Example | Translation |
|----------|-------|---------|-------------|
| `kei` | Standard negation (ALL persons) | `Pai ka kei hi.` | I don't go. |
| `lo` | Literary/formal negation | `Pai lo hi.` | Goes not. |
| `kei lo` | Absolute negation | `Kuamah kei lo.` | Nobody. |

### Word-by-Word: Negation Analysis

```
Ka pai kei hi.
```

| Word | Gloss | Function |
|------|-------|----------|
| Ka | 1SG.AGR | Subject agreement |
| pai | go | Verb stem |
| kei | NEG | Negation particle |
| hi | DECL | Declarative particle |

**Translation:** "I don't go."

```
Pai lo hi.
```

| Word | Gloss | Function |
|------|-------|----------|
| pai | go | Verb stem |
| lo | NEG | Negation particle (literary) |
| hi | DECL | Declarative particle |

**Translation:** "Goes not." (3rd person, no subject needed)

### Negation + Tense Combinations

| Pattern | Example | Translation |
|---------|---------|-------------|
| `V + kei + hi` | `Ka pai kei hi.` | I don't go. |
| `V + lo + hi` | `Pai lo hi.` | Goes not. (3rd person, `lo` is standalone — no `a` agreement) |
| `V + kei + ding` | `Ka pai kei ding hi.` | I won't go. |
| `V + ngei + lo` | `Ka mu ngei lo hi.` | I have never seen. |
| `V + thei + lo` | `Ka gen thei lo hi.` | I cannot say. |
| `V + nuam + lo` | `Ka pai nuam lo hi.` | I don't want to go. |

### Negative Conditional

| Pattern | Example | Translation |
|---------|---------|-------------|
| `V + kei + a + leh` | `Nong pai kei a leh...` | If you don't go... |

**⚠️ CRITICAL:** Negative conditionals use `kei`, NEVER `lo`:
- ✅ `Nong pai kei a leh` — If you don't go
- ❌ `Nong pai kei leh` — WRONG (missing `a`)

### Imperative Negation

| Form | Person | Example | Translation |
|------|--------|---------|-------------|
| `kei in` | singular | `Pai kei in.` | Do not go. |
| `kei un` | plural | `Pai kei un.` | Do not go (all). |
| `kei hen` | jussive | `Na lungtang patau kei hen.` | Let not your heart be troubled. |

---

## 9. Questions

### Question Types

| Type | Particle | Example | Translation |
|------|----------|---------|-------------|
| Yes/No | `hiam` | `Na pai hiam?` | Do you go? |
| Soft yes/no | `diam` | `Na pai ding diam?` | Will you go? |
| Content (what) | `bang` | `Bang na duh hiam?` | What do you want? |
| Content (who) | `kua` | `Kua na hi hiam?` | Who are you? |
| Content (where) | `koi` | `Koi ah na pai hiam?` | Where are you going? |
| Content (why) | `bang hang` | `Bang hang pai na hiam?` | Why do you go? |
| Content (how) | `bang ci` | `Bang ci na hi hiam?` | How are you? |
| Content (how many) | `bangzat` | `Bangzat a man?` | How much does it cost? |
| Tag | `maw` | `Hoih maw?` | It's good, right? |
| Rhetorical | `diam` | `Na lung a kim diam?` | Is your heart content? (rhetorical) |

### ⚠️ CRITICAL: "diam" vs "hiam"

The copyright article uses `diam` for **rhetorical questions** (not `hiam`):

| Particle | Function | Example | Implied Answer |
|----------|----------|---------|----------------|
| `hiam` | Genuine yes/no question | `Na pai hiam?` (Do you go?) | Real answer expected |
| `diam` | Rhetorical/emphasis question | `Na lung a kim diam?` (Is your heart content?) | Known answer (usually "no") |

**Key distinction:**
- `hiam` = seeks information (neutral)
- `diam` = creates moral/emotional pressure (persuasive)

**Example from article:**
```
Na lung a kim diam?
[2SG] [heart] [3SG.AGR] [content] [RQ]
"Is your heart content?" (implies: no, it's not)
```

**Rhetorical question pattern:**
1. Triple repetition: `Na lung a kim diam?` × 3 (maximum emphasis)
2. Escalation: `Nihvei thumvei tak hi lai leh e?` (Second, third time?)
3. Evidence-based: Each question follows specific ethical violations

### Word-by-Word: Question Analysis

```
Na pai hiam?
```

| Word | Gloss | Function |
|------|-------|----------|
| Na | 2SG.AGR | Subject agreement |
| pai | go | Verb stem |
| hiam | Q | Question particle |

**Translation:** "Do you go?"

```
Bang hang pai na hiam?
```

| Word | Gloss | Function |
|------|-------|----------|
| Bang | what | Question word |
| hang | reason | Reason word |
| pai | go | Verb stem |
| Na | 2SG.AGR | Subject |
| hiam | Q | Question particle |

**Translation:** "Why do you go?"

**⚠️ CRITICAL:** Content question word order: `bang hang` + verb + subject + `hiam`
- ✅ `Bang hang pai na hiam?` — Correct word order
- ❌ `Bang hang na pai hiam?` — Incorrect word order

### Interrogative Words

| Zolai | English | Example | Translation |
|-------|---------|---------|-------------|
| `bang` | what | `Hi bang hi hiam?` | What is this? |
| `bang ci` | how | `Bang ci na hi hiam?` | How are you? |
| `bang hang` | why | `Banghang na pai?` | Why do you go? |
| `bangzat` | how many | `Bangzat a man?` | How much? |
| `koi` | where | `Koi ah om?` | Where is it? |
| `kuama` | who | `Kuama hi na hiam?` | Who is it? |
| `tu` | when (now) | `Tu-in` | Now |
| `nidang` | when (future) | `Nidang ka hong ki mu kik ding.` | We will meet someday. |

---

## 10. Ergative Construction

### When to Use Ergative `in`

The ergative marker `in` is used when:
1. The subject is a **transitive agent** performing an action on an object
2. The agent is a **proper noun** or **full noun phrase**
3. The agent is **emphasized** or **contrasted**

### Word-by-Word: Ergative Analysis

```
Pasian in vantung leh leitung a piangsak hi.
```

| Word | Gloss | Function |
|------|-------|----------|
| Pasian | God | Subject (agent) |
| in | ERG | Ergative marker |
| vantung | heaven | Object 1 |
| leh | and | Conjunction |
| leitung | earth | Object 2 |
| a | 3SG.AGR | Agreement marker |
| piangsak | create | Verb |
| hi | DECL | Declarative particle |

**Translation:** "God created the heaven and earth."

### Ergative vs Absolutive

| Construction | Example | Notes |
|--------------|---------|-------|
| Ergative (transitive) | `Pasian in gam a mu hi.` | God sees the land. |
| Absolutive (intransitive) | `Pasian om hi.` | God exists. |

### When to Omit Ergative `in`

| Situation | Example | Notes |
|-----------|---------|-------|
| With agreement markers | `Gam a mu hi.` | He sees the land. (no `in`) |
| In informal speech | `Pasian gam mu hi.` | God sees the land. (no `in`) |
| With pronouns | `Gam a mu hi.` | He sees the land. (no `in`) |

### Organizational Agents with Ergative `in`

Organizations are treated as agents with the same ergative `in` pattern:

| Organization | Example | Translation |
|-------------|---------|-------------|
| `BFBS in` | `BFBS in... khenkik hi` | BFBS reprinted |
| `TBA in` | `TBA in Lai Siangtho nasepna ZCLS ap hi` | TBA handed over Bible work to ZCLS |
| `Bible Society of Burma in` | `Bible Society of Burma in Late a bu-in bawl hi` | Bible Society of Burma combined it with Late |
| `Cope Topa in` | `Cope Topa in 1914 kumin Mate zo hi` | Rev. Cope completed Matthew in 1914 |

**Organization + Postposition patterns:**
- `[Org] + in + [verb]` — ergative agent
- `[Org] + vaihawmna + tawh` — with management of
- `[Org] + pan + [verb]` — from (source)
- `[Org] + tung + ah` — on/to (direction)
- `[Org] + kiang + ah` — toward (target)
- `[Org] + phalna + tawh` — with permission of

---

## 11. Directional Particles

### Complete System

| Particle | Direction | Standalone | Combined Example |
|----------|-----------|------------|------------------|
| `hong` | Toward speaker | `Hong pai in.` (Come here) | `Hong kik pai hi.` (Came back here) |
| `va` | Away from speaker | `Va pai in.` (Go away) | `Va khia hi.` (Went out away) |
| `khia` | Outward/out | `Khia pai hi.` (Went out) | `Paikhia hi.` (Went out) |
| `lut` | Inward/in | `Lut pai hi.` (Went in) | `Inn sungah a lut hi.` (Entered house) |
| `kik` | Back/return | `Kik pai hi.` (Went back) | `Hong kik pai hi.` (Came back) |
| `pih` | Send/bring | `Hong pih in.` (Bring here) | `Va pih in.` (Send away) |
| `suk` | Downward | `Suk pai hi.` (Went down) | `A tui lutsuk hi.` (Dived down) |
| `toh` | Upward | `Toh pai hi.` (Went up) | `Kahto in...` (Going up...) |

### Word-by-Word: Directional Analysis

```
Paikhia hi.
```

| Word | Gloss | Function |
|------|-------|----------|
| pai-khia | go-out | Compound verb: go + outward |
| hi | DECL | Declarative particle |

**Translation:** "He went out."

```
Inn sungah a lut hi.
```

| Word | Gloss | Function |
|------|-------|----------|
| Inn | house | Noun |
| sungah | inside | Locative particle |
| a | 3SG.AGR | Agreement marker |
| lut | enter | Verb (inward) |
| hi | DECL | Declarative particle |

**Translation:** "He entered the house."

---

## 12. Postpositions & Locatives

### Complete System

| Particle | Meaning | Example | Translation |
|----------|---------|---------|-------------|
| `ah` | at/in/on | `Inn ah om hi.` | He is at home. |
| `sungah` | inside | `Inn sungah om hi.` | He is inside the house. |
| `tungah` | on top of | `Bawl tungah om hi.` | It is on the table. |
| `nuaiah` | below/under | `Bawl nuaiah om hi.` | It is under the table. |
| `lamah` | toward | `Nisuahna lamah` | Toward the east |
| `panin` | from | `Leitung panin` | From the earth |
| `tawh` | with/by means of | `Lai tawh` | With/by writing |
| `ding` | for (purpose) | `Ka ding` | For me |
| `sang ah` | at school | `Sinna sang ah` | At school |

### Word-by-Word: Locative Analysis

```
Inn sungah om hi.
```

| Word | Gloss | Function |
|------|-------|----------|
| Inn | house | Noun |
| sungah | inside | Locative particle |
| om | exist | Verb |
| hi | DECL | Declarative particle |

**Translation:** "He is inside the house."

---

## 13. Connectors & Discourse Markers

### Coordinating Connectors

| Connector | Meaning | Example | Translation |
|-----------|---------|---------|-------------|
| `le` | and (nouns) | `Pa le nu` | father and mother |
| `leh` | and/with (clauses) | `A pai leh ka pai hi.` | He went and I went. |
| `ahih leh` | but/however | `A hoih hi, ahih leh a sang hi.` | It's good, but expensive. |
| `cih leh` | if/then | `A hoih cih leh, ka lei ding hi.` | If it's good, I'll buy it. |

### Narrative Connectors (Biblical/Story register)

| Connector | Meaning | Example |
|-----------|---------|---------|
| `Tua ciangin` | Then/At that time | `Tua ciangin khuavak om pah hi.` |
| `Tua ahih ciangin` | And so it was | `Tua ahih ciangin...` |
| `A kipat cilin` | In the beginning | `A kipat cilin Pasian in...` |
| `Tu-in` | Now/At this point | `Tu-in gulpi pen...` |
| `ci aa [verb]` | Having said, [verb] | `Tua bang ci aa paikhia hi.` |
| `Bang hang hiam cih leh` | Because | `Bang hang hiam cih leh...` |

### Causal/Logical Connectors

| Connector | Meaning | Example | Source |
|-----------|---------|---------|--------|
| `ahih manin` | because/therefore | `ahih manin vaipuak a na la...` | Copyright article |
| `bang hang hiam cih leh` | because (reason explanation) | `Bang hang hiam cih leh...` | General |
| `ahih leh` | but/however (contrast) | `A hoih hi, ahih leh a sang hi.` | General |
| `tua ahih manin` | therefore/for that reason | `Tua ahih manin...` | General |
| `cih bangin` | as/like/in the manner of | `Cih bangin...` | General |
| `Tua manin` | Therefore/that's why | `Tua manin zahtakhuai ka sa semsem hi.` | Copyright article |
| `Tua hi a` | That is why | `Tua hi a, i Tedim Lai Siangtho...` | Copyright article |
| `Ahihmanin` | Therefore/so | `Ahihmanin vaipuak a na la...` | Copyright article |

### Additive Connectors (from Copyright Article)

| Connector | Meaning | Example | Source |
|-----------|---------|---------|--------|
| `Tua banah` | Moreover/furthermore | `Tua banah, a mi leh sum a om pong hang...` | Copyright article |
| `Lem` | Also/even | `Lem a kisa lo, leh dik a kisa lo...` | Copyright article |
| `Leh` | And/also | `"itna" leh "hehpihna" tawh kidim...` | Copyright article |
| `Pian leh` | As well as | `Lungsim sau pai pian leh bang...` | Copyright article |

### Contrastive Connectors (from Copyright Article)

| Connector | Meaning | Example | Source |
|-----------|---------|---------|--------|
| `Ahizongin` | However/nevertheless | `Ahizongin a thu paizia thei gegu napi a...` | Copyright article |
| `Tua leh` | So/then | `Tua leh, Tedim Lai Siangtho pen...` | Copyright article |

### Focus/Topic Markers

| Particle | Function | Example | Source |
|----------|----------|---------|--------|
| `pen` | Focus/topic marker | `Tua pen khatvei bek hi lo ding.` | Copyright article |
| `mahmah` | Very/emphatic | `Na it mahmah na vok` | Copyright article |
| `bel` | Indeed/truly | `Tua pen khatvei bek hi lo ding.` | Copyright article |
| `zaw` | More/even more | `A thupi hi zaw hi.` | Copyright article |
| `tak` | Truly/indeed | `Nihvei thumvei tak hi lai leh e?` | Copyright article |
| `hang` | Indeed (affirmation) | `Hampha lua hi hang.` | Copyright article |

---

## 14. Sentence Types & Patterns

### Existential & Identifying

| Pattern | Example | Translation |
|---------|---------|-------------|
| `X om hi` | `Pasian om hi.` | God exists. |
| `X ahi hi` | `Kei Zomi ka hi hi.` | I am a Zomi. |
| `X pen Y ahi hi` | `Amah pen ka Pa ahi hi.` | He is my Father. |
| `X kici` | `Topa kici.` | [It] is called Lord. |

### Relative Clauses

Zolai relative clauses **precede** the noun they modify:

| Pattern | Example | Translation |
|---------|---------|-------------|
| `V + [noun]` | `Topa in a piangsak ganhingte` | The creatures that the Lord created |
| `V + [noun]` | `Nong gen thu` | The word that you spoke |

### Direct & Indirect Speech

| Type | Pattern | Example | Translation |
|------|---------|---------|-------------|
| Direct speech | `"[Quote]," ci hi` | `"Khuavak om hen," ci hi.` | He said, "Let there be light." |
| Indirect speech | `ci-in [verb]` | `Hoih hi, ci-in a mu hi.` | Seeing it, he said it was good. |
| Reported identity | `kici` | `Laipianpa na kici hi.` | He was called Laipianpa. |

### Word-by-Word: Quotative Analysis

```
Pasian in, "Khuavak om hen," ci hi.
```

| Word | Gloss | Function |
|------|-------|----------|
| Pasian | God | Subject |
| in | ERG | Ergative marker |
| "Khuavak om hen," | "Let there be light," | Direct speech |
| ci | QUOT | Quotative particle |
| hi | DECL | Declarative particle |

**Translation:** God said, "Let there be light."

### Comparative & Superlative

| Pattern | Example | Translation |
|---------|---------|-------------|
| `A sangin B + zaw` | `Khuavak lianzaw pen sun a uk ding.` | The greater light rules the day. |
| `-pen` (superlative) | `A lianzaw pen` | The greater one |
| `-sa` (intensifier) | `Hoih sa mahmah hi.` | It was very good. |

### Blessing & Prohibition

| Pattern | Example | Translation |
|---------|---------|-------------|
| Blessing | `Pasian in amaute thupha pia hi.` | God blessed them. |
| Prohibition | `Na ne kei ding hi.` | You shall not eat. |
| Hortative | `Mihing bawl ni.` | Let us make man. |

### Imperatives, Hortatives & Softening Particles (from Copyright Article)

The copyright article demonstrates the full range of Zolai imperative/hortative patterns:

| Pattern | Particle | Function | Example | Translation |
|---------|----------|----------|---------|-------------|
| `V + aw` | `aw` | Soft command | `Ngaih aw.` | Think! (gentle) |
| `V + ni` | `ni` | Hortative | `Sem ni.` | Let it be done. |
| `V + ning` | `ning` | Hortative variant | `Na tukik phot ning.` | Let you just return. |
| `V + un` | `un` | Polite request | `Hong maisak un.` | Please note. |
| `V + hen la` | `hen la` | Very polite | `Hong lo phei ziau hen la.` | Please let come down. |
| `V + kei + dih` | `dih` | Polite prohibition | `Pai kei dih.` | Please don't go. |
| `V + ing` | `ing` | Imperative (formal) | `Khawlkik ing.` | Return! |
| `V + in` | `in` | Imperative (singular) | `Pai in.` | Go! |
| `V + un` | `un` | Imperative (plural) | `Pai un.` | Go! (all) |
| `V + kei + ni` | `ni` | Negative hortative | `Mangngilh kei ni.` | Let us not forget. |

**⚠️ Key distinction:** `diam` (rhetorical question) vs `hiam` (genuine question):
- `Na lung a kim diam?` — Is your heart content? (rhetorical, implies "no")
- `Na pai hiam?` — Do you go? (genuine question)

**Word-by-Word: Imperative Analysis**

```
Ngaih aw, ka copyright hong hi in.
```

| Word | Gloss | Function |
|------|-------|----------|
| Ngaih | think | Verb stem |
| aw | softener | Softening particle |
| ka | 1SG.POSS | Possessive |
| copyright | copyright | Loan word |
| hong | PRFV | Perfective |
| hi | be | Verb |
| in | IMPF | Imperative/imperfective |

**Translation:** "Think, my copyright is coming."

### Loan Word Adaptation

The copyright article demonstrates how English words are borrowed into Zolai:

| English | Zolai Adaptation | Usage | Notes |
|---------|-----------------|-------|-------|
| `copyright` | `copyright` | `Copyright i cih ciang...` | Legal term, used directly |
| `vitamin` | `vitamin` | `hai pana kingah vitamin...` | Health term, used directly |
| `proposal` | `proposal` | `mikangte'n "proposal" na ci...` | Legal term, used directly |
| `quality` | `quality` | `quality nei takin...` | Standard term, used directly |
| `sunday school` | `sunday school` | `i sunday school naupangte...` | Religious term, used directly |
| `post script` | `post script` | `P.s. (post script)...` | Writing convention, used directly |

**Pattern:** English loan words are borrowed directly without morphological adaptation, maintaining their original form in Zolai prose.

### Register Variation (Formal vs Informal)

Zolai has distinct registers for formal/historical and informal/personal contexts:

| Feature | Formal Register | Informal Register |
|---------|----------------|-------------------|
| **Subject** | Organizations, passive | First person `ka` |
| **Verb forms** | `kibawl`, `khenkik`, `kigawm` | `na sang kha`, `na thum ing` |
| **Connectives** | `Tua ciangin`, `Tua khit` | `Tua khit teh`, casual chains |
| **Vocabulary** | Technical publishing terms | Emotional/personal terms |
| **Sentence length** | Long, complex | Shorter, fragmented |
| **Particles** | `hi` (declarative) | `ing`, `maw`, `ung` |
| **Tone** | Objective, historical | Subjective, grateful |
| **Agency** | Organizations as agents | First person as agent |

**Formal example (historical):**
```
1977 kumin Thuciam Lui leh Thuciam Thak a kigawm Lai Siangtho, a laibu-in suakkhia hi.
"In 1977, the New and Old Testaments were combined into a Bible, and it was printed as a book."
```

**Informal example (personal):**
```
lung dam mah mah hi
"I am very very thankful."
```

**Boundary marker:** The formal section ends with `***** Tedim Laisiangtho Vai , Update *****` and the informal section begins with `Zani 1 September 2026 in`.

### Personal/Emotional Patterns

| Pattern | Example | Translation |
|---------|---------|-------------|
| `ka + [emotion] + na` | `ka it na uh` | my love/feeling |
| `lung dam + mah mah` | `lung dam mah mah hi` | very very thankful |
| `sangam + ta` | `sangam ta` | was grateful |
| `na + [verb] + ing` | `na thum ing` | you pray (gentle) |
| `[emotion] + lua` | `lung dam lua hi` | very thankful |
| `ei maw` | (tag question) | right? |
| `ung` | (hortative) | let it be |

**Word-by-Word: Personal Pattern**
```
ka it na uh ka Sep khawp na uh a om sa mah bangin
[ka] [it] [na] [uh] [ka] [Sep] [khawp] [na] [uh] [a] [om] [sa] [mah] [bangin]
[1SG] [love] [feeling] [3PL] [1SG] [work] [desire] [feeling] [3PL] [3SG.AGR] [exist] [just] [very] [like-IMPF]
"Just as my love and my desire to work exist..."
```

### Publishing/Translation Vocabulary

| Term | English | Example | Notes |
|------|---------|---------|-------|
| `lehkhiat` | translation | `Cope Topa' lehkhiat` | Translation of a work |
| `letkhia` | translate | `Thuciam Lui letkhia hi` | Variant of lehkhiat |
| `suakkhia` | print/publish | `a laibu-in suakkhia hi` | Compound: sua+khia |
| `etphatna` | editing | `(editing) a bawl uh` | English loan with Zolai gloss |
| `ettelna` | proofreading | `(proofreading) limtak` | English loan with Zolai gloss |
| `puahphatna` | revision | `Lai Siangtho puahphatna` | From puah+phat |
| `thuluanzia` | version | `thuluanzia a thak khat` | New version |
| `ciaptehna` | edition count | `BFBS ciaptehna om hi` | Counting editions |

---

## 15. ZVS 2018 Compliance

### Forbidden Forms

| Forbidden | Correct | Meaning | Rule |
|-----------|---------|---------|------|
| `pathian` | `pasian` | God | ALWAYS use `pasian` |
| `ram` | `gam` | earth/land | ALWAYS use `gam` |
| `fapa` | `tapa` | life/son | ALWAYS use `tapa` |
| `bawipa` | `topa` | Lord | ALWAYS use `topa` |
| `siangpahrang` | `kumpipa` | Savior | ALWAYS use `kumpipa` |
| `cu/cun` | `tua` | that (conjunction) | ALWAYS use `tua` |
| `suah` | `suahtakna` | holiness | Context-dependent |
| `nunnak` | `nuntakna` | life | Context-dependent |

### ZVS 2018 Orthography Rules

| Rule | Correct | Incorrect | Example |
|------|---------|-----------|---------|
| God | `pasian` | `pathian` | `Pasian in...` |
| earth | `gam` | `ram` | `Gam ka mu hi.` |
| life/son | `tapa` | `fapa` | `Ka tapa hi.` |
| Lord | `topa` | `bawipa` | `Topa in...` |
| Savior | `kumpipa` | `siangpahrang` | `Kumpipa hi.` |
| that | `tua` | `cu/cun` | `Tua ciangin...` |

### ZVS 2018 Standard Notes

The 2018 Zokam Standard Version (ZVS) prioritizes:
- `ta` for completed actions in narrative contexts
- `hi` for universal truths or ongoing present states
- `ding` strictly for future/unrealized events
- This distinction preserves the "Lung-Kha" (Heart-Spirit) emotional weight

---

## 16. RAG Integration

### How Knowledge Flows to the AI

```
User question (Zolai or English)
    ↓
zolai-core RAG pipeline:
    1. Dictionary lookup (dict_zo_en_master_v1.jsonl — 93,931 words)
    2. Bible verse search (parallel_corpus_v1.jsonl — 31,102 verses)
    3. Phrase matching (phrases_v1.jsonl — 5,000 phrases)
    4. Grammar pattern check (grammar_patterns_v2.jsonl — 5,482 patterns)
    5. Context-aware translation (word_usage_profiles.jsonl — 7,384 records)
    6. Word attestation (vocab_index_full.jsonl — 20,929 words)
    ↓
pcore-brain API (task: "zolai"):
    - System prompt includes ZVS 2018 rules
    - RAG context injected with known words + Bible examples
    - AI responds with correct grammar + Zolai translations
```

### Grammar Rules the AI Must Follow

| Rule | Pattern | Example |
|------|---------|---------|
| SOV word order | Object-Agreement-Verb | `Gam ka mu hi.` (I land see) |
| Ergative `in` | Agent marker | `Mi in ne hi.` (Person eat) |
| Negation (ALL persons) | `kei` + person markers | `Ka pai kei hi.` (I go not) |
| `lo` standalone | No `a` agreement | `Pai lo hi.` (go not) |
| `A` (pronoun) + `lo` | Pronoun "he" + `lo` | `A pai lo hi leh` = If he doesn't go (CORRECT — `a` = pronoun, not agreement) |
| Question marker | `hiam` at end | `Na pai hiam?` (You go?) |
| Content question | `bang hang` + verb + subject + `hiam` | `Bang hang pai na hiam?` |
| Pronoun (agreement) | `a` before verb | `A pai hi.` (He go) |
| Pronoun (emphasis) | `amah` standalone | `Amah a pai hi.` (HE go) |
| Future | `ding` | `Ka pai ding hi.` (I go will) |
| Negative future | `kei + ding` or `lo + ding` | `Ka pai kei ding.` (I go not will) |

### Data Files the AI Uses

| File | What AI Gets | When Used |
|------|-------------|-----------|
| `dict_zo_en_master_v1.jsonl` | Word translations | Every word lookup |
| `parallel_corpus_v1.jsonl` | Bible verse examples | Sentence context |
| `phrases_v1.jsonl` | Multi-word expressions | Phrase translation |
| `grammar_patterns_v2.jsonl` | Grammar rules | Sentence validation |
| `vocab_index_full.jsonl` | Word frequency + books | Common word detection |
| `word_usage_profiles.jsonl` | Per-book meanings | Context-aware translation |
| `phrase_context_map.jsonl` | Phrase co-occurrences | Idiom detection |
| `negation_exercises.jsonl` | Negation patterns | Grammar teaching |
| `question_exercises.jsonl` | Question patterns | Grammar teaching |
| `pronoun_exercises.jsonl` | Pronoun patterns | Grammar teaching |

---

## 17. Glossing Conventions

### Standard Abbreviations

| Abbreviation | Meaning |
|--------------|---------|
| 1SG | 1st person singular |
| 2SG | 2nd person singular |
| 3SG | 3rd person singular |
| 1PL | 1st person plural |
| 2PL | 2nd person plural |
| 3PL | 3rd person plural |
| AGR | Agreement marker |
| ERG | Ergative marker |
| NEG | Negation particle |
| Q | Question particle |
| FUT | Future tense |
| PRF | Perfect aspect |
| CMPL | Completive aspect |
| PROG | Progressive aspect |
| HAB | Habitual aspect |
| DECL | Declarative particle |
| QUOT | Quotative particle |
| VOC | Vocative particle |
| TOP | Topic marker |
| CONJ | Conjunction |

### Interlinear Gloss Format

```
Zolai:   [word1] [word2] [word3] [word4]
Gloss:   [gloss1] [gloss2] [gloss3] [gloss4]
Free:    "Full English translation"
```

### Example: Full Interlinear Analysis

```
Pasian in vantung leh leitung a piangsak hi.
[God] [ERG] [heaven] [and] [earth] [3SG.AGR] [create] [DECL]
"God created the heaven and earth."
```

---

## Appendix A: Quick Reference Cards

### Daily Phrases

| English | Zolai | Breakdown |
|---------|-------|-----------|
| How are you? | `Na dam hiam?` | na=2SG + dam=well + hiam=Q |
| I am fine. | `Ka dam hi.` | ka=1SG + dam=well + hi=DECL |
| Thank you. | `Lungdam.` | lungdam=thank |
| Please come. | `Hong pai dih.` | hong=toward + pai=go + dih=polite |
| I don't understand. | `Ka thei kei hi.` | ka=1SG + thei=know + kei=NEG + hi=DECL |
| What is this? | `Hih bang hi hiam?` | hih=this + bang=what + hi=is + hiam=Q |

### Family Terms

| English | Zolai | Breakdown |
|---------|-------|-----------|
| my father | `ka pa` | ka=1SG + pa=father |
| my mother | `ka nu` | ka=1SG + nu=mother |
| my son | `ka tapa` | ka=1SG + tapa=son |
| my daughter | `ka tanu` | ka=1SG + tanu=daughter |
| my wife | `ka zi` | ka=1SG + zi=wife |
| my husband | `ka pasal` | ka=1SG + pasal=husband |

### Numbers

| Number | Zolai |
|--------|-------|
| 1 | khat |
| 2 | nih |
| 3 | thum |
| 4 | li |
| 5 | nga |
| 6 | taruk |
| 7 | sarih |
| 8 | arak |
| 9 | kuam |
| 10 | sawm |

---

## Appendix B: Data Sources

| Source | Entries | Size | Purpose |
|--------|---------|------|---------|
| `vocab_index_full.jsonl` | 20,929 | — | Word frequency + examples |
| `grammar_patterns_v2.jsonl` | 5,482 | — | Grammar patterns |
| `parallel_corpus_v1.jsonl` | 31,102 | 16MB | Bible verses |
| `phrases_v1.jsonl` | 5,000 | — | Multi-word phrases |
| `word_alignments_v1.jsonl` | 385,120 | — | Word alignments |
| `dict_zo_en_master_v1.jsonl` | 93,931 | 11MB | ZO→EN dictionary |
| `dict_canonical_clean.jsonl` | 112,220 | 56MB | EN→ZO dictionary |
| `negation_exercises.jsonl` | 26,061 | — | Negation patterns |
| `question_exercises.jsonl` | 24,738 | — | Question patterns |
| `pronoun_exercises.jsonl` | 21,735 | — | Pronoun patterns |

---

*Reference: ZVS 2018, Zolai Sinna Bu, Zolai Khanggui, Gentehna Tuamtuam, Bible Parallel Corpus*
