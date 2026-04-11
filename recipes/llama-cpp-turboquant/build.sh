#!/bin/bash
set -euxo pipefail

EXTRA_FLAGS=""

case "$(uname -s)" in
    Darwin)
        # macOS: Metal GPU + Accelerate BLAS
        EXTRA_FLAGS="-DGGML_METAL=ON -DGGML_BLAS=ON"
        ;;
    Linux)
        # Linux: check for CUDA toolkit
        if command -v nvcc &>/dev/null || [ -d "${CUDA_HOME:-/usr/local/cuda}" ]; then
            CUDA_PATH="${CUDA_HOME:-/usr/local/cuda}"
            EXTRA_FLAGS="-DGGML_CUDA=ON -DCMAKE_CUDA_COMPILER=${CUDA_PATH}/bin/nvcc"
            echo "CUDA detected at ${CUDA_PATH} — building with GPU support"
        else
            echo "No CUDA found — building CPU-only (install cuda-toolkit for GPU support)"
        fi
        ;;
esac

cmake -B build -S . \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DGGML_OPENMP=ON \
    -DLLAMA_BUILD_TESTS=OFF \
    -DLLAMA_BUILD_EXAMPLES=ON \
    -DLLAMA_BUILD_SERVER=ON \
    ${EXTRA_FLAGS}

cmake --build build -j"${CPU_COUNT}"
cmake --install build
