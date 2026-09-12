package com.gameforge.chair;

import java.util.LinkedHashSet;
import java.util.Set;
import org.bukkit.plugin.java.JavaPlugin;
import org.bukkit.util.BoundingBox;

public final class ChairPlugin extends JavaPlugin {
    public static final String SOURCE_TAG = "7a67866ae705";
    private static final Set<String> SEATED_PLAYERS = new LinkedHashSet<>();

    public static BoundingBox chairHitbox() {
        return new BoundingBox(0, 0, 0, 1, 1, 1);
    }

    public static boolean handleChairInteract(String playerId) {
        if (playerId == null || playerId.trim().isEmpty()) return false;
        return SEATED_PLAYERS.add(playerId);
    }

    public static String snapshot() {
        return SEATED_PLAYERS.size() + ":" + String.join(",", SEATED_PLAYERS);
    }

    public static void resetForReload() {
        SEATED_PLAYERS.clear();
    }

    @Override
    public void onDisable() {
        resetForReload();
    }
}
