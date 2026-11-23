#!/usr/bin/env bash
# 运行无第三方依赖的回归测试。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

mkdir -p build
swiftc -D COPYTOAST_TESTS \
  Sources/CopyToast/main.swift Tests/RegressionTests.swift \
  -o build/CopyToastTests
build/CopyToastTests
