Implement `ParkPlugin.java` for a Paper 1.20.4 plugin that manages a small park with a Corgi companion and benches players can sit on. Every state operation is currently a stub — you need to fill in the real behavior.

The plugin tracks two kinds of entities: Corgis and benches. Registering either should accept new identifiers and reject null, empty, or duplicate ones. Corgis transition between idle and playing states; unknown state labels, unregistered Corgis, and no-op transitions where the target state is already the current one should all be rejected. Seating a player on a bench should fail for empty player identifiers, unknown benches, or benches that already have an occupant.

The hitbox for the Corgi must have a Y span of 1.0 so the dog fits under a one-block gap, and the bench hitbox must have X and Z spans of 1.0 for a single-block footprint. The state snapshot must serialize to `<corgis>:<benches>:<seated>:<occupant of bench-1>` — so one Corgi, one bench, and player-1 on bench-1 produces `1:1:1:player-1`. Resetting should clear all park state.

Submit only `src/main/java/com/gameforge/park/ParkPlugin.java`.