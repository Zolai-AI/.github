# Circuit Breaker Architecture

## Overview

The circuit breaker pattern prevents cascade failures when external services (AI providers, SMTP, webhooks) become unavailable or slow. It implements the standard three-state model: CLOSED → OPEN → HALF_OPEN → CLOSED.

## Implementation

**Location:** `zolai/resilience/circuit_breaker.py`

### States

| State | Behavior |
|-------|----------|
| CLOSED | Normal operation, requests pass through, failures counted |
| OPEN | Failure threshold exceeded, requests fail fast without calling service |
| HALF_OPEN | After timeout, allows test requests to see if service recovered |

### Configuration (Environment Variables)

| Variable | Default | Description |
|----------|---------|-------------|
| `ZOLAI_CB_FAILURE_THRESHOLD` | 5 | Consecutive failures before opening |
| `ZOLAI_CB_TIMEOUT` | 30 | Seconds before transitioning to HALF_OPEN |
| `ZOLAI_CB_SUCCESS_THRESHOLD` | 2 | Successes in HALF_OPEN before closing |
| `ZOLAI_CB_ENABLED` | true | Enable/disable circuit breaker globally |

### Usage

#### Decorator (sync/async)
```python
from zolai.resilience import circuit_breaker

@circuit_breaker("llm_gemini")
async def call_gemini(prompt: str) -> str:
    # This call is protected by circuit breaker
    return await provider.generate(prompt)
```

#### Context Manager
```python
from zolai.resilience import circuit_breaker_context

with circuit_breaker_context("smtp_email"):
    await send_email(...)
```

#### Manual Control
```python
from zolai.resilience import get_circuit_breaker

cb = get_circuit_breaker("my_service")
cb.force_open()   # Manually open
cb.reset()        # Reset to closed
```

### Metrics (Prometheus)

| Metric | Type | Labels | Description |
|--------|------|--------|-------------|
| `circuit_breaker_state` | Gauge | `name`, `state` | Current state (0=closed, 1=open, 2=half_open) |
| `circuit_breaker_failures_total` | Counter | `name` | Total failures recorded |
| `circuit_breaker_successes_total` | Counter | `name` | Total successes recorded |

### Integration Points

1. **LLM Providers** (`zolai/llm/adapter.py`): Per-provider circuit breakers keyed by `catalog_id`
2. **SMTP Email** (`zolai/notifications/service.py`): `smtp_email` circuit breaker protects email sending
3. **Custom**: Any external call can use the decorator or context manager

### Thread Safety

- Uses `threading.RLock` for state transitions
- Safe for concurrent async and sync usage
- Metrics use atomic operations

### Testing

Run circuit breaker tests:
```bash
pytest tests/test_circuit_breaker.py -v
```

17 tests covering: state transitions, thresholds, decorator, context manager, metrics, thread safety, config from env.
