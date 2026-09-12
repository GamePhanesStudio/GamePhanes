# GameForgeBench

> **Terminal-Bench for interactive game-engine development agents.**
>
> A Harbor-compatible benchmark for coding agents that build, debug, and repair games through terminal workspaces and executable runtime feedback.

[Homepage](https://gamephanes.github.io/) · [Benchmark](https://gamephanes.github.io/bench.html) · [Task Registry](https://gamephanes.github.io/registry/) · [Issues](https://github.com/GamePhanesStudio/GamePhanes/issues) · [Discussions](https://github.com/GamePhanesStudio/GamePhanes/discussions)

## What Is GameForgeBench?

Terminal benchmarks often stop at files, commands, and exit codes. Interactive software has a second truth: the project must import, launch, accept controlled input, change runtime state, and produce the intended behavior. GameForgeBench evaluates coding agents on that complete loop.

```text
instruction -> inspect -> edit -> run -> observe -> diagnose -> repair -> verify
```

The benchmark target is a coding agent, not a player bot. Evaluator-controlled probes provide runtime evidence; the agent is judged on engineering work, debugging, behavior, and regression resistance.

## How It Differs From Related Benchmarks

**SWE-bench** treats a resolved GitHub issue as the task and checks whether the repo's existing test suite passes after the patch. The reward is binary and the environment is a layered Docker image built from the original repo. It tests general software engineering but has no engine runtime.

**JAMER** (arxiv 2606.19830) generates Godot projects from theme keywords and measures structural completeness (SCS) and behavioral alignment (BAS) using headless Godot runs. It uses Claude Code as the agent harness with model-swapping. Its metrics are continuous rather than binary and the tasks are generative rather than repair.

**GameCraft-Bench** (arxiv 2606.17861) covers 140 Godot tasks across 15 game families and judges agent output by replaying recorded gameplay through a multimodal LLM rubric judge. The top frontier agent reached 41.5% on its scale.

GameForgeBench differs on three points. First, every task is an existing-project repair inside a real engine (Unity, Godot, Minecraft, Roblox, C++), not a generative or pure-function task. Second, the reward is determined solely by task-specific runtime behavior checked by a deterministic native probe — file presence and project parse are supporting gates only and cannot produce a passing reward on their own. Third, the scoring design is explicit: binary reward (1 when all required behavior checks pass, 0 otherwise) plus an optional post-hoc diagnostic score, with no LLM judge in the scoring path.

## Open Release

The corpus contains **81 normalized executable candidates** spanning Godot, Unity, Roblox, Minecraft, Unreal, Web, and generic engine projects. Tasks are released in batches as their Docker verifiers and oracle/no-op controls are hardened for public use. More tasks are coming soon.

Each task is a self-contained contract with a starter project, a natural-language request, a reproducible environment, protected files, a reference solution, and executable acceptance checks.

## Released Tasks

| Task | Engine | What it tests |
|---|---|---|
| [`godot-battle-status-bars-gloss`](release/tasks/godot-battle-status-bars-gloss/) | Godot | Replace flat HP/MP fills with glossy textures; bounded ratios, idempotent updates, lifecycle reload |
| [`godot-night-zone-controller`](release/tasks/godot-night-zone-controller/) | Godot | NightZone state: landmarks, armed weapons, AI path-cost multiplier, snapshot isolation |
| [`godot-replay-orbit-camera`](release/tasks/godot-replay-orbit-camera/) | Godot | Fix orbit camera drag direction; make rotation sensitivity DPI-independent |
| [`godot-replay-minimap-capture`](release/tasks/godot-replay-minimap-capture/) | Godot | Attach minimap to independent CanvasLayer; suppress screenshot-only elements during capture |
| [`godot-vehicle-effects`](release/tasks/godot-vehicle-effects/) | Godot | Smooth vehicle stopping, horizontal launcher camera follow, continuous rocket smoke trail |
| [`godot-endless-chunks`](release/tasks/godot-endless-chunks/) | Godot | Deterministic endless chunk generation with spike hazards and gated entity unlocks |
| [`godot-pixel-movement`](release/tasks/godot-pixel-movement/) | Godot | Native player input, wall collision, window configuration, HUD synchronization |
| [`godot-grenade-projectile`](release/tasks/godot-grenade-projectile/) | Godot | Grenade projectile, burn-pool validation, smoke extinguish lifecycle |
| [`godot-inksans-combat`](release/tasks/godot-inksans-combat/) | Godot | InkSans combat state: HP signals, death gating, reset idempotency, scene isolation |
| [`godot-scene-run-manager`](release/tasks/godot-scene-run-manager/) | Godot | PackedScene execution gating, crash-lock recovery, isolated runtime snapshots |
| [`minecraft-paper-chair`](release/tasks/minecraft-paper-chair/) | Paper 1.20.4 | Chair plugin: seat collision and repeated interaction behavior on a live server |
| [`minecraft-paper-corgi`](release/tasks/minecraft-paper-corgi/) | Paper 1.20.4 | Native entities, park furniture, server-authoritative interaction state |
| [`minecraft-paper-kaucja`](release/tasks/minecraft-paper-kaucja/) | Paper 1.20.4 | Native entity model, texture, and animation lifecycle |
| [`minecraft-paper-settings-i18n`](release/tasks/minecraft-paper-settings-i18n/) | Paper 1.20.4 | Locale-aware settings inventory with en_us/ru_ru switching backed by property files |
| [`cpp-shadow-map-pass`](release/tasks/cpp-shadow-map-pass/) | C++ | Implement a shadow-map pass in a C++ game-engine scene and graphics runtime |
| [`cpp-ball-prediction`](release/tasks/cpp-ball-prediction/) | C++ | Ball–ball prediction: spin transfer and overlap separation to prevent post-shot drift |
| [`html5-cyberpunk-engine`](release/tasks/html5-cyberpunk-engine/) | HTML5 | Cyberpunk game engine state transitions, enemy waves, and boss registry |

More tasks covering Unity, Roblox Luau, Unreal, and additional Godot and Minecraft scenarios are coming soon.

## Task Format

Every contributed task follows the same portable directory shape:

```text
task-name/
├── task.toml
├── instruction.md
├── environment/
│   ├── Dockerfile
│   └── project files
├── tests/
│   ├── test.sh
│   └── runtime probes and fixtures
└── solution/
    └── reference implementation
```

### File Responsibilities

- `task.toml`: task metadata, schema version, timeouts, and resource limits.
- `instruction.md`: starting condition, requested outcome, constraints, and acceptance criteria without revealing the patch.
- `environment/`: pinned engine, operating system packages, project dependencies, and clean runtime entrypoint.
- `tests/`: benchmark-owned verification executed outside the candidate implementation.
- `solution/`: maintainer reference implementation used to prove solvability; never shown to the agent.

Tasks must not depend on a contributor's local absolute path, private package registry, undisclosed asset, network download at evaluation time, or interactive GUI step.

To audit the open-source package layout and current Harbor controls:

```bash
python3 scripts/audit_harbor_022_reproducibility.py
```

Only tasks with a current Harbor 0.22.0 oracle/no-op run record are counted as reproducible.

## How To Run The Example

Requires Godot 4.6.1 for local inspection and Docker for the hermetic verifier.

```bash
cd release/tasks/godot-battle-status-bars-gloss
godot --headless --path . --editor --quit
```

The task README contains the reference-workspace command and the Docker invocation. The verifier observes the running Godot project and writes a machine-readable result with per-check diagnostics.

## Evaluation Model

GameForgeBench separates four layers of evidence:

1. **Artifact**: required files, schemas, bindings, and protected-workspace integrity.
2. **Engine**: import, parsing, scene loading, and native startup.
3. **Behavior**: ordered events, state transitions, boundaries, persistence, and lifecycle behavior.
4. **Diagnostics**: invariant-level results explaining the outcome.

This separation distinguishes a plausible file edit from a project that actually behaves correctly when the engine runs it.

The scoring design is explicit and simple: each check is binary (pass or fail), and the primary Harbor task reward is 1 only when all required checks pass, otherwise 0. An optional post-hoc diagnostic score in [0, 1] can be computed from `passed_checks / total_checks` for near-miss analysis, but it is never substituted for the primary reward. File presence and project parse checks are supporting gates only — a passing reward cannot be obtained from them alone.

## Task Quality Bar

A strong task has a narrow user-visible objective, a believable engineering problem, enough surface area for inspection and repair, deterministic evidence, and a meaningful regression boundary. It should reward understanding the project rather than string matching a known patch.

Reviewers reject tasks that can pass by deleting the gameplay loop, replacing the project with a stub, weakening the verifier, hard-coding the probe sequence, or relying on screenshots alone.

## How To Contribute

1. Fork the repository and create a branch for one task.
2. Add a directory under `release/tasks/<task-name>/` using the format above.
3. Make `tests/test.sh` executable and include a reference solution.
4. Run a clean Docker build, the verifier, and the reference solution from a clean checkout.
5. Open a pull request describing the runtime behavior and regression boundary.

## Public Scope

The public repository is the inspectable trust layer: task contracts, starter projects, verifier design, reference examples, and reproducible reports. Private evaluation variants, collected agent trajectories, and service credentials are not published as benchmark answers.

## Contributors

GamePhanesStudio maintains the benchmark, task format, runtime adapters, and evaluation tooling. Contributions are welcome through issues, discussions, and pull requests.

## License

MIT.

## Citation

```bibtex
@software{gameforgebench2026,
  author  = {GamePhanesStudio},
  title   = {GameForgeBench},
  year    = {2026},
  url     = {https://github.com/GamePhanesStudio/GamePhanes},
  license = {MIT}
}
```
