# Contributing to Zolai-AI

Thank you for helping build AI tools for the Zomi people! 🌾

## 🎯 Our Mission

Preserve and revitalize Tedim Zolai (ZVS 2018) through community-owned, culturally grounded AI tools.

## 👥 Who We Need

### Native Zomi Speakers (Highest Priority)
- Validate translations and corpus data
- Check ZVS 2018 orthography compliance
- Test learning tools and provide feedback
- Contribute cultural knowledge

### Linguists
- Tibeto-Burman grammar analysis
- Sentence structure and word prediction
- Dialectal variation documentation
- Phonological and morphological analysis

### ML Engineers
- Low-resource NLP pipelines
- Embeddings and RAG systems
- Model fine-tuning and evaluation
- Data quality assessment

### Developers
- Next.js web platform (zolai-web)
- Tauri desktop app (zolai-tauri)
- MCP server (zolai-mcp-server)
- Mobile learning apps

### Educators
- Curriculum development
- Exercise creation
- Pedagogical grammar writing
- Cultural content curation

## 🚀 Quick Start

### 1. Fork & Clone
```bash
# Fork the repo on GitHub, then:
git clone https://github.com/YOUR-USERNAME/zolai-ai.git
cd zolai-ai
git remote add upstream https://github.com/Zolai-AI/zolai-ai.git
```

### 2. Set Up Environment
```bash
# Install Python 3.10+
python3 -m venv venv
source venv/bin/activate

# Install core dependencies
pip install -r requirements.txt

# For ML work:
pip install torch transformers datasets peft unsloth

# For web development:
cd zolai-web && bun install
```

### 3. Create Branch
```bash
git checkout -b feat/your-feature-name
# or
git checkout -b fix/issue-number-description
```

### 4. Make Changes & Test
```bash
# Run linting
ruff check .

# Run tests
pytest tests/

# Verify ZVS compliance
python scripts/zvs/validate.py
```

### 5. Commit & Push
```bash
git add .
git commit -m "feat(scope): brief description"
git push origin feat/your-feature-name
```

### 6. Create PR
- Fill out PR template completely
- Link related issues
- Add screenshots if UI changes
- Request review from maintainers

## 📝 Commit Convention

We use **Conventional Commits**:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style (formatting, semicolons, etc.)
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvement
- `test`: Adding or correcting tests
- `chore`: Build process, dependencies, or auxiliary tool changes
- `ci`: CI/CD configuration changes
- `security`: Security vulnerability fixes

### Scopes
- `core`: zolai-core (RAG, API)
- `web`: zolai-web (Next.js platform)
- `tauri`: zolai-tauri (desktop app)
- `datasets`: zolai-datasets (data, scripts)
- `wiki`: zolai-wiki (knowledge base)
- `mcp`: zolai-mcp-server
- `training`: zolai-training
- `landing`: zolai-landing
- `docs`: Documentation
- `ci`: CI/CD

### Examples
```
feat(core): add Bible search endpoint
fix(web): resolve login timeout issue
docs(wiki): add grammar reference section
chore(deps): update transformers to 4.40.0
security(mcp): patch authentication bypass
```

## 🌿 Language Standards

### ZVS 2018 Compliance (CRITICAL)
All Zolai text MUST follow ZVS 2018 orthography:

| ❌ Forbidden | ✅ Correct | Meaning |
|-------------|-----------|---------|
| pathian | pasian | God |
| ram | gam | earth/ground |
| fapa | tapa | father |
| bawipa | topa | lord/master |
| siangpahrang | kumpipa | savior |
| cu/cun | tua | you/your |
| suah | chuak | go out |
| zalenna | suahtakna | to know |
| nunnak | nuntakna | to see |

### Word Order
- **SOV** is standard (Subject-Object-Verb)
- Ergative marker `in` for transitive subjects
- Example: `Ka in laibu sim hi.` (I read a book.)

### Exceptions
- Historical quotes may use old forms (flag with comment)
- Borrowed words from English/Burmese are allowed
- Dialectal variants should be documented

## 📊 Data Standards

### Dictionary Format
```json
{
  "zolai": "pasian",
  "english": ["God", "deity"],
  "source": "zomidictionary",
  "zvs_compliant": true
}
```

### Bible Verse Format
```json
{
  "book": "GEN",
  "chapter": "1",
  "verse": "1",
  "ref": "GEN 1:1",
  "zo_tdb77": "Pasian in vantung leh lebung a piangsak hi.",
  "zo_tedim2010": "Pasian in vantung leh lebung a piangsak hi.",
  "en_kJV": "In the beginning God created the heaven and the earth."
}
```

### Quality Requirements
- All data must be UTF-8 encoded
- No trailing whitespace
- Unix line endings (LF)
- Valid JSON/JSONL format
- Metadata required for provenance

## 🧪 Testing

### Run All Tests
```bash
# Python tests
pytest tests/ -v

# Linting
ruff check .
ruff format --check .

# ZVS validation
python scripts/zvs/validate.py --wiki

# Type checking
mypy zolai/
```

### Test Coverage
- Aim for 80%+ coverage on new code
- Include edge cases
- Test with real Zolai data when possible

## 🏗️ Architecture

### Repository Structure
```
zolai-ai/
├── zolai-core/          # Python API + RAG engine
├── zolai-web/           # Next.js learner platform
├── zolai-tauri/         # Desktop app (Tauri 2)
├── zolai-datasets/      # Data + build scripts
├── zolai-wiki/          # Knowledge base
├── zolai-training/      # LoRA/QLoRA fine-tuning
├── zolai-mcp-server/    # MCP server for AI assistants
├── zolai-landing/       # Org landing page
├── zolai-ai.github.io/  # GitHub Pages
├── .github/             # Org profile + community
└── data/                # Shared data (gitignored)
```

### Key Principles
1. **RAG-first**: No raw fine-tuning; inject knowledge as context
2. **Community-owned**: Open source, community-governed
3. **Culturally grounded**: Respect Zomi values and protocols
4. **Accessible**: Mobile-first, offline-capable
5. **Ethical**: CARE principles, data sovereignty

## 🎨 Style Guide

### Python
- Follow PEP 8
- Use type hints on public API
- Maximum line length: 88 characters (Black/Ruff default)
- Docstrings: Google style

### TypeScript/JavaScript
- Strict TypeScript mode
- Prettier for formatting
- ESLint for linting
- Functional components (React)

### Documentation
- Markdown for all docs
- Include code examples
- Add diagrams where helpful
- Keep language simple and clear

## 🐛 Bug Reports

### Include in Bug Report
1. **Environment**: OS, Python/Node version, browser
2. **Steps to reproduce**: Clear, numbered steps
3. **Expected behavior**: What should happen
4. **Actual behavior**: What actually happens
5. **Screenshots**: If applicable
6. **Logs**: Error messages, stack traces

### Label Meanings
- `bug`: Confirmed bug
- `enhancement`: New feature or improvement
- `good first issue`: Beginner-friendly
- `help wanted`: Community contribution welcome
- `priority: critical`: Needs immediate attention
- `zvs-compliance`: Related to orthography standards

## 🌍 Community

### Communication Channels
- **GitHub Issues**: Bug reports, feature requests
- **GitHub Discussions**: Questions, ideas, general chat
- **GitHub Discussions**: Questions, ideas, real-time chat
- **Community Meetings**: Monthly (link in GitHub Discussions)

### Recognition
- All contributors credited in README
- Significant contributions get maintainer status
- Annual contributor appreciation
- Community spotlight features

## 📚 Resources

### Learning Zolai
- [Zolai Grammar](https://github.com/Zolai-AI/zolai-wiki)
- [Dictionary](https://github.com/Zolai-AI/zolai-datasets)
- [Bible Study Tools](https://github.com/Zolai-AI/zolai-datasets/tree/main/scripts/bible)

### Technical Resources
- [NLP Tools Guide](context/NLP_TOOLS_GUIDE.md)
- [Data Governance](context/DATA_GOVERNANCE.md)
- [Research Papers](context/RESEARCH_SYNTHESIS.md)

### External Links
- [ZVS 2018 Standard](https://github.com/Zolai-AI/zolai-wiki/blob/main/grammar/ZVS_2018.md)
- [Zomi Language Resources](https://zomi language.org)
- [Low-Resource NLP Guide](https://github.com/ogulcanaydogan/LowResource-LLM-Forge)

## ❓ Questions?

- Open a GitHub Discussion
- Join our GitHub Discussions
- Attend community meetings
- Read the FAQ in wiki

## 🙏 Thank You!

Every contribution matters. Whether you fix a typo, add a word to the dictionary, or build a new feature — you're helping preserve Tedim Zolai for future generations.

**Lungdam!** (Thank you!) 🙏

---

*Last updated: 2026-09-07*
