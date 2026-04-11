#!/bin/bash
set -euxo pipefail

METAL_FLAG="-DGGML_METAL=OFF"
BLAS_FLAG="-DGGML_BLAS=OFF"

if [[ "$(uname -s)" == "Darwin" ]]; then
    METAL_FLAG="-DGGML_METAL=ON"
    BLAS_FLAG="-DGGML_BLAS=ON"
fi

cmake -B build -S . \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    ${METAL_FLAG} \
    ${BLAS_FLAG} \
    -DGGML_OPENMP=ON \
    -DLLAMA_BUILD_TESTS=OFF \
    -DLLAMA_BUILD_EXAMPLES=ON \
    -DLLAMA_BUILD_SERVER=ON

cmake --build build -j"${CPU_COUNT}"
cmake --install build
