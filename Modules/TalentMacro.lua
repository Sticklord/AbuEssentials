----------------------------------------------
-- Usage: Name a macro "Tier#", where # is the tier.
-- Then the macro is marked and any spell name in there
-- will be replaced with the selected talent. 
-- You MUST have 2 spaces and capital first, and small letter last i.e. "  Living bomb"
--
-- "#showtooltip  Living Bomb"
-- "/cast [@mouseover,exists,harm]  Living Bomb; [@target,harm]  Living Bomb"
--
-- Will be changed to:
--
-- "#showtooltip  Nether Tempest"
-- "/cast [@mouseover,exists,harm]  Nether Tempest; [@target,harm]  Nether Tempest"
-------------------------------------------
-- 	"#showtooltip  Blazing Speed"
--	"/cast  Blazing Speed"
--	"/cast Frostbolt"
--
--Will be changed to:
--
--	"#showtooltip  Ice Floes"
--	"/cast  Ice Floes"
--	"/cast Frostbolt"
----------------------------------------------
local _, ns = ...

local fixNames = {
	["Invocation"] = "Evocation",
}

local function UpdateMacros(event, ...)
	if InCombatLockdown() then return end
	local cSpec = GetActiveSpecGroup()
	
	for tier = 1, GetMaxTalentTier() do
		for column = 1, 3 do
			local id, name, _, selected = GetTalentInfo(tier, column, cSpec)
			if selected then
				local macrotext = GetMacroBody("Tier" .. tier)
				if macrotext then 
					if fixNames[name] then
						name = fixNames[name]
					end
					-- match: Space, Space, Uppercase letter [any word, letter, " , - ' "]as many as possible, end on lowercase letter
					macrotext = string.gsub(macrotext, "%s%s%u[A-Za-z0-9%,%-%'% ]+%l", "  " .. name)
					EditMacro("Tier"..tier, nil, "INV_Misc_QuestionMark", macrotext)
				end
			end
		end
	end
end

ns:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateMacros)
ns:RegisterEvent("PLAYER_TALENT_UPDATE", UpdateMacros)
ns:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", UpdateMacros)

--[[macro: TotT
#showtooltip Tricks of the Trade
/run if IsShiftKeyDown() and not InCombatLockdown() then SetTotTMacro() end
/cast [@name] Tricks of the Trade
]]
local MACRONAME = "TotT"
function _G.SetTotTMacro()
	local macrotext = GetMacroBody(MACRONAME)
	local name = UnitName("target")
	if (macrotext) and name then
		EditMacro(MACRONAME	, nil, "INV_Misc_QuestionMark", string.gsub(macrotext, "%@(.-)%]", "@"..name.."]"))
	end
end