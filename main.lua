local addon, Pesky = ...

Pesky.availableAdv = {}
Pesky.advDeck = {} -- slots 1-4

function Pesky.TryFreeShuffle(adventure)
	Command.Minion.Shuffle(adventure, "none")
	--print("trying to shuffle: ", adventure)
end

function Pesky.UpdateAdventureDB(details)
	Pesky.lastAdventure = details.id
	if not Pesky_AdventureDB[details.id] then
		Pesky_AdventureDB[details.id] = details
	end
end

function Pesky.InitMinionDB()
	local list = Inspect.Minion.Minion.List()
	if not list or not next(list) then
		print("Minions not available yet!")
	end
	Pesky.minionDB = Inspect.Minion.Minion.Detail(list)
end

function Pesky.AddToDeck(details)
	local slot = Pesky.Adventure.GetSlot(details)
	if not slot then
		return
	end
	if Pesky.advDeck[slot] then
		print(string.format("Warning, slot %i was not empty!", slot))
	end
	Pesky.advDeck[slot] = details
end

function Pesky.RemoveFromDeck(details)
	for slot = 1, 4 do
		if Pesky.advDeck[slot] and Pesky.advDeck[slot].id == details.id then
			Pesky.advDeck[slot] = nil
			return
		end
	end
	print("could not find adventure in deck:")
	dump(details)
end

function Pesky.AdventureChangeHandler(hEvent, adventures)
	print("Adventure.Change")
	local details
	for id, unknown in pairs(adventures) do
		-- print(id, unknown)
		details = Inspect.Minion.Adventure.Detail(id)
		if details and details.mode == "available" then
			--print("new adventure:", details.name)
			Pesky.availableAdv[id] = details
			Pesky.AddToDeck(details)
			Pesky.UpdateAdventureDB(details)
			--if Pesky_AdventureBL[id] then
			--	print(string.format("Blacklist hit for: %s (%i) %s", id, details.duration, details.name))
			--end
			--local suitable = Pesky.Minions.GetSuitableMinions(details)
			--for i = 1, #suitable do
			--	print(suitable[i].minion.name, suitable[i].score)
			--	if i>3 then break end
			--end
			-- Test:
			Pesky.UI.UpdateSuitableMinions(details)
			-- EOTest
			Pesky.TryFreeShuffle(id)
		else
			if Pesky.availableAdv[id] then
				print("removing:", id, details ~= nil, details and details.mode)
				Pesky.availableAdv[id] = nil
			--else
			--	print("other update", id, details and details.mode)
			end
			Pesky.RemoveFromDeck(details)
		end
	end
end

function Pesky.CommandHandler(hEvent, command)
	if command == "available" then
		for id, details in pairs(Pesky.availableAdv) do
			print(string.format("%s (%i) %s", id, details.duration, details.name))
		end
		for slot = 1, 4 do
			local details = Pesky.advDeck[slot]
			if details then
				print(string.format("slot %i: %imin, %s", slot, details.duration/60, details.name))
			end
		end
	elseif command == "last" then
		local details = Pesky_AdventureDB[Pesky.lastAdventure]
		print(string.format("%s (%i) %s", details.id, details.duration, details.name))
	elseif command == "bl" or command == "blacklist" then
		Pesky_AdventureBL[Pesky.lastAdventure] = true
		print("Blacklisted: ", Pesky.lastAdventure)
	elseif command == "ui" then
		--[[if not Pesky.MinionFrame0 then
			Pesky.MinionFrame0 = Pesky.UI.CreateMinionIcon("frame0", Pesky.context)
			Pesky.MinionFrame0:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 600, 50)
		else
			Pesky.MinionFrame0:SetVisible(not Pesky.MinionFrame0:GetVisible())
		end]]--
		if not Pesky.UI.minionWidget then
			Pesky.UI.UpdateSuitableMinions(Pesky_AdventureDB[Pesky.lastAdventure])
		else
			Pesky.UI.minionWidget:SetVisible(not Pesky.UI.minionWidget:GetVisible())
		end
	elseif command == "noicon" then
		for id, details in pairs(Pesky.minionDB) do
			if not Pesky.Data.Minion[id] then
				print("missing minion: ", id, details.name)
			elseif not Pesky.Data.Minion[id].icon then
				print("missing icon: ", id, details.name)
			end
		end
	elseif command == "stats" then
		local adv_count = {}
		for id, details in pairs(Pesky_AdventureDB) do
			adv_count[details.duration] = (adv_count[details.duration] or 0) + 1
		end
		for duration, count in pairs(adv_count) do
			print("duration: ", duration, " count: ", count)
		end
	else
		dump(command, #command)
	end
end

function Pesky.LoadEndHandler(hEvent, addonID)
	--dump(addonID)
	if addonID ~= addon.toc.Identifier then return end

	if not Pesky_AdventureDB then
		Pesky_AdventureDB = {}
	end
	if not Pesky_AdventureBL then
		Pesky_AdventureBL = {}
	end
end

function Pesky.AvailabilityHandler(hEvent, units)
	-- TODO: Attach System.Update.End handler here if not initialized yet
	-- and make it poll until we get minion data
	for id, specifier in pairs(units) do
		if specifier == "player" then
			print("Availability.Full")
			Command.Event.Attach(Event.System.Update.End, Pesky.SystemUpdateHandler_Init, "pesky_poll_init")
			Command.Event.Detach(Event.Unit.Availability.Full, Pesky.AvailabilityHandler, "pesky_availability")
		end
	end
end

-- Event.Addon.Startup.End is useless, happens way before Availability.Full
--function Pesky.StartupHandler(hEvent)
function Pesky.SystemUpdateHandler_Init(hEvent)
	local adv_list = Inspect.Minion.Adventure.List()
	if not adv_list or not next(adv_list) then
		--print("Adventures not available yet!")
		return
	end
	local adventures = Inspect.Minion.Adventure.Detail(adv_list)
	for id, details in pairs(adventures) do
		if details.mode == "available" then
			Pesky.availableAdv[id] = details
			Pesky.AddToDeck(details)
			Pesky.UpdateAdventureDB(details)
		end
	end
	Pesky.InitMinionDB()
	Command.Event.Detach(Event.System.Update.End, Pesky.SystemUpdateHandler_Init, "pesky_poll_init")
end

function Pesky.MinionChangeHandler(hEvent, minions)
	print("Minion.Change")
	if not Pesky.minionDB then return end
	for id, _ in pairs(minions) do
		Pesky.minionDB[id] = Inspect.Minion.Minion.Detail(id)
	end
end

Command.Event.Attach(Event.Minion.Adventure.Change, Pesky.AdventureChangeHandler, "pesky_shuffle")
Command.Event.Attach(Command.Slash.Register("pesky"), Pesky.CommandHandler, "Pesky Minions Command")
Command.Event.Attach(Event.Addon.SavedVariables.Load.End, Pesky.LoadEndHandler, "Pesky Loaded")
Command.Event.Attach(Event.Minion.Minion.Change, Pesky.MinionChangeHandler, "pesky_minion_update")
Command.Event.Attach(Event.Unit.Availability.Full, Pesky.AvailabilityHandler, "pesky_availability")
--Command.Event.Attach(Event.System.Update.End, Pesky.SystemUpdateHandler_Init, "pesky_poll_init")
