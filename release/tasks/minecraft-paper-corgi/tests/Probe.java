public class Probe {
    public static void main(String[] args) throws Exception {
        if (!com.gameforge.park.ParkPlugin.SOURCE_TAG.equals("b925e1743a3a"))
            throw new IllegalStateException("source tag");
        org.bukkit.util.BoundingBox dog = com.gameforge.park.ParkPlugin.corgiHitbox();
        if ((dog.getMaxY() - dog.getMinY()) != 1.0)
            throw new IllegalStateException("corgi bounds");
        org.bukkit.util.BoundingBox bench = com.gameforge.park.ParkPlugin.benchHitbox();
        if ((bench.getMaxX() - bench.getMinX()) != 1.0 || (bench.getMaxZ() - bench.getMinZ()) != 1.0)
            throw new IllegalStateException("bench bounds");
        if (!com.gameforge.park.ParkPlugin.spawnCorgi("corgi-1") || !com.gameforge.park.ParkPlugin.placeBench("bench-1"))
            throw new IllegalStateException("register");
        if (com.gameforge.park.ParkPlugin.spawnCorgi("corgi-1") || com.gameforge.park.ParkPlugin.placeBench("bench-1"))
            throw new IllegalStateException("duplicate register");
        if (!com.gameforge.park.ParkPlugin.setCorgiState("corgi-1", "playing") || !com.gameforge.park.ParkPlugin.setCorgiState("corgi-1", "idle"))
            throw new IllegalStateException("corgi transition");
        if (!com.gameforge.park.ParkPlugin.interact("player-1", "bench-1"))
            throw new IllegalStateException("seat");
        if (com.gameforge.park.ParkPlugin.interact("player-1", "bench-1") || com.gameforge.park.ParkPlugin.interact("", "bench-1") || com.gameforge.park.ParkPlugin.interact("player-2", "missing"))
            throw new IllegalStateException("interaction boundary");
        if (!com.gameforge.park.ParkPlugin.snapshot().startsWith("1:1:1:player-1"))
            throw new IllegalStateException("snapshot");
        com.gameforge.park.ParkPlugin.resetForReload();
        if (!com.gameforge.park.ParkPlugin.snapshot().equals("0:0:0:"))
            throw new IllegalStateException("reload");
        System.out.println("MINECRAFT_PAPER_PARK_PROBE_OK");
    }
}
