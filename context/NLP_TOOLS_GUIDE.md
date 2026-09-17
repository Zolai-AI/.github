# Zolai-AI: NLP Tools & Setup Guide

**Date:** 2026-09-07  
**Purpose:** Best tools, platforms, and machine setup for low-resource language NLP

## Executive Summary

Based on research from 20+ projects (BYOL, Kakugo, mTIG, NagaNLP, LILA Lab, etc.), this guide provides the best free tools and setup for building Zolai AI.

## Free Platforms for Training

### 🥇 Kaggle (Best Free Option)
- **GPU:** Tesla T4 (16GB VRAM)
- **Free Hours:** 30 hours/week
- **Credit Card:** ❌ Not required
- **Best For:** Training, notebooks, data processing
- **Setup:**
  1. Go to kaggle.com → New Notebook
  2. Enable GPU: Settings → Accelerator → GPU T4 × 2
  3. Upload datasets to /kaggle/input/
  4. Save models to /kaggle/working/

### 🥈 Google Colab
- **GPU:** T4/V100 (variable)
- **Free Hours:** ~4 hours/session
- **Credit Card:** ❌ Not required
- **Best For:** Quick experiments, prototyping
- **Limitation:** Sessions disconnect after inactivity

### 🥉 Lightning AI
- **GPU:** T4
- **Free Hours:** 22 hours/month
- **Credit Card:** ❌ Not required
- **Best For:** PyTorch Lightning projects

### Other Options
- **Paperspace Gradient:** M4000 (8GB), limited free tier
- **Saturn Cloud:** T4, 30 hrs/month (credit card required)
- **Intel DevCloud:** Xeon + GPU, 120 days trial

## Essential NLP Tools

### 1. Data Collection & Processing

| Tool | Purpose | Install | Free |
|------|---------|---------|------|
| **HuggingFace Datasets** | Dataset loading/processing | `pip install datasets` | ✅ |
| **Datatrove** | Large-scale data processing | `pip install datatrove` | ✅ |
| **trafilatura** | Web scraping/text extraction | `pip install trafilatura` | ✅ |
| **fastText** | Language identification | `pip install fasttext` | ✅ |
| **GlotLID** | 2000+ language LID | GitHub | ✅ |
| **MinHash (datasketch)** | Deduplication | `pip install datasketch` | ✅ |
| **KenLM** | Perplexity scoring | `pip install kenlm` | ✅ |

### 2. Annotation Platforms

| Tool | Purpose | Install | Free |
|------|---------|---------|------|
| **Argilla** | Community annotation | `pip install argilla` | ✅ |
| **Label Studio** | Multi-purpose annotation | `pip install label-studio` | ✅ |
| **Doccano** | Text annotation | `pip install doccano` | ✅ |

### 3. Model Training

| Tool | Purpose | Install | Free |
|------|---------|---------|------|
| **HuggingFace Transformers** | Model training | `pip install transformers` | ✅ |
| **Unsloth** | 2-5x faster LoRA | `pip install unsloth` | ✅ |
| **PEFT** | Parameter-efficient tuning | `pip install peft` | ✅ |
| **TRL** | RLHF/DPO training | `pip install trl` | ✅ |
| **LlamaFactory** | Fine-tuning UI | Docker | ✅ |
| **Axolotl** | Fine-tuning framework | `pip install axolotl` | ✅ |

### 4. Tokenization

| Tool | Purpose | Install | Free |
|------|---------|---------|------|
| **SentencePiece** | Custom tokenizers | `pip install sentencepiece` | ✅ |
| **Tokenizers (HF)** | Fast tokenizers | `pip install tokenizers` | ✅ |
| **BPEmb** | Byte-pair embeddings | `pip install bpemb` | ✅ |

### 5. Evaluation

| Tool | Purpose | Install | Free |
|------|---------|---------|------|
| **lm-evaluation-harness** | LLM benchmarks | `pip install lm-eval` | ✅ |
| **sacrebleu** | MT evaluation | `pip install sacrebleu` | ✅ |
| **rouge-score** | Summarization eval | `pip install rouge-score` | ✅ |
| **bert-score** | Semantic similarity | `pip install bert-score` | ✅ |

### 6. Inference & Serving

| Tool | Purpose | Install | Free |
|------|---------|---------|------|
| **vLLM** | High-throughput inference | `pip install vllm` | ✅ |
| **Ollama** | Local LLM serving | Download | ✅ |
| **TGI** | Text generation inference | Docker | ✅ |
| **llama.cpp** | CPU/GPU inference | Build from source | ✅ |

## Recommended Setup by Task

### Task 1: Data Cleaning Pipeline
```bash
# Install tools
pip install datasets datatrove fasttext datasketch kenlm

# Use our data_quality_scorer.py
python scripts/bible/data_quality_scorer.py input.jsonl output.jsonl --threshold 0.5

# Deduplication
python -m datatrove.tools.dedup input.jsonl output.jsonl
```

### Task 2: Synthetic Data Generation
```bash
# Option A: Local (free)
pip install ollama
ollama pull llama3.1:8b
python scripts/bible/generate_synthetic_data.py --seed data/seeds.jsonl --output data/synthetic.jsonl

# Option B: Cloud API (costs money)
pip install openai
export OPENAI_API_KEY="your-key"
python scripts/bible/generate_synthetic_data.py --provider openai --model gpt-4o
```

### Task 3: Model Fine-Tuning (Kaggle)
```python
# Kaggle notebook setup
!pip install transformers datasets peft accelerate

from transformers import AutoModelForCausalLM, TrainingArguments
from peft import LoraConfig, get_peft_model

# Load base model
model = AutoModelForCausalLM.from_pretrained("Qwen/Qwen2.5-3B")

# LoRA config
lora_config = LoraConfig(
    r=16,
    lora_alpha=32,
    target_modules=["q_proj", "v_proj"],
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM"
)

model = get_peft_model(model, lora_config)

# Train
training_args = TrainingArguments(
    output_dir="./results",
    num_train_epochs=3,
    per_device_train_batch_size=4,
    gradient_accumulation_steps=4,
    fp16=True,  # T4 supports fp16
    logging_steps=10,
    save_steps=100,
)

trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=train_dataset,
)
trainer.train()
```

### Task 4: Custom Tokenizer
```python
import sentencepiece as spm

# Train SentencePiece on Zolai text
spm.SentencePieceTrainer.train(
    input='zolai_text.txt',
    model_prefix='zolai_tokenizer',
    vocab_size=32000,
    character_coverage=0.9995,
    model_type='bpe',
    byte_fallback=True,
    split_digits=True,
)
```

### Task 5: Evaluation
```bash
# Install evaluation harness
pip install lm-eval

# Evaluate on multilingual benchmarks
lm_eval --model hf \
    --model_args pretrained=./zolai-model \
    --tasks mmlu,mmlu_continuation \
    --batch_size 8 \
    --device cuda
```

## Machine Setup (Local)

### Minimum Requirements
- **CPU:** 4+ cores
- **RAM:** 16GB+
- **Storage:** 100GB+ free
- **GPU:** Optional (T4 or better)

### Recommended Setup
- **CPU:** 8+ cores
- **RAM:** 32GB+
- **Storage:** 500GB+ SSD
- **GPU:** RTX 3090/4090 (24GB VRAM)

### Software Stack
```bash
# 1. Install Python 3.10+
sudo apt update && sudo apt install python3.10 python3-pip

# 2. Create virtual environment
python3 -m venv zolai-env
source zolai-env/bin/activate

# 3. Install core packages
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
pip install transformers datasets accelerate peft
pip install sentencepiece tokenizers
pip install unsloth  # 2-5x faster LoRA

# 4. Install data tools
pip install datatrove fasttext datasketch kenlm trafilatura

# 5. Install evaluation
pip install lm-eval sacrebleu rouge-score bert-score

# 6. Install serving
pip install vllm  # or ollama for local
```

## Best Practices from Research

### 1. Data Quality > Quantity (SynthLLM, Kakugo)
- 10K-20K high-quality examples > 100K noisy ones
- Use LLM-as-judge for quality filtering
- Validate with native speakers

### 2. Synthetic → Gold Warm-up (SynthLLM)
- Start with synthetic data (cheaper)
- Fine-tune with gold data (higher quality)
- This ordering consistently outperforms reversed

### 3. Custom Tokenizers (FineWeb2, BYOL)
- Standard tokenizers waste tokens on low-resource languages
- Train SentencePiece on target language
- Can improve downstream F1 by 5-15 points

### 4. Community Validation (NagaNLP, ELR-1000)
- LLMs hallucinate orthography and grammar
- Always validate with native speakers
- Use human-in-the-loop annotation

### 5. Evaluation Matters (IndigiEval)
- Perplexity is misleading for low-resource
- Build small, native-evaluated benchmarks
- Include cultural knowledge tests

## Cost Estimates

### Free Tier (Kaggle/Colab)
- **Data processing:** Free (CPU)
- **Model training:** 30 hrs/week free (T4)
- **Inference:** Free (local Ollama)

### Paid Tier (If Needed)
- **Together AI:** $0.60/M output tokens
- **OpenAI GPT-4o:** $2.50/M input, $10/M output
- **HuggingFace Inference:** Free tier + paid

### Kakugo Reference (54 languages)
- **Total cost:** <$50 per language
- **Training time:** 1-5 hours on single GPU
- **Data generation:** 10-50M tokens per language

## Quick Reference Commands

```bash
# Data processing
python data_quality_scorer.py input.jsonl output.jsonl --stats

# Synthetic generation
python generate_synthetic_data.py --seed seeds.jsonl --count 10000

# Tokenizer training
python -c "import sentencepiece as spm; spm.SentencePieceTrainer.train(input='text.txt', model_prefix='tok', vocab_size=32000)"

# Model training (Kaggle)
!pip install transformers datasets peft
# See notebook above

# Inference
ollama run zolai-model
# or
vllm serve ./model --port 8000
```

## References

1. BYOL (Microsoft, 2026) - Toolkit for low-resource languages
2. Kakugo (Devine et al., 2026) - <$50 per language SLM training
3. mTIG (ACL 2026) - Grammar-controlled synthetic data
4. NagaNLP (2025) - LLM-to-human bootstrapping pipeline
5. LILA Lab (2026) - Language Intelligence for Low-resource Applications
6. FineWeb2 (HuggingFace, 2025) - Adaptive data processing pipeline
7. LowResource-LLM-Forge (2026) - End-to-end fine-tuning pipeline

---

**Next Steps:**
1. Set up Kaggle notebook environment
2. Install core tools locally
3. Test data quality pipeline
4. Generate synthetic training data
5. Fine-tune first model on Kaggle
