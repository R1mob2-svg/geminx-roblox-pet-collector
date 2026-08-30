--!strict
-- GeminX Pet Collector — server game loop.
-- Handles star collection, leveling, zone unlocking and checkpoint saves.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("GeminX"):WaitForChild("Shared")
local ConfigModule = require(Shared.GameConfig)
local GameConfig = ConfigModule.GameConfig

local PetHatch = require(script.Parent.PetHatch)
local Checkpoints = require(script.Parent.Checkpoints)

local RemoteEvents = Instance.new("Folder")
RemoteEvents.Name = "GeminXRemoteEvents"
RemoteEvents.Parent = ReplicatedStorage

-- Server -> client: HUD refresh, zone unlock announcement, rare reward notice.
local HUDUpdate = Instance.new("RemoteEvent")
HUDUpdate.Name = "HUDUpdate"
HUDUpdate.Parent = RemoteEvents

local ZoneUnlock = Instance.new("RemoteEvent")
ZoneUnlock.Name = "ZoneUnlock"
ZoneUnlock.Parent = RemoteEvents

local RareReward = Instance.new("RemoteEvent")
RareReward.Name = "RareReward"
RareReward.Parent = RemoteEvents

-- Client -> server: collect a star, buy/hatch an egg.
local CollectStar = Instance.new("RemoteEvent")
CollectStar.Name = "CollectStar"
CollectStar.Parent = RemoteEvents

local HatchEgg = Instance.new("RemoteEvent")
HatchEgg.Name = "HatchEgg"
HatchEgg.Parent = RemoteEvents

local playerData: { [number]: { level: number, stars: number, pets: { { name: string, rarity: string } } } } = {}

local function zoneForLevel(level: number): number
	local unlocked = 1
	for index, zone in ipairs(GameConfig.zones) do
		if level >= zone.minLevel then
			unlocked = index
		end
	end
	return unlocked
end

local function refresh(player: Player, target: Player)
	local data = playerData[target.UserId]
	if not data then
		return
	end
	HUDUpdate:FireClient(target, {
		level = data.level,
		stars = data.stars,
		highestZone = Checkpoints.getHighestZone(target.UserId),
		zoneName = GameConfig.zones[zoneForLevel(data.level)].name,
	})
end

local function onCollectStar(player: Player)
	local data = playerData[player.UserId]
	if not data then
		return
	end

	local zoneIndex = zoneForLevel(data.level)
	local zone = GameConfig.zones[zoneIndex]
	data.stars += zone.starValue

	-- Level up roughly every 5 stars.
	if data.stars >= data.level * 5 then
		data.level += 1
		data.stars = 0
		-- Checkpoint: record the newly unlocked zone if a new one opened.
		local justUnlocked = zoneForLevel(data.level)
		if justUnlocked > zoneIndex then
			local highest = Checkpoints.recordUnlock(player.UserId, justUnlocked)
			ZoneUnlock:FireClient(player, {
				zoneName = GameConfig.zones[justUnlocked].name,
				zoneIndex = justUnlocked,
				highest = highest,
				range = justUnlocked .. ' of ' .. #GameConfig.zones,
			})
		end
	end

	refresh(player, player)
end

local function onHatchEgg(player: Player, eggName: string)
	local data = playerData[player.UserId]
	if not data then
		return
	end

	local egg = GameConfig.eggs[eggName]
	if not egg or data.stars < egg.cost then
		return -- insufficient stars or unknown egg
	end

	data.stars -= egg.cost

	local pet = PetHatch.hatch(eggName)
	table.insert(data.pets, pet)

	-- Reveal rare rewards and give a bonus for discovery.
	if PetHatch.isRareReward(pet.rarity) then
		data.stars += 10
		RareReward:FireClient(player, {
			petName = pet.name,
			rarity = pet.rarity,
			bonusStars = 10,
		})
	end

	refresh(player, player)
end

Players.PlayerAdded:Connect(function(player)
	playerData[player.UserId] = {
		level = GameConfig.startLevel,
		stars = 0,
		pets = {},
	}

	CollectStar.OnServerEvent:Connect(function(caller, ...)
		if caller == player then
			onCollectStar(player)
		end
	end)

	HatchEgg.OnServerEvent:Connect(function(caller, eggName)
		if caller == player and typeof(eggName) == "string" then
			onHatchEgg(player, eggName)
		end
	end)

	Coroutine.wrap(function()
		task.wait(1)
		refresh(player, player)
	end)()
end)

Players.PlayerRemoving:Connect(function(player)
	playerData[player.UserId] = nil
end)

return {
	getZoneForLevel = zoneForLevel,
}
