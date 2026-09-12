package com.gameforge.localization;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;
import java.util.UUID;
import org.bukkit.Bukkit;
import org.bukkit.Material;
import org.bukkit.entity.Player;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.inventory.InventoryCloseEvent;
import org.bukkit.inventory.Inventory;
import org.bukkit.inventory.ItemStack;
import org.bukkit.inventory.meta.ItemMeta;
import org.bukkit.plugin.java.JavaPlugin;

/** Paper settings inventory backed by packaged locale resources. */
public final class LocalizationPlugin extends JavaPlugin implements Listener {
    private static LocalizationPlugin instance;
    private static boolean started;
    private static String locale;
    private static Map<String, String> translations = Map.of();
    private static final Map<UUID, Inventory> VIEWS = new LinkedHashMap<>();

    @Override
    public void onEnable() {
        instance = this;
        Bukkit.getPluginManager().registerEvents(this, this);
    }

    @Override
    public void onDisable() {
        resetForReload();
        if (instance == this) instance = null;
    }

    public static synchronized boolean startSettings() {
        if (started || instance == null || !loadLocale("en_us")) return false;
        started = true;
        for (Player player : Bukkit.getOnlinePlayers()) openFor(player);
        return !VIEWS.isEmpty();
    }

    private static void openFor(Player player) {
        Inventory view = Bukkit.createInventory(null, 9, "Settings");
        VIEWS.put(player.getUniqueId(), view);
        player.openInventory(view);
        render(view);
    }

    private static void render(Inventory view) {
        view.clear();
        view.setItem(4, named(Material.PAPER, text("title")));
        view.setItem(8, named(Material.EMERALD, text("save")));
    }

    private static ItemStack named(Material material, String label) {
        ItemStack item = new ItemStack(material);
        ItemMeta meta = item.getItemMeta();
        meta.setDisplayName(label);
        item.setItemMeta(meta);
        return item;
    }

    private static boolean loadLocale(String requested) {
        if (instance == null || requested == null) return false;
        String normalized = requested.toLowerCase(Locale.ROOT);
        if (!normalized.equals("en_us") && !normalized.equals("ru_ru")) return false;
        Properties properties = new Properties();
        try (InputStream stream = instance.getResource("lang/" + normalized + ".properties")) {
            if (stream == null) return false;
            properties.load(new InputStreamReader(stream, StandardCharsets.UTF_8));
        } catch (IOException error) {
            return false;
        }
        Map<String, String> next = new LinkedHashMap<>();
        for (String key : properties.stringPropertyNames()) {
            next.put(key, properties.getProperty(key));
        }
        if (!next.containsKey("title") || !next.containsKey("save")) return false;
        locale = normalized;
        translations = Map.copyOf(next);
        return true;
    }

    public static synchronized boolean setLocale(String requested) {
        if (!started || !loadLocale(requested)) return false;
        for (Inventory view : new ArrayList<>(VIEWS.values())) render(view);
        return true;
    }

    public static synchronized String text(String key) {
        if (!started || key == null) return "missing";
        return translations.getOrDefault(key, "missing");
    }

    public static synchronized String renderSettings() {
        if (!started || locale == null || VIEWS.isEmpty()) return "missing";
        return locale + ":" + text("title") + ":" + text("save");
    }

    public static synchronized void resetForReload() {
        for (UUID id : new ArrayList<>(VIEWS.keySet())) {
            Player player = Bukkit.getPlayer(id);
            Inventory view = VIEWS.get(id);
            if (view != null) view.clear();
            if (player != null) player.closeInventory();
        }
        VIEWS.clear();
        started = false;
        locale = null;
        translations = Map.of();
    }

    @EventHandler
    public void onClose(InventoryCloseEvent event) {
        if (VIEWS.get(event.getPlayer().getUniqueId()) == event.getInventory()) {
            VIEWS.remove(event.getPlayer().getUniqueId());
        }
    }
}
