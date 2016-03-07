local addon, Pesky = ...

Pesky.Minions = {}
local Minions = Pesky.Minions

local levelStat =
{
	[1] = 1 + 1,
	[2] = 1 + 2,
	[2] = 1 + 3,
	[4] = 2 + 4,
	[5] = 2 + 5,
	[6] = 2 + 6,
	[7] = 3 + 7,
	[8] = 3 + 7,
	[9] = 4 + 8,
	[10] = 4 + 9,
	[11] = 4 + 10,
	[12] = 4 + 11,
	[13] = 5 + 11,
	[14] = 5 + 12,
	[15] = 5 + 12,
	[16] = 6 + 13,
	[17] = 6 + 14,
	[18] = 6 + 14,
	[19] = 6 + 15,
	[20] = 6 + 16,
	[21] = 6 + 16,
	[22] = 6 + 16,
	--[23] = ???
	[24] = 6 + 17,
	[25] = 7 + 18
}

local statList =
{
	-- elements: erde < luft < feuer < wasser < leben < tod
	-- tasks: jagd < dipl < ernte < dim < arte < mord
	"statAir",
	"statArtifact",
	"statAssassination",
	"statDeath",
	"statDimension",
	"statDiplomacy",
	"statEarth",
	"statExploration", -- ???
	"statFire",
	"statHarvest",
	"statHunting",
	"statLife",
	"statWater"
}
-- we actually want a descending list, so return first <better> second
function compareScore(first, second)
	if first.score == second.score then
		return first.minion.stamina > second.minion.stamina
	else
		return first.score > second.score
	end
end

function Minions.GetSuitableMinions(adventure)
	local list = {}
	for id, details in pairs(Pesky.minionDB) do
		local m_score = Minions.GetScore(adventure, details)
		if m_score > 0 then
			table.insert(list, { score = m_score, minion = details })
		end
	end
	table.sort(list, compareScore)
	return list
end

function Minions.GetScore(adventure, minion)
	local sum = 0
	for _, stat in pairs(statList) do
		if adventure[stat] and minion[stat] then
			sum = sum + minion[stat]
		end
	end
	return sum
end
