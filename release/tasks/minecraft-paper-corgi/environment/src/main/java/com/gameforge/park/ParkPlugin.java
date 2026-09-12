package com.gameforge.park;

import java.util.LinkedHashMap;
import java.util.Map;
import org.bukkit.plugin.java.JavaPlugin;
import org.bukkit.util.BoundingBox;

public final class ParkPlugin extends JavaPlugin {
    public static final String SOURCE_TAG = "b925e1743a3a";
    private static final Map<String, String> DOGS = new LinkedHashMap<String, String>();
    private static final Map<String, String> BENCHES = new LinkedHashMap<String, String>();
    private static final Map<String, String> SEATS = new LinkedHashMap<String, String>();

    public static BoundingBox corgiHitbox() { return new BoundingBox(-0.45, 0.0, -0.35, 0.45, 1.0, 0.35); }
    public static BoundingBox benchHitbox() { return new BoundingBox(0.0, 0.0, 0.0, 1.0, 0.75, 1.0); }

    public static boolean spawnCorgi(String id) {
        return false;
    }
    public static boolean placeBench(String id) {
        return false;
    }
    public static boolean interact(String playerId, String benchId) {
        return false;
    }
    public static boolean setCorgiState(String id, String state) {
        return false;
    }
    public static String snapshot() {
        return DOGS.size() + ":" + BENCHES.size() + ":" + SEATS.size() + ":" + (SEATS.containsKey("bench-1") ? SEATS.get("bench-1") : "");
    }
    public static void resetForReload() { DOGS.clear(); BENCHES.clear(); SEATS.clear(); }
}
