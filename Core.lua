local AddonName, ns = ...
_G.ABUADDONS = ns

---------------------------------------------------------------------------
--							Event Handler								 --
---------------------------------------------------------------------------
local eventframe = CreateFrame("Frame")
eventframe:SetScript("OnEvent", function(self, event, ...)
	if self[event] then
		for _, func in pairs(self[event]) do
			func(event, ...)
		end
	end
end)

function ns.RegisterEvent(event, func)
	assert(type(event) == "string")
	if not eventframe[event] then
		eventframe[event] = {}
	end
	table.insert(eventframe[event], func)
	return eventframe:RegisterEvent(event)
end
function ns.UnregisterEvent(event, func) -- Need to check if this works
	if not eventframe[event] then return; end
	if func and eventframe[event][func]  then
		eventframe[event][func] = nil
	end
	if #eventframe[event] == 0 then
		eventframe:UnregisterEvent(event)
	end
end

local function Load(event, ...)
	if ... ~= AddonName then return end
	if not AbuEssentialsSavedVars then
		_G.AbuEssentialsSavedVars = { };
	end
	ShowAccountAchievements(true);
end
ns.RegisterEvent('ADDON_LOADED', Load)

local function Unload(e)
	_G.ABUADDONS = nil;
end
ns.RegisterEvent("PLAYER_ENTERING_WORLD", Unload)

---------------------------------------------------------------------------
--								COMMANDS								 --
---------------------------------------------------------------------------

--Reeeeeload
_G.SLASH_RELOADUI1 = '/rl'
SlashCmdList.RELOADUI = ReloadUI

--Stacked
_G.SLASH_FSTACK1 = '/fs'
SlashCmdList.FSTACK = function(msg) SlashCmdList.FRAMESTACK(msg) end

-- gm 
_G.SLASH_HELP1 = '/gm'
_G.SLASH_HELP2 = '/ticket'
SlashCmdList.HELP = ToggleHelpFrame

--ItemID
_G.SLASH_ITEMID1 = '/itemid'
SlashCmdList.ITEMID = function(msg) 
	local _, link = GetItemInfo(msg) 
	if link then 
		ChatFrame1:AddMessage(msg .. " has item ID: " .. link:match("item:(%d+):")) 
	end 
end

function ns.Print(...)
	if (not ...) then return; end
	local s = ""
	local t = {...}
	for i = 1, #t do
		s = s .. " " .. t[i]
	end
	return print("|cffffcf00Abu:|r"..s)
end
