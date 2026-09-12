#!/usr/bin/env bash
set -euo pipefail

mkdir -p /logs/verifier
python3 /tests/run_verifier.py
