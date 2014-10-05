----------------------------------------------
-- Changes the "gryphons" to figures according to warrior stances.
----------------------------------------------
local AddonName, ns = ...

local texPath = "Interface\\AddOns\\AbuEssentials\\Textures\\SquidMod\\"
local playerClass = select(2, UnitClass("player"))

if playerClass ~= "WARRIOR" then return; end

local function SetSideCaps(event, ...)
	--if UnitInVehicle("player") then
	--	MainMenuBarRightEndCap:SetSize(128, 128)
	--	MainMenuBarLeftEndCap:SetSize(128, 128)
	--	MainMenuBarLeftEndCap:SetPoint('BOTTOM', MainMenuBarArtFrame, -289, 0)
	--	MainMenuBarRightEndCap:SetPoint('BOTTOM', MainMenuBarArtFrame, 289, 0)
	--else
	MainMenuBarLeftEndCap:SetSize(90, 90)
	MainMenuBarLeftEndCap:ClearAllPoints()
	MainMenuBarLeftEndCap:SetPoint("BOTTOM", "MainMenuBarArtFrame", "BOTTOM", 275, 0)

	MainMenuBarRightEndCap:SetSize(90, 90)
	MainMenuBarRightEndCap:ClearAllPoints()
	MainMenuBarRightEndCap:SetPoint("BOTTOM", "MainMenuBarArtFrame", "BOTTOM", -275, 0)
	if GetShapeshiftForm() == 1 then		-- BATTLE STANCE
		MainMenuBarLeftEndCap:SetTexture(texPath.."WBattle.tga")
		MainMenuBarRightEndCap:SetTexture(texPath.."WBattle.tga")
	elseif GetShapeshiftForm() == 2	then	-- DEFENSIVE STANCE
		MainMenuBarLeftEndCap:SetTexture(texPath.."WDefensive.tga")
		MainMenuBarRightEndCap:SetTexture(texPath.."WDefensive.tga")
	elseif GetShapeshiftForm() == 3 then	-- BERSERKER STANCE
		MainMenuBarLeftEndCap:SetTexture(texPath.."WBerserker.tga")
		MainMenuBarRightEndCap:SetTexture(texPath.."WBerserker.tga")
	else
		MainMenuBarLeftEndCap:SetTexture(texPath.."WUnknown.tga")
		MainMenuBarRightEndCap:SetTexture(texPath.."WUnknown.tga")
	end
	--end
	--MainMenuBarLeftEndCap.SetPoint = function() end
	--MainMenuBarRightEndCap.SetPoint = function() end
end

ns.RegisterEvent("PLAYER_ENTERING_WORLD", SetSideCaps)
ns.RegisterEvent("UPDATE_SHAPESHIFT_FORM", SetSideCaps)