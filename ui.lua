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
	stamina = "Minion_I158.dds", -- 128x128, 15B, 24, 27
	aventurin = "Minion_I2C9.dds",
	-- stats
	-- elements
	statEarth = "Minion_I28.dds", -- 28, 2B, 13E, 141
	statAir = "Minion_I2A.dds", -- 2A, 2D, 140, 143
	statFire = "Minion_I2C.dds",-- 16x32: 2C, 2F, 142, 145
	statWater = "Minion_I2E.dds", -- 16x32: 2E, 31, 144, 147
	statLife = "Minion_I30.dds", -- 30, 33, 146, 149
	statDeath = "Minion_I32.dds", -- 32, 35, 148, 14B
	-- tasks
	statHunting = "Minion_I34.dds", -- 34, 37, 14A(?), 14D
	statDiplomacy = "Minion_I36.dds", -- 36, 39, 14C, 14F
	statHarvest = "Minion_I38.dds", -- 38, 3B, 14E, 151
	statDimension = "Minion_I3A.dds", -- 3A, 3D, 150, 153
	statArtifact = "Minion_I3C.dds", -- 3C, 3F, 152, 155
	statAssassination = "Minion_I3E.dds", -- 3E, 41, 140, 157
--	"statExploration",
	-- adventures
	chain_adventure = "Minion_I1BA.dds", -- =1CA, 64x32; 512x256: 1BD
	halloween_spider = "Minion_I19E.dds" -- 1B1
}

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

	widget.level_plate = UI.CreateFrame("Texture", name .. "level_plate", widget)
	widget.level_plate:SetPoint("BOTTOMCENTER", widget.icon_border, "BOTTOMCENTER", 0, 1)
	widget.level_plate:SetTexture("Rift", images.level_plate)
	widget.level_plate:SetWidth(30)
	widget.level_plate:SetHeight(19)
	widget.level_plate:SetLayer(30)

	widget.level_text = UI.CreateFrame("Text", name .. "level", widget)
	widget.level_text:SetPoint("BOTTOMCENTER", widget.icon_border, "BOTTOMCENTER", 0, 1)
	widget.level_text:SetFont("Rift", "$Flareserif_light")
	widget.level_text:SetFontColor(1, 1, 1)
	widget.level_text:SetText("25")
	widget.level_text:SetLayer(40)

	widget.name_text = UI.CreateFrame("Text", name .. "name", widget)
	widget.name_text:SetPoint("TOPLEFT", widget, "TOPLEFT", 64, 3)
	widget.name_text:SetWidth(128)

	widget.SetMinionDisplay = Pesky.UI.SetMinionDisplay
	return widget
end

function Pesky.UI.SetMinionDisplay(widget, details)
	--local details = Pesky.minionDB[minion]
	local border_img = icon_border[details.rarity] or icon_border.common
	widget.icon_border:SetTexture("Rift", border_img)
	local icon = images.placeholder
	if Pesky.Data.Minion[details.id] and Pesky.Data.Minion[details.id].icon then
		icon = Pesky.Data.Minion[details.id].icon .. ".dds"
	end
	widget.icon:SetTexture("Rift", icon)
	widget.level_text:SetText(tostring(details.level))
	widget.name_text:SetText(details.name or "N/A")
end

function Pesky.UI.CreateMinionList()
	Pesky.UI.minionWidget = UI.CreateFrame("Frame", "Pesky_minion_widget", Pesky.context)
	Pesky.UI.minionWidget:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 600, 50)
	Pesky.UI.minionList = {}
	for i = 1, Pesky.UI.listBestN do
		Pesky.UI.minionList[i] = Pesky.UI.CreateMinionIcon("frame" .. i, Pesky.UI.minionWidget)
		Pesky.UI.minionList[i]:SetPoint("TOPLEFT", Pesky.UI.minionWidget, "TOPLEFT", 0, 64*(i-1))
	end
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
			Pesky.UI.minionList[i]:SetMinionDisplay(suitable[i].minion)
			Pesky.UI.minionList[i]:SetVisible(true)
		end
	end
end
