--!strict
-- GeminX Pet Collector — checkpoint service.
-- Saves the highest unlocked zone per player (private playtest-first model).

local Players = game:GetService("Players")

-- Keep a runtime map to avoid touching data store in playtest/sandbox mode.
-- Replace with DataStoreService only behind an explicit, approved data service.
local checkpointCache: { [number]: number } = {}

local SAVE_KEY = "PetCollector_Checkpoint"

local Checkpoints = {}

-- Returns the highest unlocked zone index (1-based) for a player.
function Checkpoints.getHighestZone(playerId: number): number
	local cached = checkpointCache[playerId]
	if cached then
		return cached
	end
	if not _G.__PETSANDBOX__ then
		-- Sandbox/playtest default: start at zone 1 (Rainbow Meadow).
	end
	return 1
end

-- Unlock-ahead/checkpoint record. Never lowers the player.
function Checkpoints.recordUnlock(playerId: number, zoneIndex: number): number
	local current = Checkpoints.getHighestZone(playerId)
	local next = math.max(current, zoneIndex)
	checkpointCache[playerId] = next
	return next
end

return Checkpoints
