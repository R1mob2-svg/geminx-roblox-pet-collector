--!strict
-- GeminX Pet Collector — shared game configuration.

export type Zone = {
	name: string,
	minLevel: number,
	starValue: number,
	colour: Color3,
}

export type EggDef = {
	name: string,
	cost: number,
	rarityWeights: { [string]: number },
}

export type Config = {
	zones: { Zone },
	eggs: { [string]: EggDef },
	startLevel: number,
	checkpointSaveKey: string,
	playerLevelAttribute: string,
}

local GameConfig: Config = {
	startLevel = 1,
	checkpointSaveKey = "PetCollector_Checkpoint",
	playerLevelAttribute = "CollectorLevel",

	-- Rainbow world zones, unlocked by level and remembered via checkpoints.
	zones = {
		{ name = "Rainbow Meadow", minLevel = 1,  starValue = 1, colour = Color3.fromRGB(255, 90, 120) },
		{ name = "Shimmer Groves", minLevel = 3,  starValue = 2, colour = Color3.fromRGB(255, 200, 60) },
		{ name = "Prism Peaks",   minLevel = 5,  starValue = 3, colour = Color3.fromRGB(80, 220, 160) },
		{ name = "Aurora Falls",  minLevel = 8,  starValue = 4, colour = Color3.fromRGB(80, 160, 255) },
		{ name = "Nebula Core",   minLevel = 12, starValue = 5, colour = Color3.fromRGB(180, 120, 255) },
	},

	eggs = {
		Common = {
			cost = 50,
			rarityWeights = {
				Common   = 70,
				Uncommon = 20,
				Rare     = 8,
				Epic     = 2,
			},
		},
		RareGacha = {
			cost = 250,
			rarityWeights = {
				Common   = 20,
				Uncommon = 40,
				Rare     = 25,
				Epic     = 10,
				Legendary = 5,
			},
		},
	},
}

-- Ordered rarity list — index 1 is common, higher index = rarer reward.
export type RarityList = { string }

local RARITY_ORDER: RarityList = {
	"Common",
	"Uncommon",
	"Rare",
	"Epic",
	"Legendary",
}

return {
	GameConfig = GameConfig,
	RARITY_ORDER = RARITY_ORDER,
	RARITY_ORDER_BY_NAME = function(name: string): number
		for index, rarity in ipairs(RARITY_ORDER) do
			if rarity == name then
				return index
			end
		end
		return 0
	end,
}
