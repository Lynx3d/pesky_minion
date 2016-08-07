local addon, Pesky = ...

Pesky.Adventure = {}

function Pesky.Adventure.GetSlot(details)
	local slot
	if details.costAventurine == 0 then
		-- known: 1m, 3m
		if details.duration <= 180 then
			slot = 1
		-- known: 5m, 10m, 15m, 20m
		elseif details.duration >= 300 and details.duration <= 1200 then
			slot = 2
		-- known: 8h, 10h
		elseif details.duration >= 28800 and details.duration <= 36000 then
			slot = 3
		end
	elseif details.costAventurine == 250 and (details.duration == 14400 or details.duration == 36000) then
		slot = 4
	end

	if not slot then
		print("unknown adventure slot:")
		dump(details)
	end
	return slot
end
