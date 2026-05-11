# TurboQuant+ Local LLM Setup

> **Based on [TheTom/turboquant_plus](https://github.com/TheTom/turboquant_plus).**

> **Disclaimer:** This is a proof-of-tech for educational and "art of the possible" purposes, put together in spare time. It is not meant for production, nor is it supported or endorsed by Snowflake.

Build and run local LLMs with [TurboQuant KV cache compression](https://github.com/TheTom/turboquant_plus) — 5.1x less memory for the KV cache, enabling longer context on the same hardware.

## Quick Start

### Option A: Install pre-built package (no compilation)

```bash
pixi init && pixi add --channel https://repo.prefix.dev/repo llama-cpp-turboquant
pixi run -- llama-server -m model.gguf -ctk q8_0 -ctv turbo3 -fa on -ngl 99 -c 16384 --jinja
```

### Option B: Build from source

```bash
git clone --recurse-submodules https://github.com/YOUR_USERNAME/turboquant-plus-local.git
cd turboquant-plus-local
pixi install
pixi run build
pixi run download-gemma4
pixi run serve
```

## What's Included

- **llama-cpp-turboquant** — llama.cpp fork with native TurboQuant KV compression
- **pixi.toml** — reproducible build with cmake, ninja, compilers from conda-forge
- **recipes/** — rattler-build recipe for conda packaging
- **.github/workflows/** — CI for multi-platform package builds

## Benchmarks (Mac Studio M4 Max, 128 GB)

| Model | KV Mode | Prompt (tok/s) | Generation (tok/s) | V Compression |
|:--|:--|--:|--:|--:|
| Mistral Medium 3.5 128B | FP16 | 50.0 | 7.1 | 1x |
| Mistral Medium 3.5 128B | **turbo4** | 50.2 | 6.8 | **3.8x** |
| Gemma 4 26B | FP16 | 1,441 | 88.2 | 1x |
| Gemma 4 26B | **turbo3** | 1,452 | 65.7 | **5.1x** |
| Qwen3.5 4B | FP16 | 1,519 | 90.7 | 1x |
| Qwen3.5 4B | **turbo3** | 1,521 | 82.7 | **5.1x** |

## Model Compatibility Notes

Tested with `llama-cpp-turboquant` at b8814:

| Model | turbo4 (4-bit V) | turbo3 (3-bit V) | Notes |
|:--|:-:|:-:|:--|
| Llama 3.x | yes | yes | Universal |
| Qwen3.5 (DeltaNet hybrid) | yes | yes | Both work well |
| Gemma 4 26B-A4B (MoE) | yes | yes | Both work well |
| **Mistral Medium 3.5 128B** | **yes** | **broken** | turbo3 produces gibberish; use turbo4 |

For Mistral 3.5 specifically, use `-ctv turbo4` (3.8x V compression). `turbo3` produces corrupted output on this architecture as of the current TurboQuant build.

### Recommended Settings

```bash
# Safe default for any model (3.8x V compression, ~0% PPL impact)
-ctk q8_0 -ctv turbo4 -fa on

# Best compression for Llama/Qwen/Gemma (5.1x V compression, +1-2% PPL)
-ctk q8_0 -ctv turbo3 -fa on

# Maximum compression for 70B+ models (5.1x K+V, validated on Llama 70B / Command-R+ 104B)
-ctk turbo3 -ctv turbo3 -fa on
```

### Context Size

opencode and other agentic clients send large system prompts with tool definitions (often 20K+ tokens). Use `-c 32768` or higher to avoid context overflow:

```bash
llama-server ... -c 32768 --jinja --reasoning-budget 0
```

`--reasoning-budget 0` disables the model's chain-of-thought to keep responses snappy.

## Using with opencode

Start the server:

```bash
./llama-cpp-turboquant/build/bin/llama-server \
  -m models/UD-Q4_K_XL/Mistral-Medium-3.5-128B-UD-Q4_K_XL-00001-of-00003.gguf \
  --port 8092 \
  -ctk q8_0 -ctv turbo4 \
  -fa on -ngl 99 -c 32768 \
  --threads 12 --jinja --reasoning-budget 0
```

Configure `~/.config/opencode/opencode.json`:

```json
{
  "model": "turboquant-plus/mistral-medium-3.5",
  "provider": {
    "turboquant-plus": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "TurboQuant+ (local)",
      "options": { "baseURL": "http://127.0.0.1:8092/v1" },
      "models": {
        "mistral-medium-3.5": { "name": "Mistral Medium 3.5 128B", "tools": true, "reasoning": false }
      }
    }
  }
}
```

Then run `opencode`.

> **First request is slow** (~30-60s on a 128B model) because Metal compute graphs need to warm up. Subsequent requests are fast (~2s for short prompts). If opencode times out on the first request, retry — the server is now warm.

## Pre-built Packages

Available on [prefix.dev/channels/repo](https://prefix.dev/channels/repo):

```bash
# macOS (Apple Silicon) — Metal GPU
pixi add --channel https://repo.prefix.dev/repo llama-cpp-turboquant

# Linux — CPU + auto-detect CUDA
pixi add --channel https://repo.prefix.dev/repo llama-cpp-turboquant

# Linux — NVIDIA CUDA GPU (requires CUDA 12+)
pixi add --channel https://repo.prefix.dev/repo llama-cpp-turboquant-cuda
```

| Package | Platform | GPU |
|:--|:--|:--|
| `llama-cpp-turboquant` | osx-arm64, linux-64, linux-aarch64 | Metal (macOS), CPU (Linux) |
| `llama-cpp-turboquant-cuda` | linux-64 | NVIDIA CUDA 12+ |

## Acknowledgments

This project is a build/packaging wrapper around [TheTom's llama-cpp-turboquant](https://github.com/TheTom/llama-cpp-turboquant) — a llama.cpp fork that implements native TurboQuant KV cache compression. All the TurboQuant implementation work, Metal/CUDA kernels, and research validation was done by [TheTom](https://github.com/TheTom) in the [turboquant_plus](https://github.com/TheTom/turboquant_plus) project.

We added pixi build configuration, conda packaging recipes, multi-platform Docker builds, opencode integration guide, and benchmarks.

## License

MIT (llama.cpp), Apache 2.0 (TurboQuant)
