#!/bin/sh
set -eu
python -m pytest tests/test_outputs.py -q
