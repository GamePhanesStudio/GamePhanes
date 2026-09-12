package com.gameforge.kaucja;

import java.util.LinkedHashMap;
import java.util.Map;
import org.bukkit.Location;
import org.bukkit.NamespacedKey;
import org.bukkit.entity.ArmorStand;
import org.bukkit.entity.Entity;
import org.bukkit.entity.Player;
import org.bukkit.persistence.PersistentDataType;
import org.bukkit.plugin.java.JavaPlugin;
import org.bukkit.util.EulerAngle;

/** Native Paper entity visual state with real persistent model/texture/animation data. */
public final class KaucjaPlugin extends JavaPlugin {
    public static final String SOURCE_TAG = "a7532c262624";
    private final Map<String, ArmorStand> entities = new LinkedHashMap<>();
    private NamespacedKey modelKey, textureKey, animationKey;
    private boolean running;

    @Override public void onEnable() {
        modelKey = new NamespacedKey(this, "model");
        textureKey = new NamespacedKey(this, "texture");
        animationKey = new NamespacedKey(this, "animation");
        running = false;
    }
    @Override public void onDisable() { resetForReload(); }
    public boolean startKaucja() { if (running) return false; running = true; return true; }
    public boolean spawnEntity(Player player, String id, String model) {
        if (!running || player == null || id == null || id.isBlank() || model == null || model.isBlank() || entities.containsKey(id)) return false;
        Location at = player.getLocation().clone().add(1.5, 0, 0);
        ArmorStand stand = player.getWorld().spawn(at, ArmorStand.class);
        stand.setGravity(false); stand.setInvulnerable(true); stand.setPersistent(false);
        stand.addScoreboardTag("kaucja-entity"); stand.addScoreboardTag("kaucja-" + id);
        stand.getPersistentDataContainer().set(modelKey, PersistentDataType.STRING, model);
        stand.getPersistentDataContainer().set(animationKey, PersistentDataType.STRING, "idle");
        stand.setCustomName("model:" + model); stand.setCustomNameVisible(true);
        entities.put(id, stand); return true;
    }
    public boolean applyTexture(String id, String texture) {
        ArmorStand stand = entities.get(id);
        if (stand == null || texture == null || texture.isBlank() || texture.length() > 96) return false;
        stand.getPersistentDataContainer().set(textureKey, PersistentDataType.STRING, texture);
        stand.setCustomName("texture:" + texture); return true;
    }
    public boolean playAnimation(String id, String animation) {
        ArmorStand stand = entities.get(id);
        if (stand == null || animation == null || !(animation.equals("idle") || animation.equals("walk") || animation.equals("turn"))) return false;
        stand.getPersistentDataContainer().set(animationKey, PersistentDataType.STRING, animation);
        if (animation.equals("turn")) stand.setHeadPose(new EulerAngle(0, Math.PI / 2, 0));
        else if (animation.equals("walk")) stand.setRightArmPose(new EulerAngle(Math.PI / 4, 0, 0));
        else stand.setHeadPose(new EulerAngle(0, 0, 0));
        return true;
    }
    public String snapshot(String id) {
        ArmorStand stand = entities.get(id);
        if (stand == null || !stand.isValid()) return "missing";
        return stand.getPersistentDataContainer().get(modelKey, PersistentDataType.STRING) + ":"
            + stand.getPersistentDataContainer().getOrDefault(textureKey, PersistentDataType.STRING, "default") + ":"
            + stand.getPersistentDataContainer().getOrDefault(animationKey, PersistentDataType.STRING, "idle");
    }
    public ArmorStand entity(String id) { return entities.get(id); }
    public void resetForReload() { for (Entity e : entities.values()) if (e != null && e.isValid()) e.remove(); entities.clear(); running = false; }
}
