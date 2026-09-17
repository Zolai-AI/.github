# Zolai-AI: Kaggle Notebook Setup Guide

**Last Updated:** 2026-09-07  
**Purpose:** Set up Kaggle notebook environment for Zolai model training

---

## Quick Start

### 1. Create Kaggle Account
1. Go to [kaggle.com](https://kaggle.com)
2. Sign up with GitHub or email
3. Verify email address

### 2. Enable GPU
1. Click **New Notebook** (top right)
2. Click **Settings** (right sidebar)
3. Under **Accelerator**, select **GPU T4 ×2**
4. Click **Save**

### 3. Upload Datasets
1. Click **Add Data** (right sidebar)
2. Search for `zolai` or `peterpausianlian`
3. Add these datasets:
   - `zolai-llm-training-dataset` (94MB)
   - `zolai-tedim-cleaned-master` (120MB)
   - `peterpausianlian/zolai-knowledge-vectors`

### 4. Install Dependencies
```python
# Cell 1: Install packages
!pip install -q transformers datasets peft accelerate
!pip install -q unsloth  # 2-5x faster LoRA
!pip install -q sentencepiece tokenizers
!pip install -q wandb  # Optional: track training
```

### 5. Load Data
```python
# Cell 2: Load datasets
from datasets import load_dataset

# Load training data
dataset = load_dataset('peterpausianlian/zolai-llm-training-dataset')
print(f"Training examples: {len(dataset['train'])}")

# Preview
print("\nSample:")
print(dataset['train'][0])
```

### 6. Load Base Model
```python
# Cell 3: Load Qwen2.5-3B
from transformers import AutoModelForCausalLM, AutoTokenizer

model_name = "Qwen/Qwen2.5-3B"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(
    model_name,
    torch_dtype="auto",
    device_map="auto"
)

print(f"Model loaded: {model_name}")
print(f"Parameters: {model.num_parameters():,}")
```

### 7. Configure LoRA
```python
# Cell 4: LoRA configuration
from peft import LoraConfig, get_peft_model

lora_config = LoraConfig(
    r=16,
    lora_alpha=32,
    target_modules=["q_proj", "v_proj", "o_proj", "gate_proj", "up_proj", "down_proj"],
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM"
)

model = get_peft_model(model, lora_config)
print(f"Trainable parameters: {model.num_parameters():,}")
```

### 8. Training
```python
# Cell 5: Training configuration
from transformers import TrainingArguments, Trainer

training_args = TrainingArguments(
    output_dir="./zolai-qwen2.5-3b-lora",
    num_train_epochs=3,
    per_device_train_batch_size=4,
    gradient_accumulation_steps=4,
    learning_rate=2e-4,
    fp16=True,  # T4 supports fp16
    logging_steps=10,
    save_steps=100,
    save_total_limit=3,
    warmup_steps=100,
    lr_scheduler_type="cosine",
    report_to="none",  # or "wandb" for tracking
)

trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=dataset['train'],
    tokenizer=tokenizer,
)

# Start training
trainer.train()
```

### 9. Save Model
```python
# Cell 6: Save LoRA adapter
model.save_pretrained("./zolai-qwen2.5-3b-lora")
tokenizer.save_pretrained("./zolai-qwen2.5-3b-lora")

print("Model saved!")
```

### 10. Push to HuggingFace
```python
# Cell 7: Push to Hub
from huggingface_hub import login

# Login (you'll need a token)
login()

# Push
model.push_to_hub("peterpausianlian/zolai-qwen2.5-3b-lora")
tokenizer.push_to_hub("peterpausianlian/zolai-qwen2.5-3b-lora")

print("Model pushed to HuggingFace!")
```

---

## Dataset Format

### Training Data (JSONL)
```json
{
  "zolai": "Pasian in vantung leh leitung a piangsak hi.",
  "english": "God created the heavens and the earth.",
  "source": "bible_tdb77",
  "type": "translation"
}
```

### Conversation Format (ChatML)
```json
{
  "messages": [
    {"role": "system", "content": "You are a Zolai language tutor."},
    {"role": "user", "content": "How do you say 'God created the heavens' in Zolai?"},
    {"role": "assistant", "content": "Pasian in vantung a piangsak hi."}
  ]
}
```

---

## Training Tips

### 1. Data Quality
- **Start with 500 seed pairs**
- **Generate 10K synthetic pairs**
- **Keep 30%+ real data** in training
- **Validate with native speakers**

### 2. Hyperparameters
- **Learning rate:** 2e-4 (good default)
- **Batch size:** 4-8 (T4 limit)
- **Epochs:** 1-3 (avoid overfitting)
- **LoRA rank:** 16 (balance speed/quality)

### 3. Memory Management
- **Use gradient checkpointing** for large models
- **Monitor GPU memory** with `nvidia-smi`
- **Reduce batch size** if OOM

### 4. Evaluation
- **Save checkpoints** every 100 steps
- **Monitor loss** for overfitting
- **Test on held-out data** before pushing

---

## Troubleshooting

### OOM Error
```python
# Reduce batch size
per_device_train_batch_size=2

# Enable gradient checkpointing
model.gradient_checkpointing_enable()
```

### Slow Training
```python
# Use Unsloth for 2-5x speedup
from unsloth import FastLanguageModel

model, tokenizer = FastLanguageModel.from_pretrained(
    model_name="Qwen/Qwen2.5-3B",
    max_seq_length=2048,
    dtype=None,
    load_in_4bit=True,
)
```

### Tokenizer Issues
```python
# Add special tokens
special_tokens = {"pad_token": "<|pad|>"}
tokenizer.add_special_tokens(special_tokens)
model.resize_token_embeddings(len(tokenizer))
```

---

## Resources

- [Kaggle GPU Docs](https://www.kaggle.com/docs/gpus)
- [HuggingFace Training](https://huggingface.co/docs/transformers/training)
- [Unsloth](https://github.com/unslothai/unsloth)
- [LoRA Paper](https://arxiv.org/abs/2106.09685)

---

**Lungdam!** 🙏
