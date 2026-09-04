# Zolai-AI — Project Setup

## Clone the workspace
```bash
WS=/home/peter/Documents/Projects/zolai-ai
git clone git@github.com:Zolai-AI/zolai-core.git      # main toolkit
git clone git@github.com:Zolai-AI/.github.git          # org meta-repo
```

## Core dev loop
```bash
cd $WS/zolai-core
python -m venv .venv && source .venv/bin/activate
pip install -e .
python -m pytest tests/ -q
```

## Open in VS Code
`code $WS/zolai-ai.code-workspace` (multi-root: each repo on its own root).
