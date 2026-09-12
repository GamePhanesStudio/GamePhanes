package com.gameforge.localization;

import org.bukkit.plugin.java.JavaPlugin;

/** Starter plugin shell; the settings runtime is intentionally incomplete. */
public final class LocalizationPlugin extends JavaPlugin {
    @Override
    public void onEnable() {
        // The task implementation adds the settings inventory and lifecycle state.
    }

    public static boolean startSettings() {
        return false;
    }

    public static boolean setLocale(String requested) {
        return false;
    }

    public static String text(String key) {
        return "missing";
    }

    public static String renderSettings() {
        return "missing";
    }

    public static void resetForReload() {
        // No runtime state exists in the starter.
    }
}
