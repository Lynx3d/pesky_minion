local addon, Pesky = ...

Pesky.Adventure = {}

function Pesky.Adventure.GetSlot(details)
	local slot
	if details.costAventurine == 0 then
		if details.duration == 60 then
			slot = 1
		elseif details.duration == 300 or details.duration == 900 or details.duration == 1200 then
			slot = 2
		elseif details.duration == 28800 then
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
