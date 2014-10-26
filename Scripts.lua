local AddonName, ns = ...

--  [[ Change DameFont ]] --
_G.DAMAGE_TEXT_FONT = ns.Config.Fonts.Damage

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
ns.RegisterEvent("PLAYER_LOGIN", HideFishTip)

--	[[	Move Loots 	]] --
do
	local alerts = _G.LOOT_WON_ALERT_FRAMES
	local function LootWonAlertFrame_ShowAlert_Hook(itemLink, quantity, rollType, roll)
		for i = 1, #alerts do
			local frame = alerts[i]
			if not frame.UraltUndSenilLahmAufMichZuKroch then
				frame:HookScript("OnShow", frame.Hide)
				frame:Hide()
				frame.UraltUndSenilLahmAufMichZuKroch = true
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
	CompactUnitFrameProfilesGeneralOptionsFrameHeightSlider:SetMinMaxValues(1,150) 
	CompactUnitFrameProfilesGeneralOptionsFrameWidthSlider:SetMinMaxValues(1,150)
end

ns.RegisterEvent("PLAYER_LOGIN", ChangeRaidSliders)

-- [[ Change LFD to holiday ]]
LFDParentFrame:HookScript("OnShow", function()
	for i = 1, GetNumRandomDungeons() do
		local id, name = GetLFGRandomDungeonInfo(i)
		if(select(15,GetLFGDungeonInfo(id))) and (not GetLFGDungeonRewards(id)) then
			LFDQueueFrame_SetType(id)
		end
	end
end)

---------------------------------------------------------------------------
-- 						TekKrush  Credits to Tek						 --
---------------------------------------------------------------------------

local function tekKrush(event, id, rollType)
	for i=1,STATICPOPUP_NUMDIALOGS do
		local frame = _G["StaticPopup"..i]
		if frame.which == "CONFIRM_LOOT_ROLL" and frame.data == id 
			and frame.data2 == rollType and frame:IsVisible() 
		then
			StaticPopup_OnClick(frame, 1) 
		end
	end
end
ns.RegisterEvent("CONFIRM_DISENCHANT_ROLL", tekKrush)

StaticPopupDialogs["LOOT_BIND"].OnCancel = function(self, slot)
	if GetNumGroupMembers() == 0 then 
		ConfirmLootSlot(slot) 
	end
end