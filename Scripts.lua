local AddonName, Abu = ...

--  [[ Change DameFont ]] --
_G.DAMAGE_TEXT_FONT = Abu.Config.Fonts.Damage

--  [[ Map Edit 	]] --
WorldMapFrame:SetScript("OnMouseWheel", function(self, delta)
	local newLevel = GetCurrentMapDungeonLevel() + delta
	if newLevel >= 1 and newLevel <= GetNumDungeonMapLevels() then
		PlaySound("INTERFACESOUND_GAMESCROLLBUTTON")
		SetDungeonMapLevel(newLevel)
	end
end)

--	[[	Raid Warnings	]] --
RaidWarningFrame:ClearAllPoints()
RaidWarningFrame:SetPoint('CENTER', UIParent, 'CENTER', 0, 260)
RaidWarningFrameSlot2:ClearAllPoints()
RaidWarningFrameSlot2:SetPoint('TOP', RaidWarningFrameSlot1, 'BOTTOM', 0, -3)
RaidBossEmoteFrameSlot2:ClearAllPoints()
RaidBossEmoteFrameSlot2:SetPoint('TOP', RaidBossEmoteFrameSlot1, 'BOTTOM', 0, -3)

--	[[ Hide Annoying Spell Overlays	]] --
do
	local HIDESPELLS = {
		[135286] = true, -- Teeth n claw druid
		[93622] = true,  -- Mangle
	}
	hooksecurefunc("SpellActivationOverlay_ShowOverlay", function(self, spellID)
		if HIDESPELLS[spellID] then
			SpellActivationOverlay_HideOverlays(SpellActivationOverlayFrame, spellID)
		end
	end)
end

-- 	[[ Remove Poisonous stuff ]] --
PVPReadyDialog.leaveButton:Hide()
PVPReadyDialog.enterButton:ClearAllPoints()
PVPReadyDialog.enterButton:SetPoint("BOTTOM", PVPReadyDialog, "BOTTOM", 0, 25)
StaticPopupDialogs.ADDON_ACTION_FORBIDDEN.button1 = nil
StaticPopupDialogs.TOO_MANY_LUA_ERRORS.button1 = nil
StaticPopupDialogs.RESURRECT.hideOnEscape = nil
StaticPopupDialogs.AREA_SPIRIT_HEAL.hideOnEscape = nil
StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = nil

--	[[	Hide fish tooltips	]]  --
local function HideFishTip()
	GameTooltip:HookScript("OnShow", function()
		local tooltipText = GameTooltipTextLeft1
		if tooltipText and tooltipText:GetText() == "Fishing Bobber" then
			GameTooltip:Hide()
		end
	end)
end
Abu.RegisterEvent("PLAYER_LOGIN", HideFishTip)

--	[[	Move Loots 	]] --
do
	local originals = {}
	local hooked = {}

	local alerts = LOOT_WON_ALERT_FRAMES

	local function Hook(frame)
		originals[frame] = frame:GetScript("OnShow")
		frame:HookScript("OnShow", frame.Hide)
		frame:Hide()
		hooked[frame] = true
	end

	local function LootWonAlertFrame_ShowAlert_Hook(itemLink, quantity, rollType, roll)
		for i = 1, #alerts do
			local frame = alerts[i]
			if not hooked[frame] then
				Hook(frame)
			end
		end
	end

	hooksecurefunc("LootWonAlertFrame_ShowAlert", LootWonAlertFrame_ShowAlert_Hook)
end

--	[[	Change Raid Sliders ]]  --
local function ChangeRaidSliders()
	if not IsAddOnLoaded('Blizzard_CompactUnitFrameProfiles') then
		LoadAddOn("Blizzard_CompactUnitFrameProfiles")
	end
	local h = _G["CompactUnitFrameProfilesGeneralOptionsFrameHeightSlider"]
	local w = _G["CompactUnitFrameProfilesGeneralOptionsFrameWidthSlider"] 
	h:SetMinMaxValues(1,150) 
	w:SetMinMaxValues(1,150)
end

Abu.RegisterEvent("PLAYER_LOGIN", ChangeRaidSliders)