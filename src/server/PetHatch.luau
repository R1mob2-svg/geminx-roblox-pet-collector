--!strict
-- GeminX Pet Collector — pet egg hatching with weighted rarity rewards.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("GeminX"):WaitForChild("Shared")
local ConfigModule = require(Shared.GameConfig)

local GameConfig = ConfigModule.GameConfig
local RARITY_ORDER = ConfigModule.RARITY_ORDER
local RARITY_ORDER_BY_NAME = ConfigModule.RARITY_ORDER_BY_NAME

local PetHatch = {}

local PET_NAMES: { [string]: string } = {
	Common = "Dazzle Spud",
	Uncommon = "Bubble Wisp",
	Rare = "Prism Fox",
	Epic = "Aurora Drake",
	Legendary = "Nebula Sovereign",
}

-- Weighted random selection over an egg's rarity table.
function PetHatch.rollRarity(eggName: string): string
	local egg = GameConfig.eggs[eggName]
	if not egg then
		return "Common"
	end

	local total = 0
	for _, weight in pairs(egg.rarityWeights) do
		total += weight
	end

	local roll = math.random() * total
	local accumulator = 0
	for rarity, weight in pairs(egg.rarityWeights) do
		accumulator += weight
		if roll <= accumulator then
			return rarity
		end
	end
	return "Common"
end

-- Hatches a pet and returns its name + rarity tier.
function PetHatch.hatch(eggName: string): { name: string, rarity: string }
	local rarity = PetHatch.rollRarity(eggName)
	return {
		name = PET_NAMES[rarity] or "Mystery Pet",
		rarity = rarity,
	}
end

-- Returns whether the hatched rarity is "rare reward" worthy (>= Rare tier).
function PetHatch.isRareReward(rarity: string): boolean
	return RARITY_ORDER_BY_NAME(rarity) >= RARITY_ORDER_BY_NAME("Rare")
end

return PetHatch
