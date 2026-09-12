public class Probe {
    public static void main(String[] args) throws Exception {
        if (!com.gameforge.chair.ChairPlugin.SOURCE_TAG.equals("7a67866ae705"))
            throw new IllegalStateException("source tag");
        org.bukkit.util.BoundingBox box = com.gameforge.chair.ChairPlugin.chairHitbox();
        if ((box.getMaxX() - box.getMinX()) != 1.0 || (box.getMaxY() - box.getMinY()) != 1.0 || (box.getMaxZ() - box.getMinZ()) != 1.0)
            throw new IllegalStateException("hitbox");
        if (!com.gameforge.chair.ChairPlugin.handleChairInteract("player-1"))
            throw new IllegalStateException("first interaction");
        if (com.gameforge.chair.ChairPlugin.handleChairInteract("player-1"))
            throw new IllegalStateException("duplicate interaction");
        if (com.gameforge.chair.ChairPlugin.handleChairInteract(""))
            throw new IllegalStateException("empty id");
        if (!com.gameforge.chair.ChairPlugin.snapshot().startsWith("1:player-1"))
            throw new IllegalStateException("state");
        com.gameforge.chair.ChairPlugin.resetForReload();
        if (!com.gameforge.chair.ChairPlugin.snapshot().equals("0:"))
            throw new IllegalStateException("reload");
        System.out.println("MINECRAFT_PAPER_PROBE_OK");
    }
}
