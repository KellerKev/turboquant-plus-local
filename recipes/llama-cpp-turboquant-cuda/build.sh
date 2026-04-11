#!/bin/bash
set -euxo pipefail

cmake -B build -S . \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DGGML_CUDA=ON \
    -DGGML_OPENMP=ON \
    -DLLAMA_BUILD_TESTS=OFF \
    -DLLAMA_BUILD_EXAMPLES=ON \
    -DLLAMA_BUILD_SERVER=ON

cmake --build build -j"${CPU_COUNT}"
cmake --install build
