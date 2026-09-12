import java.util.*;
public final class BenchmarkFeature {
    public static final String SOURCE_TAG = "b925e1743a3a";
    private final LinkedHashSet<String> changes = new LinkedHashSet<String>();
    public boolean apply(String id) { if (id == null || id.trim().isEmpty()) return false; return changes.add(id); }
    public boolean ready() { return changes.size() >= 2; }
    public List<String> snapshot() { ArrayList<String> out = new ArrayList<String>(changes); Collections.sort(out); return out; }
}
