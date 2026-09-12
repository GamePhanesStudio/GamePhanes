import com.gameforge.localization.LocalizationPlugin;
import com.google.gson.Gson;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.bukkit.Bukkit;
import org.bukkit.Material;
import org.bukkit.entity.Player;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.player.PlayerJoinEvent;
import org.bukkit.inventory.Inventory;
import org.bukkit.inventory.ItemStack;
import org.bukkit.plugin.java.JavaPlugin;

public final class ForgeVerifier extends JavaPlugin implements Listener {
    private final List<Map<String, Object>> checks = new ArrayList<>();
    private final List<Map<String, Object>> events = new ArrayList<>();
    private LocalizationPlugin candidate;
    private boolean scheduled;

    @Override public void onEnable() {
        candidate = (LocalizationPlugin) Bukkit.getPluginManager().getPlugin("Localization");
        Bukkit.getPluginManager().registerEvents(this, this);
        mark("verifier_enabled", Map.of("paper", Bukkit.getVersion()));
    }

    @EventHandler public void onJoin(PlayerJoinEvent event) {
        if (!scheduled && Bukkit.getPlayerExact("ProbeAlice") != null && Bukkit.getPlayerExact("ProbeBob") != null) {
            scheduled = true;
            Bukkit.getScheduler().runTaskLater(this, this::runChecks, 10L);
        }
    }

    private void mark(String stage, Map<String, Object> state) {
        Map<String, Object> event = new LinkedHashMap<>(state);
        event.put("stage", stage);
        event.put("tick", Bukkit.getCurrentTick());
        events.add(event);
        getLogger().info("PROBE_STAGE " + new Gson().toJson(event));
    }

    private void test(String id, Runnable body) {
        try {
            candidate.resetForReload();
            body.run();
            checks.add(Map.of("id", id, "type", "paper_server_event_probe", "passed", true));
        } catch (Throwable failure) {
            failure.printStackTrace();
            checks.add(Map.of("id", id, "type", "paper_server_event_probe", "passed", false, "error", failure.toString()));
        }
    }

    private void require(boolean value, String message) { if (!value) throw new AssertionError(message); }
    private Player alice() { return Bukkit.getPlayerExact("ProbeAlice"); }
    private Player bob() { return Bukkit.getPlayerExact("ProbeBob"); }

    private Inventory top(Player player) { return player.getOpenInventory().getTopInventory(); }
    private String label(Player player, int slot) {
        ItemStack item = top(player).getItem(slot);
        require(item != null && item.getItemMeta() != null, "missing settings item");
        return item.getItemMeta().getDisplayName();
    }

    private void runChecks() {
        test("lifecycle_gui", () -> {
            require(candidate.startSettings(), "start");
            require(top(alice()).getSize() == 9 && top(bob()).getSize() == 9, "native views missing");
            require(top(alice()).getItem(4).getType() == Material.PAPER, "title item missing");
            require("Settings".equals(label(alice(), 4)) && "Save".equals(label(alice(), 8)), "english labels missing");
            mark("english_view_observed", Map.of("title", label(alice(), 4), "save", label(alice(), 8)));
        });
        test("locale_transition", () -> {
            require(candidate.startSettings() && candidate.setLocale("ru_ru"), "locale setup");
            require("ru_ru:Настройки:Сохранить".equals(candidate.renderSettings()), "render state");
            require("Настройки".equals(label(alice(), 4)) && "Сохранить".equals(label(alice(), 8)), "native russian labels missing");
            require("Настройки".equals(label(bob(), 4)), "second view not updated");
            mark("russian_view_observed", Map.of("render", candidate.renderSettings()));
        });
        test("boundary_locale", () -> {
            require(candidate.startSettings(), "start");
            String before = candidate.renderSettings();
            require(!candidate.setLocale("xx_zz") && "missing".equals(candidate.text("missing")), "invalid locale accepted");
            require(before.equals(candidate.renderSettings()) && "Settings".equals(label(alice(), 4)), "invalid locale mutated view");
        });
        test("two_player_views", () -> {
            require(candidate.startSettings(), "start");
            require(alice().getUniqueId() != null && bob().getUniqueId() != null && !alice().getUniqueId().equals(bob().getUniqueId()), "players aliased");
            require(top(alice() ) != top(bob()), "views aliased");
            require(candidate.setLocale("ru_ru") && "Сохранить".equals(label(bob(), 8)), "view isolation/update failed");
        });
        test("reload_cleanup", () -> {
            require(candidate.startSettings() && candidate.setLocale("ru_ru"), "setup");
            candidate.resetForReload();
            require("missing".equals(candidate.renderSettings()), "reload state leaked");
            require(alice().getOpenInventory().getTopInventory().getItem(4) == null, "Alice view leaked");
            require(bob().getOpenInventory().getTopInventory().getItem(4) == null, "Bob view leaked");
        });
        test("disable_lifecycle", () -> {
            require(candidate.startSettings(), "setup");
            Bukkit.getPluginManager().disablePlugin(candidate);
            require("missing".equals(candidate.renderSettings()), "disable state leaked");
            require(alice().getOpenInventory().getTopInventory().getItem(4) == null && bob().getOpenInventory().getTopInventory().getItem(4) == null, "inventory remained open");
        });
        try {
            Path out = Path.of("probe-output");
            Files.createDirectories(out);
            Files.writeString(out.resolve("behavior.json"), new Gson().toJson(Map.of("checks", checks, "events", events)));
        } catch (Exception failure) { failure.printStackTrace(); }
        Bukkit.getScheduler().runTask(this, Bukkit::shutdown);
    }
}
