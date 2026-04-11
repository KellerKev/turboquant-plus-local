# TurboQuant+ Local LLM Setup

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
- **blog.md** — full walkthrough with benchmarks and opencode setup
- **.github/workflows/** — CI for multi-platform package builds

## Benchmarks (Mac Studio M4 Max, 128 GB)

| Model | KV Mode | Prompt (tok/s) | Generation (tok/s) | V Compression |
|:--|:--|--:|--:|--:|
| Gemma 4 26B | FP16 | 1,441 | 88.2 | 1x |
| Gemma 4 26B | **turbo3** | 1,452 | 65.7 | **5.1x** |
| Qwen3.5 4B | FP16 | 1,519 | 90.7 | 1x |
| Qwen3.5 4B | **turbo3** | 1,521 | 82.7 | **5.1x** |

## Using with opencode

See [blog.md](blog.md) Step 7 for full configuration. Quick version:

```json
{
  "model": "turboquant-plus/gemma4-26b",
  "provider": {
    "turboquant-plus": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "TurboQuant+ (local)",
      "options": { "baseURL": "http://127.0.0.1:8092/v1" },
      "models": {
        "gemma4-26b": { "name": "Gemma 4 26B", "tools": true, "reasoning": false }
      }
    }
  }
}
```

## Pre-built Packages

Available on [prefix.dev/channels/repo](https://prefix.dev/channels/repo):

| Platform | Status |
|:--|:--|
| osx-arm64 | available |
| linux-64 | available |
| linux-aarch64 | available |

```bash
pixi add --channel https://repo.prefix.dev/repo llama-cpp-turboquant
```

## Acknowledgments

This project is a build/packaging wrapper around [TheTom's llama-cpp-turboquant](https://github.com/TheTom/llama-cpp-turboquant) — a llama.cpp fork that implements native TurboQuant KV cache compression. All the TurboQuant implementation work, Metal/CUDA kernels, and research validation was done by [TheTom](https://github.com/TheTom) in the [turboquant_plus](https://github.com/TheTom/turboquant_plus) project.

We added pixi build configuration, conda packaging recipes, multi-platform Docker builds, opencode integration guide, and benchmarks.

## License

MIT (llama.cpp), Apache 2.0 (TurboQuant)
