local addon, Pesky = ...

Pesky.UI =
{
	listBestN = 4
}
Pesky.context = UI.CreateContext("Pesky")

local icon_border =
{
	common = "icon_border.dds",
	uncommon = "icon_border_uncommon.dds",
	rare = "icon_border_rare.dds",
	epic = "icon_border_epic.dds",
	relic = "icon_border_relic.dds",
	transcendant = "icon_border_transcended.dds",
	heirloom = "icon_border_heirloom.dds"
}

local images =
{
	placeholder = "placeholder_icon.dds",
	level_plate = "Minion_IFA.dds", -- "Minion_IFD.dds" identical
	bg_overlay = "Minion_I273.dds",
	stamina = "Minion_I24.dds", -- 128x128, 24, 27, 158, 15B
	aventurin = "Minion_I2C9.dds",
	magnet = { asset = "minion_magnet.png.dds", height = 25, width = 28 },
	-- stats
	-- elements
	statEarth = { asset = "Minion_I28.dds", height = 18, width = 17 }, -- 28, 2B, 13E, 141	-- 16x17 ? 17x17 ?
	statAir = { asset = "Minion_I2A.dds", height = 17, width = 18 }, -- 2A, 2D, 140, 143	 -- 15x17 ?
	statFire = { asset = "Minion_I2C.dds", height = 18, width = 15 },-- 16x32: 2C, 2F, 142, 145		-- 14x17 ?
	statWater = { asset = "Minion_I2E.dds", height = 18, width = 12 }, -- 16x32: 2E, 31, 144, 147	 -- 11x17
	statLife = { asset = "Minion_I30.dds", height = 18, width = 18 }, -- 30, 33, 146, 149
	statDeath = { asset = "Minion_I32.dds", height = 18, width = 18 }, -- 32, 35, 148, 14B
	-- tasks
	statHunting = { asset = "Minion_I34.dds", height = 18, width = 18 }, -- 34, 37, 14A(?), 14D	-- 16x17 ?
	statDiplomacy = { asset = "Minion_I36.dds", height = 18, width = 17 }, -- 36, 39, 14C, 14F	 -- 15x17
	statHarvest = { asset = "Minion_I38.dds", height = 17, width = 18 }, -- 38, 3B, 14E, 151		--	17x17
	statDimension = { asset = "Minion_I3A.dds", height = 18, width = 18 }, -- 3A, 3D, 150, 153	-- 17x17
	statArtifact = { asset = "Minion_I3C.dds", height = 18, width = 18 }, -- 3C, 3F, 152, 155
	statAssassination = { asset = "Minion_I3E.dds", height = 18, width = 18 }, -- 3E, 41, 140, 157  -- 17x17
--	"statExploration",
	-- adventures
	rewardHunting = "Minion_IC6.dds",
	rewardDiplomacy = "Minion_IC8.dds",
	rewardHarvest = "Minion_ICA.dds",
	rewardDimension = "Minion_ICC.dds",
	rewardArtifact = "Minion_ICE.dds",
	rewardAssassination = "Minion_ID4.dds",
	rewardHalloween = "Minion_IE0.dds",
	rewardFaeYule = "Minion_IE9.dds",
	rewardSummer = "Minion_IEB.dds",
	rewardCarnival = "Minion_IED.dds",

	chain_adventure = "Minion_I1BA.dds", -- =1CA, 64x32; 512x256: 1BD
	halloween_spider = "Minion_I19E.dds" -- 1B1
}

function Pesky.UI.RightClickhandler(frame, hEvent)
	-- TODO: Slot setting, now only 5/15/20m slot
	local adventure = Pesky.advDeck[2]
	if frame.minion_id and adventure then
		print(string.format("Sending %s on %s", frame.minion_id, adventure.name))
		Command.Minion.Send(frame.minion_id, adventure.id, "none")
	end
end

function Pesky.UI.CreateIcon(name, parent, width, height, texture, resource)
	local icon = UI.CreateFrame("Texture", name , parent)
	icon:SetTexture(resource or "Rift", texture)
	if width then
		icon:SetWidth(width)
	end
	if height then
		icon:SetHeight(height)
	end
	return icon
end

function Pesky.UI.SetIcon(frame, image)
	frame:SetTexture(image.resource or "Rift", image.asset)
	if image.width then frame:SetWidth(image.width) end
	if image.height then frame:SetHeight(image.height) end
end

function Pesky.UI.CreateMinionIcon(name, parent)
	local widget = UI.CreateFrame("Frame", name, parent)
	widget:SetWidth(192)
	widget:SetHeight(64)
	widget.icon = UI.CreateFrame("Texture", name .. "icon", widget)
	widget.icon:SetPoint("TOPLEFT", widget, "TOPLEFT", 8, 8)
	widget.icon:SetTexture("Rift", "ability_icons\\spiritbolt2.dds") -- images.placeholder)

	widget.icon_border = UI.CreateFrame("Texture", name .. "icon", widget)
	widget.icon_border:SetPoint("TOPLEFT", widget, "TOPLEFT")
	widget.icon_border:SetTexture("Rift", icon_border.rare)
	widget.icon_border:SetLayer(20)

	--widget.level_plate = UI.CreateFrame("Texture", name .. "level_plate", widget)
	widget.level_plate = Pesky.UI.CreateIcon(name .. "level_plate", widget, 30, 19, images.level_plate)
	widget.level_plate:SetPoint("BOTTOMCENTER", widget.icon_border, "BOTTOMCENTER", 0, 1)
	--widget.level_plate:SetTexture("Rift", images.level_plate)
	--widget.level_plate:SetWidth(30)
	--widget.level_plate:SetHeight(19)
	widget.level_plate:SetLayer(30)

	widget.magnet = Pesky.UI.CreateIcon(name .. "attractor", widget, images.magnet.width, images.magnet.height, images.magnet.asset)
	widget.magnet:SetPoint("TOPLEFT", widget.icon_border, "TOPLEFT", 30, 8)
	widget.magnet:SetLayer(35)

	widget.level_text = UI.CreateFrame("Text", name .. "level", widget)
	widget.level_text:SetPoint("BOTTOMCENTER", widget.icon_border, "BOTTOMCENTER", 0, 1)
	widget.level_text:SetFont("Rift", "$Flareserif_light")
	widget.level_text:SetFontColor(1, 1, 1)
	widget.level_text:SetText("25")
	widget.level_text:SetLayer(40)

	widget.name_text = UI.CreateFrame("Text", name .. "name", widget)
	widget.name_text:SetPoint("TOPLEFT", widget, "TOPLEFT", 64, 3)
	widget.name_text:SetWidth(128)

	--widget.stamina_icon = UI.CreateFrame("Texture", name .. "stamina_icon", widget)
	widget.stamina_icon = Pesky.UI.CreateIcon(name .. "stamina_icon", widget, 24, 24, images.stamina)
	widget.stamina_icon:SetPoint("TOPRIGHT", widget, "TOPRIGHT")
	--widget.stamina_icon:SetTexture("Rift", images.stamina)
	--widget.stamina_icon:SetWidth(32)
	--widget.stamina_icon:SetHeight(32)

	widget.stamina = UI.CreateFrame("Text", name .. "stamina", widget)
	widget.stamina:SetPoint("TOPRIGHT", widget.stamina_icon, "BOTTOMRIGHT")

	widget.score = UI.CreateFrame("Text", name .. "score", widget)
	widget.score:SetPoint("TOPRIGHT", widget.stamina, "BOTTOMRIGHT")

	widget:EventAttach(Event.UI.Input.Mouse.Right.Click, Pesky.UI.RightClickhandler, name .. "_right_click")
	widget.SetMinionDisplay = Pesky.UI.SetMinionDisplay
	return widget
end

function Pesky.UI.SetMinionDisplay(widget, details, score)
	widget.minion_id = details.id
	--local details = Pesky.minionDB[minion]
	local border_img = icon_border[details.rarity] or icon_border.common
	widget.icon_border:SetTexture("Rift", border_img)
	local icon = images.placeholder
	local db_entry = Pesky.Data.Minion[details.id]
	if db_entry then
		if db_entry.icon  then
			icon = Pesky.Data.Minion[details.id].icon .. ".dds"
		end
		if db_entry.attractorType then
			widget.magnet:SetVisible(true)
		else
			widget.magnet:SetVisible(false)
		end
	end
	widget.icon:SetTexture("Rift", icon)
	widget.level_text:SetText(tostring(details.level))
	widget.name_text:SetText(details.name or "N/A")
	if Pesky.minionWorking[details.id] then
		widget.name_text:SetFontColor(1, 0, 0)
	else
		widget.name_text:SetFontColor(1, 1, 1)
	end
	widget.stamina:SetText(string.format("%i/%i", details.stamina, details.staminaMax))
	widget.score:SetText(string.format("%.0f", score))
end

function Pesky.UI.CreateMinionList()
	Pesky.UI.minionWidget = UI.CreateFrame("Frame", "Pesky_minion_widget", Pesky.context)
	Pesky.UI.minionWidget:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, 400)
	Pesky.UI.minionList = {}
	for i = 1, Pesky.UI.listBestN do
		Pesky.UI.minionList[i] = Pesky.UI.CreateMinionIcon("frame" .. i, Pesky.UI.minionWidget)
		Pesky.UI.minionList[i]:SetPoint("TOPLEFT", Pesky.UI.minionWidget, "TOPLEFT", 0, 64*(i-1))
	end
end
-------------
-- Card Deck
-------------

function Pesky.UI.CreateCard(name, parent)
	local widget = UI.CreateFrame("Frame", name, parent)
	widget:SetWidth(64)
	widget:SetHeight(64)

	widget.duration = UI.CreateFrame("Text", name .. "duration", widget)
	widget.duration:SetPoint("TOPCENTER", widget, "TOPCENTER", 0, 4)

	widget.attribute1 = Pesky.UI.CreateIcon(name .. "attr_1", widget, 18, 18, images.placeholder)
	widget.attribute1:SetPoint("TOPLEFT", widget, "TOPLEFT", 14, 44)

	widget.attribute2 = Pesky.UI.CreateIcon(name .. "attr_2", widget, 18, 18, images.placeholder)
	widget.attribute2:SetPoint("TOPLEFT", widget, "TOPLEFT", 34, 44)

	widget.SetCardDisplay = Pesky.UI.SetCardDisplay
	return widget
end

function Pesky.UI.SetCardDisplay(widget, details)
	local cardStats = {}
	for idx, stat in ipairs(Pesky.statList) do
		if details[stat] then
			table.insert(cardStats, stat)
		end
	end
	if cardStats[1] then
		Pesky.UI.SetIcon(widget.attribute1, images[cardStats[1]])
	end
	if cardStats[2] then
		Pesky.UI.SetIcon(widget.attribute2, images[cardStats[2]])
	end
	local duration = details.duration / 60
	if duration < 60 then
		widget.duration:SetText(string.format("%im", duration))
	else
		widget.duration:SetText(string.format("%ih", duration/60))
	end
end

function Pesky.UI.UpdateCardDisplay(adventure_details)
	-- TODO: decide about deck display/card selection
	if not Pesky.MinionCard0 then
		return
	end
	Pesky.MinionCard0:SetCardDisplay(adventure_details)
end

function Pesky.UI.UpdateSuitableMinions(adventure_details)
	-- TODO: review widget initialization
	if not Pesky.UI.minionWidget then
		Pesky.UI.CreateMinionList()
	end
	local suitable = Pesky.Minions.GetSuitableMinions(adventure_details)
	local n_suitable = #suitable
	for i = 1, Pesky.UI.listBestN do
		if i > n_suitable then
			Pesky.UI.minionList[i]:SetVisible(false)
		else
			Pesky.UI.minionList[i]:SetMinionDisplay(suitable[i].minion, suitable[i].real_score)
			Pesky.UI.minionList[i]:SetVisible(true)
		end
	end
end
