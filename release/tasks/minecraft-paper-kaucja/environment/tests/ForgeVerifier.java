import com.gameforge.kaucja.KaucjaPlugin;
import com.google.gson.Gson;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.bukkit.Bukkit;
import org.bukkit.entity.ArmorStand;
import org.bukkit.entity.Entity;
import org.bukkit.entity.Player;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.player.PlayerJoinEvent;
import org.bukkit.plugin.java.JavaPlugin;

public final class ForgeVerifier extends JavaPlugin implements Listener {
    private final List<Map<String, Object>> checks = new ArrayList<>();
    private final List<Map<String, Object>> events = new ArrayList<>();
    private KaucjaPlugin candidate;
    private boolean scheduled;

    @Override public void onEnable() {
        candidate = (KaucjaPlugin) Bukkit.getPluginManager().getPlugin("Kaucja");
        Bukkit.getPluginManager().registerEvents(this, this);
    }

    @EventHandler public void onJoin(PlayerJoinEvent event) {
        if (!scheduled && Bukkit.getPlayerExact("ProbeAlice") != null && Bukkit.getPlayerExact("ProbeBob") != null) {
            scheduled = true;
            Bukkit.getScheduler().runTaskLater(this, this::runChecks, 10L);
        }
    }

    private void test(String id, Runnable body) {
        try { candidate.resetForReload(); body.run(); checks.add(Map.of("id", id, "type", "paper_server_event_probe", "passed", true)); }
        catch (Throwable failure) { failure.printStackTrace(); checks.add(Map.of("id", id, "type", "paper_server_event_probe", "passed", false, "error", failure.toString())); }
    }
    private void require(boolean value, String message) { if (!value) throw new AssertionError(message); }
    private Player alice() { return Bukkit.getPlayerExact("ProbeAlice"); }
    private Player bob() { return Bukkit.getPlayerExact("ProbeBob"); }
    private ArmorStand stand(String id) { return candidate.entity(id); }
    private void mark(String stage, Map<String, Object> state) { Map<String, Object> event = new LinkedHashMap<>(state); event.put("stage", stage); event.put("tick", Bukkit.getCurrentTick()); events.add(event); getLogger().info("PROBE_STAGE " + new Gson().toJson(event)); }

    private void runChecks() {
        Player a = alice(), b = bob();
        test("lifecycle_spawn", () -> {
            require(candidate.startKaucja(), "start");
            require(candidate.spawnEntity(a, "guard", "guard_model"), "spawn");
            require(!candidate.spawnEntity(a, "guard", "other_model"), "duplicate accepted");
            ArmorStand entity = stand("guard");
            require(entity != null && entity.isValid() && entity.getWorld().equals(a.getWorld()), "native entity missing");
            require(entity.getScoreboardTags().contains("kaucja-guard"), "entity tag missing");
            mark("entity_spawned", Map.of("uuid", entity.getUniqueId().toString(), "snapshot", candidate.snapshot("guard")));
        });
        test("texture_animation", () -> {
            require(candidate.startKaucja() && candidate.spawnEntity(a, "guard", "guard_model"), "setup");
            require(candidate.applyTexture("guard", "guard_texture"), "texture");
            require(candidate.playAnimation("guard", "turn"), "animation");
            require(candidate.snapshot("guard").equals("guard_model:guard_texture:turn"), "state");
            require(stand("guard").getHeadPose().getY() > 1.0, "native pose not observed");
            mark("animation_observed", Map.of("snapshot", candidate.snapshot("guard")));
        });
        test("boundary_isolation", () -> {
            require(candidate.startKaucja() && candidate.spawnEntity(a, "guard", "guard_model"), "setup");
            String before = candidate.snapshot("guard");
            require(!candidate.applyTexture("guard", "") && !candidate.applyTexture("guard", "x".repeat(97)), "bad texture accepted");
            require(!candidate.playAnimation("guard", "explode"), "bad animation accepted");
            require(!candidate.spawnEntity(a, "", "model") && before.equals(candidate.snapshot("guard")), "state corrupted");
        });
        test("multi_entity_runtime", () -> {
            require(candidate.startKaucja() && candidate.spawnEntity(a, "alice", "model_a") && candidate.spawnEntity(b, "bob", "model_b"), "setup");
            require(!stand("alice").getUniqueId().equals(stand("bob").getUniqueId()), "entities aliased");
            require(stand("alice").getLocation().distanceSquared(stand("bob").getLocation()) > 0.01, "entities overlap");
        });
        test("reload_cleanup", () -> {
            require(candidate.startKaucja() && candidate.spawnEntity(a, "guard", "guard_model"), "setup");
            ArmorStand entity = stand("guard");
            candidate.resetForReload();
            require(!entity.isValid() && "missing".equals(candidate.snapshot("guard")), "reload leaked entity");
            require(candidate.startKaucja() && candidate.spawnEntity(a, "guard", "guard_model"), "restart");
        });
        test("disable_lifecycle", () -> {
            require(candidate.startKaucja() && candidate.spawnEntity(a, "guard", "guard_model"), "setup");
            Bukkit.getPluginManager().disablePlugin(candidate);
            for (Entity entity : a.getWorld().getEntities()) require(!entity.getScoreboardTags().contains("kaucja-entity"), "entity leaked on disable");
        });
        try { Path out = Path.of("probe-output"); Files.createDirectories(out); Files.writeString(out.resolve("behavior.json"), new Gson().toJson(Map.of("checks", checks, "events", events))); }
        catch (Exception failure) { failure.printStackTrace(); }
        Bukkit.getScheduler().runTask(this, Bukkit::shutdown);
    }
}
