local addon, Pesky = ...

Pesky.Minions = {}
local Minions = Pesky.Minions

local levelStat =
{
	[1] = 1 + 1,
	[2] = 1 + 2,
	[3] = 1 + 3,
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
	[23] = 6 + 17,
	[24] = 6 + 17,
	[25] = 7 + 18
}

local statList =
{
	-- elements: erde < luft < feuer < wasser < leben < tod
	"statEarth",
	"statAir",
	"statFire",
	"statWater",
	"statLife",
	"statDeath",
	-- tasks: jagd < dipl < ernte < dim < arte < mord
	"statHunting",
	"statDiplomacy",
	"statHarvest",
	"statDimension",
	"statArtifact",
	"statAssassination",
	"statExploration" -- ???
}
Pesky.statList = statList

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
	local requirement_dat = Pesky.Data.Adventure_Requirements
	for id, details in pairs(Pesky.minionDB) do
		-- check requirements
		local suitable = true
		local reqs = requirement_dat[adventure.id]
		if reqs then
			if type(reqs.minion) == "table" and not reqs.minion[id] then
				suitable = false
			end
			if suitable and type(reqs.stat) == "table" then
				local has_stat = false
				for stat, _ in pairs(reqs.stat) do
					if details[stat] then has_stat = true end
				end
				suitable = has_stat
			end
			if suitable and type(reqs.level) == "number" and details.level < reqs.level then
				suitable = false
			end
		end
		-- get score
		if suitable then
			local m_score, m_real_score = Minions.GetScore(adventure, details)
			if m_score > 0 then
				table.insert(list, { score = m_score, real_score = m_real_score, minion = details })
			end
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
	-- test --
	if sum > 2 and minion.level < 25 then
		local scaled_score = levelStat[25] * sum / levelStat[minion.level]
		return scaled_score, sum
	end
	return sum, sum
end
