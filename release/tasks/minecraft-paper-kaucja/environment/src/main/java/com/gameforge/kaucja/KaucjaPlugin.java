package com.gameforge.kaucja;

import org.bukkit.entity.ArmorStand;
import org.bukkit.entity.Player;
import org.bukkit.plugin.java.JavaPlugin;

/** Starter Paper plugin: wire native entity visual state into these hooks. */
public final class KaucjaPlugin extends JavaPlugin {
    public static final String SOURCE_TAG = "a7532c262624";
    public boolean startKaucja() { return false; }
    public boolean spawnEntity(Player player, String id, String model) { return false; }
    public boolean applyTexture(String id, String texture) { return false; }
    public boolean playAnimation(String id, String animation) { return false; }
    public String snapshot(String id) { return "missing"; }
    public ArmorStand entity(String id) { return null; }
    public void resetForReload() { }
}
