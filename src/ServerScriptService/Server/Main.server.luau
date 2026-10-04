--[[
	Server entry point. Every module in ./Services can have:
	  init()  - runs first, in the order below (connect events, prepare data)
	  start() - runs after every init(), each in its own thread (may yield)
	To add a system: create Services/MyService.luau and add its name to ORDER.
]]

local Services = script.Parent:WaitForChild("Services")

local ORDER = {
	"AssetPrepService",
	"AnimationService",
	"HatService",
	"CharacterService",
	"SelfTestService",
}

local loaded = {}
for _, name in ORDER do
	local module = Services:FindFirstChild(name)
	if module then
		loaded[name] = require(module)
	else
		warn(`[Main] Missing service {name}`)
	end
end

for _, name in ORDER do
	local service = loaded[name]
	if service and service.init then
		service.init()
	end
end

for _, name in ORDER do
	local service = loaded[name]
	if service and service.start then
		task.spawn(service.start)
	end
end

print("[Main] Mailman server ready")
