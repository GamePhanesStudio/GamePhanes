local remote={count=0}; function remote:FireAllClients(...) self.count=self.count+1 end

local Stats=require("./src/ReplicatedStorage/PlayerStats")

local Leader=require("./src/ReplicatedStorage/RoundLeader")

if Stats.SOURCE_TAG~="9aec007bbc6e" then error("tag") end

local stats=Stats.new(remote); local leader=Leader.new(stats)

if not stats:record_drops("p1",10) or not stats:record_drops("p2",20) then error("record")
end

if leader:leader().id~="p2" or remote.count~=2 then error("leader") end

if stats:record_drops("p2",30) or stats:record_drops("",4) or stats:record_drops("p3",0)
then error("boundary") end

local copy=stats:snapshot(); copy.players.p1.Drops=999

if stats:snapshot().players.p1.Drops~=10 then error("copy") end

stats:next_round()

if leader:leader()~=nil or next(stats:snapshot().players)~=nil then error("reset")
end

if not stats:record_drops("p1",5) or leader:leader().id~="p1" then error("new round") end

print("ROBLOX_DROPS_LEADER_RUNTIME_OK")
