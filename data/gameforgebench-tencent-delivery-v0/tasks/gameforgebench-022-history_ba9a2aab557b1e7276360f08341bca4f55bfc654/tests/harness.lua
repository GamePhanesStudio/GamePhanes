local function new_instance(class_name)
    local value = {ClassName = class_name, Name = "", Parent = nil}
    return value
end
Instance = {new = new_instance}
local Knit = require("./src/ReplicatedStorage/Knit")
local PingService = require("./src/ReplicatedStorage/Services/PingService")
local PingController = require("./src/ReplicatedStorage/Controllers/PingController")
if PingService.SOURCE_TAG ~= "34e4ec1bf6d9" then error("source tag") end
local service = PingService.new(Instance)
local knit = Knit.new(Instance)
knit:register("PingService", service)
if not knit:start() or not knit.started then error("knit start") end
local controller = PingController.new(service)
local first = controller:request("player-1", "nonce-1")
if not first or not first.ok or first.nonce ~= "nonce-1" then error("rpc") end
if controller:request("player-1", "nonce-1") ~= nil then error("duplicate") end
if controller:request("", "nonce-2") ~= nil or controller:request("player-1", "") ~= nil then error("invalid") end
if service:snapshot().calls ~= 1 then error("count") end
service:reset()
if service:snapshot().calls ~= 0 then error("reset") end
if not controller:request("player-1", "nonce-1") then error("post reset") end
print("ROBLOX_KNIT_RUNTIME_OK")
