local name, ns = ...

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
hooksecurefunc("SpellActivationOverlay_ShowOverlay", function(self, spellID)
	if ns.Config.HidePowa[spellID] then
		SpellActivationOverlay_HideOverlays(SpellActivationOverlayFrame, spellID)
	end
end)

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
ns:RegisterEvent("PLAYER_LOGIN", HideFishTip)

-- Replace Blizzards duration display
do	local minute, hour, day = 60, 60*60, 60*60*24
	local hourish, dayish = minute*59, hour*23 
	function _G.SecondsToTimeAbbrev(sec)
		if ( sec >= dayish  ) then
			return '|cffffffff%dd|r', floor(sec/day + .5);
		elseif ( sec >= hourish  ) then
			return '|cffffffff%dh|r', floor(sec/hour + .5);
		elseif ( sec >= minute  ) then
			return '|cffffffff%dm|r', floor(sec/minute + .5);
		end
		return '|cffffffff%d|r', sec;
end	end

--	[[	Change Raid Sliders ]]  --
local function ChangeRaidSliders()
	if not IsAddOnLoaded('Blizzard_CompactUnitFrameProfiles') then
		LoadAddOn("Blizzard_CompactUnitFrameProfiles")
	end
	CompactUnitFrameProfilesGeneralOptionsFrameHeightSlider:SetMinMaxValues(1,150) 
	CompactUnitFrameProfilesGeneralOptionsFrameWidthSlider:SetMinMaxValues(1,150)
end

ns:RegisterEvent("PLAYER_LOGIN", ChangeRaidSliders)

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
-- 						autoclick static StaticPopupDialogs						 --
---------------------------------------------------------------------------

local function autoClick(which, arg1, arg2, data)
	for i=1,STATICPOPUP_NUMDIALOGS do
		local frame = _G["StaticPopup"..i]
		if (not frame:IsVisible()) then
			return;
		end

		if frame.which == "CONFIRM_LOOT_ROLL" then
			if frame.data == arg1 and frame.data2 == arg2 then
				StaticPopup_OnClick(frame, 1) 
			end
		elseif frame.which == "CONFIRM_PURCHASE_TOKEN_ITEM" then
			if string.find(arg1, "Garrison Resources") then
				StaticPopup_OnClick(frame, 1) 
			end
		end
	end
end
hooksecurefunc("StaticPopup_Show", autoClick)

StaticPopupDialogs["LOOT_BIND"].OnCancel = function(self, slot)
	if GetNumGroupMembers() == 0 then 
		ConfirmLootSlot(slot) 
	end
end

-- Encanting scrolls button
local scrollb
local enchanting = GetSpellInfo(7411)

ns:RegisterEvent("ADDON_LOADED", function(event, name)
	if (not scrollb) and (name == "Blizzard_TradeSkillUI") then

		scrollb = CreateFrame("Button", "TradeSkillScrollButton", TradeSkillFrame, "MagicButtonTemplate")
		scrollb:SetPoint("TOPRIGHT", TradeSkillCreateButton, "TOPLEFT", -3, 0)

		scrollb:SetScript("OnClick", function(self, button, down)
			DoTradeSkill(TradeSkillFrame.selectedSkill)
			UseItemByName(38682)
		end)
		
		hooksecurefunc("TradeSkillFrame_SetSelection", function(index)
			local name, skillType, numAvailable, isExpanded, altVerb = GetTradeSkillInfo(index)
			if IsTradeSkillGuild() or IsTradeSkillLinked() then
				scrollb:Hide()
			elseif (altVerb) and (CURRENT_TRADESKILL == enchanting) then
				local scrollnum = GetItemCount(38682)
				scrollb:SetText("Scroll ("..scrollnum..")")

				scrollb:Show()
				if (altVerb ~= "Enchant") or (not name) or (scrollnum < 1) or (TradeSkillCreateButton:GetButtonState() == "DISABLE") then
					scrollb:Disable()
				else
					scrollb:Enable()
				end
			else
				scrollb:Hide()
			end
		end)
	end
end)

-- Fix blizz token UI, and maybe it breaks other addons, but screw em
local _GetCurrencyListInfo = GetCurrencyListInfo
local _GetCurrencyListSize = GetCurrencyListSize
local MyCurrencyOrder = {}

-- Our update function:
function _G.GetCurrencyListSize()
	wipe(MyCurrencyOrder)
	local size = _GetCurrencyListSize()
	local warlordsInserted = 0
	for i = 1, size do
		local name, isHeader, isExpanded, isUnused, isWatched, count, icon = _GetCurrencyListInfo(i)

		if name == "Warlords of Draenor" or warlordsInserted > 0 then
			warlordsInserted = warlordsInserted + 1
			table.insert(MyCurrencyOrder, warlordsInserted, i)
		else
			table.insert(MyCurrencyOrder, i)
		end
	end
	return size
end

function _G.GetCurrencyListInfo(index)
	return _GetCurrencyListInfo(MyCurrencyOrder[index] or index)
end

hooksecurefunc("TokenFrame_Update", function()
	local buttons = TokenFrameContainer.buttons;
	if not buttons then return; end
	local offset = HybridScrollFrame_GetOffset(TokenFrameContainer);

	for i = 1, #buttons do
		local index = offset+i;
		local button = buttons[i]
		local name = GetCurrencyListInfo(i)
		if ( name == TokenFrame.selectedToken ) then
			TokenFrame.selectedID = MyCurrencyOrder[index];
			button:LockHighlight();
		else
			button:UnlockHighlight();
		end
		button.index = MyCurrencyOrder[index];
	end
end)

-- Moveable alertframe
do
	_G.SLASH_MOVEALERTFRAME1 = '/alertframe'
	_G.SLASH_MOVEALERTFRAME2 = '/alert'

	AlertFrame:SetMovable(true)
	AlertFrame:SetUserPlaced(true)
	local mover, alertframe_unlocked = nil, false

	SlashCmdList.MOVEALERTFRAME = function(m)
		if not mover then
			mover = CreateFrame('Frame', 'AlertFrame_Mover')
			mover:SetSize(180, 70)
			mover:SetPoint('BOTTOM', AlertFrame)
			mover:SetClampedToScreen(true)
			mover:EnableMouse(true)
			mover:RegisterForDrag("LeftButton")

			local tex = mover:CreateTexture(nil, "OVERLAY")
			tex:SetTexture(0.4, 0.4, 0.4, 0.4)
			tex:SetAllPoints(mover)

			local string = mover:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
			string:SetText("Alert Frame\nAlt-Click to reset")
			string:SetPoint('CENTER', tex)

			mover:SetScript("OnDragStart", function()
				AlertFrame:StartMoving()
			end)

			mover:SetScript("OnDragStop", function()
				AlertFrame:StopMovingOrSizing()
			end)
			mover:SetScript("OnMouseDown", function(self)
				if IsAltKeyDown() then
					AlertFrame:StopMovingOrSizing()
					AlertFrame:ClearAllPoints()
					AlertFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 128)
				end
			end)

		end

		if alertframe_unlocked then
			mover:Hide()
			AlertFrame:StopMovingOrSizing()
		else
			mover:Show()
		end
		alertframe_unlocked = not alertframe_unlocked
	end
end

---------------------------------------------------------------
--		Garrison stuff
---------------------------------------------------------------
do
	local button
	local function start_ticker()
		if button:IsVisible() and button:IsEnabled() then
			_G.GarrisonCapacitiveStartWorkOrder_OnClick()
			_G.C_Timer.After(0.5, start_ticker)
		end
	end

	local function enableWorkOrderMousewheel(e, addon)
		if (addon ~= "Blizzard_GarrisonUI") then return; end

		button = GarrisonCapacitiveDisplayFrame.StartWorkOrderButton
		button:HookScript("OnMouseUp", function(self, button)
			if (button == "LeftButton") then return; end
			start_ticker()
		end)
		ns:UnregisterEvent(e, enableWorkOrderMousewheel)
	end
	ns:RegisterEvent("ADDON_LOADED", enableWorkOrderMousewheel)
end
