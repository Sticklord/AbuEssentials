local AddonName, ns = ...
local cfg = ns.Config
local playerGUID
local ShowIDs = false

if false then return end

local 	GetTime, UnitName, UnitLevel, UnitExists, UnitIsDeadOrGhost, UnitFactionGroup =
		_G.GetTime, _G.UnitName, _G.UnitLevel, _G.UnitExists, _G.UnitIsDeadOrGhost, _G.UnitFactionGroup
local   UnitIsPlayer, GetMouseFocus, GetInventoryItemLink, GetInventorySlotInfo, GetItemInfo =
		_G.UnitIsPlayer, _G.GetMouseFocus, _G.GetInventoryItemLink, _G.GetInventorySlotInfo, _G.GetItemInfo
local 	UnitClass, UnitIsTapped, UnitIsTappedByPlayer, UnitReaction, IsShiftKeyDown= 
		_G.UnitClass, _G.UnitIsTapped, _G.UnitIsTappedByPlayer, _G.UnitReaction, _G.IsShiftKeyDown
local   GetSpecialization, GetInspectSpecialization, GetSpecializationRoleByID, GetSpecializationInfoByID, GetSpecializationInfo = 
		_G.GetSpecialization, _G.GetInspectSpecialization, _G.GetSpecializationRoleByID, _G.GetSpecializationInfoByID, _G.GetSpecializationInfo
		

local 	find, 		 format, 		select, _G , floor,  unpack =
		string.find, string.format, select, _G, _G.floor, _G.unpack

local roleicons = {
	TANK = '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:0:19:22:41|t',
	HEALER = '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:20:39:1:20|t',
	DAMAGER = '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:20:39:22:41|t',
	NONE = '',
}

local Classification = {
	worldboss = "|cffAF5050B|r",
	rareelite = "|cffAF5050R+|r",
	elite = "|cffAF5050+|r",
	rare = "|cffAF5050R|r",
}

-- For finding Ilvl
local InvSlotNames = {	
		'Head', 'Neck', 'Shoulder', 'Back', 'Chest',
		'Wrist','Hands','Waist','Legs','Feet','Finger0',
		'Finger1','Trinket0','Trinket1','MainHand','SecondaryHand',
}
local UpgradeILvlMap = {
	['0'] = 0,['1'] = 4,['373'] = 4,['374'] = 8,['375'] = 4,['376'] = 8,['377'] = 12,
	['379'] = 4,['380'] = 8,['445'] = 0,['446'] = 4,['447'] = 8,['451'] = 0,['452'] = 4,
	['453'] = 0,['454'] = 4,['455'] = 8,['456'] = 0,['457'] = 4,['458'] = 0,['459'] = 4,
	['460'] = 8,['461'] = 12,['462'] = 16,['465'] = 0,['466'] = 4,['467'] = 8,['468'] = 0,
	['469'] = 4,['470'] = 8,['471'] = 12,['472'] = 16,['476'] = 0,['491'] = 0,['492'] = 4,['493'] = 8,
	['494'] = 0,['495'] = 4,['496'] = 8,['497'] = 12,['498'] = 16,['504'] = 12,['505'] = 16,
	['506'] = 20,['507'] = 24,
}
--[=================================================[
-- saving for later, to find item upgrade ids

local t = tip or CreateFrame("GameTooltip", "tip", UIParent, "GameTooltipTemplate")
t:SetOwner(UIParent, "ANCHOR_TOPLEFT")
local link = "|cffa335ee|Hitem:99161:0:0:4618:0:0:0:0:90:0:504|h[Chronomancer Hood]|h|r"
t:SetHyperlink(link)
t:Show()
ChatFrame3:Clear()

local i = 0
t.elapsed = 0
t:SetScript("OnUpdate", function(self, elapsed)
      self.elapsed = self.elapsed + elapsed
      if self.elapsed > .1 then
         if i % 100 == 0 then print (i) end
         local link = "|cffa335ee|Hitem:99161:0:0:4618:0:0:0:0:90:0:"..i.."|h[Chronomancer Hood]|h|r"
         
         self:ClearLines()
         self:SetHyperlink(link)
         
         for k = 2, self:NumLines() do
            local text = _G["tipTextLeft"..k]:GetText()
            if text and text ~= "" then
               local up = strmatch(text, "^" .. gsub(ITEM_UPGRADE_TOOLTIP_FORMAT, "%%d", "(%%d+)"))
               if up then
                  ChatFrame3:AddMessage("['"..i.."'] = " .. (up * 4) ..",")
               end
            end
         end
         i = i + 1
         self.elapsed = 0
      end
end)
--]=================================================]

local Tooltips = {
	GameTooltip,
	ItemRefTooltip,
	ItemRefShoppingTooltip1,
	ItemRefShoppingTooltip2,
	ItemRefShoppingTooltip3,
	AutoCompleteBox,
	FriendsTooltip,
	ConsolidatedBuffsTooltip,
	ShoppingTooltip1,
	ShoppingTooltip2,
	ShoppingTooltip3,
	WorldMapTooltip,
	WorldMapCompareTooltip1,
	WorldMapCompareTooltip2,
	WorldMapCompareTooltip3,
	DropDownList1MenuBackdrop,
	DropDownList2MenuBackdrop,
	DropDownList3MenuBackdrop,
	BNToastFrame
}

local NIL_COLOR = 	 { r = 1,  g = 1,  b = 1 }
local TAPPED_COLOR = { r = 0.6,g = 0.6,b = 0.6 }

-- Get the Unit Color
local function GetUnitColor( unit )
	if (not unit) then unit = "mouseover" end

	local color
	if (UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		color = _G.RAID_CLASS_COLORS[class]
	elseif (UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then
		color = TAPPED_COLOR
	else
		local reaction = UnitReaction(unit, "player")
		if (reaction) then
			color = _G.FACTION_BAR_COLORS[reaction]
		end
	end
	if (not color) then
		color = NIL_COLOR
	end
	return color, color.r, color.g, color.b
end

-- Format Numbers
local function GetFormattedValue(val)
	if(val >= 1e6) then
		return ("%.0fm"):format(val / 1e6)
	elseif(val >= 1e3) then
		return ("%.0fk"):format(val / 1e3)
	else
		return ("%d"):format(val)
	end
end

-- Hide Useless Lines
local function HideLines(self)
	for i = 3, self:NumLines() do
		local tiptext = _G["GameTooltipTextLeft"..i]
		local linetext = tiptext:GetText()

		if (linetext) then
			if (linetext:find(_G.PVP)) or (linetext:find(_G.FACTION_ALLIANCE)) or (linetext:find(_G.FACTION_HORDE)) then
				tiptext:SetText(nil)
				tiptext:Hide()
			end
		end
	end
end

-- Find a line
local function FindLine(self, text, offset)
	offset = offset or 2
	for i=offset, self:NumLines() do
		local tipText = _G["GameTooltipTextLeft"..i]
		if(tipText:GetText() and tipText:GetText():find(text)) then
			return tipText
		end
	end
end

-- Get the correct Unit
local function GetGameTooltipUnit(self)
	local _, unit = self:GetUnit()

	-- Check if we got the correct unit
	if (not unit) then
		local MFocus = GetMouseFocus()
		if (MFocus and MFocus:GetAttribute("unit")) then
			unit = MFocus:GetAttribute("unit");
		end
		if (not unit) or (not UnitExists(unit)) then
			return false;
		end
	end
	return unit
end

--  [[  Inspect Stuff  ]] --
local function GetItemUpgrade(link)
	if not link then return 0; end

	local upgrade = link:match(":(%d+)\124h%[")
	if upgrade then
		if not UpgradeILvlMap[upgrade] then
			ns.Print("Unknown Item Upgrade code: " .. upgrade .. ". Item: " .. link)
			return 0;
		end
		return UpgradeILvlMap[upgrade]
	end
	return 0;
end

local ipairs = _G.ipairs
local function GetItemLevel(unit)
	local totlvl, numItems = 0, 0
	for i, v in ipairs(InvSlotNames) do
		local link = GetInventoryItemLink(unit, GetInventorySlotInfo(v..'Slot'))
		if link ~= nil then
			local _, _, _, ilvl = GetItemInfo(link)
			numItems = numItems + 1
			totlvl = totlvl + ilvl + (GetItemUpgrade(link) or 0)
		end
	end
	if numItems > 5 and numItems < 17 and totlvl > 1 then
		return floor(totlvl/numItems + .5)
	end
	return false
end
-- Get spec Icon 
local function GetSpecIcon(unit, isPlayer)
	local spec
	if(isPlayer) then
		spec = GetSpecialization()
	else
		spec = GetInspectSpecialization(unit)
	end
	if(spec ~= nil and spec > 0) then
		if (not isPlayer) then 
			local role = GetSpecializationRoleByID(spec);
			if(role ~= nil) then
				local _, _, _, icon = GetSpecializationInfoByID(spec);
				return icon
			end
		else
			local _, _, _, icon = GetSpecializationInfo(spec)
			return icon
		end
	end
end

-- OnEvent
local function GameTooltip_OnEvent(self, event, ...)
	local unit = "mouseover"
	if event == "MODIFIER_STATE_CHANGED" then
		if((... == "LSHIFT" or ... == "RSHIFT") and UnitExists(unit)) then
			self:SetUnit(unit)
		end
	elseif event == "INSPECT_READY" then
		local GUID = ...
		if (self.requestedGUID ~= GUID) or (_G.InspectFrame and _G.InspectFrame:IsShown()) then 
			return
		end

		if (UnitExists(unit)) then 
			local cache = self.inspectCache

			-- Fetch data while we got inspect
			local iLvl = GetItemLevel(unit)
			local specIcon = GetSpecIcon(unit)
			local now = floor(GetTime())

			cache[GUID] = {lastUpdate = now}
			if specIcon then
				cache[GUID].specIcon = specIcon
			end
			if iLvl then
				cache[GUID].iLvl = iLvl
			end

			-- Update tooltip
			self:SetUnit(unit)
		end
		self:UnregisterEvent(event)
	end
end

-- Getting the inspect Info, sometimes
local function GetInspectInfo(self, unit, level, needIlvl, specIcon, iLvl)
	if (not CanInspect(unit)) then return; end

	local GUID = UnitGUID(unit)

	if (GUID == playerGUID) then
		specIcon = GetSpecIcon(unit, true)
		local _, iLvl = GetAverageItemLevel()
		return specIcon, floor(iLvl)
	end

	local cache = self.inspectCache[GUID]
	local specIcon, iLvL = specIcon, iLvl

	if (cache) then
		specIcon = cache.specIcon
		iLvl = cache.iLvl
		if (specIcon) and (iLvl or not needIlvl) then
			return specIcon, iLvl
		end

		if ((cache.lastUpdate - floor(GetTime())) > 120) or (not specIcon) or (iLvl or not needIlvl) then
			self.inspectCache[GUID] = nil
			-- try again ... save the current specicon and ilvl
			return GetInspectInfo(self, unit, level, needIlvl, specIcon, iLvl)
		end
	end

	if (_G.InspectFrame and _G.InspectFrame:IsShown()) then return specIcon, iLvl; end 
	self.requestedGUID = GUID
	self:RegisterEvent("INSPECT_READY")
	NotifyInspect(unit)
	return specIcon, iLvl;
end

--  [[  Apply The Tooltip Style  ]]  --
local function SetTooltipStyle(self)
	if not self then return; end

	local borderSize, bgSize
    if (self == _G.ConsolidatedBuffsTooltip) then
        bgSize = 3
        borderSize = 12
    elseif (self == _G.FriendsTooltip) then
        self:SetScale(1.1)
        bgSize = 3
        borderSize = 8
    else
        bgSize = 3
        borderSize = 12
    end

    local backdrop = {	bgFile = 'Interface\\Buttons\\WHITE8x8', 
						tile = false,
						tileSize = 16,
						edgeSize = 3,
						insets = {left = bgSize, right = bgSize, top = bgSize, bottom = bgSize}};
	self:SetBackdrop(backdrop)

	self:HookScript("OnShow", function(self) self:SetBackdropColor(0, 0, 0, .7) end)
	ns.CreateBorder(self, borderSize, 0)
	self:SetBorderColor(unpack(cfg.Colors.Border))
end

local function GameTooltip_OnTooltipSetUnit(self)
	local unit = GetGameTooltipUnit(self)
	if (not unit) then return; end

	HideLines(self)

	local level = UnitLevel(unit)
	local isShiftKeyDown = IsShiftKeyDown()
	local color, r, g, b = GetUnitColor(unit)
	local name, realm = UnitName(unit)

	if UnitIsPlayer(unit) and name ~= _G.UNKNOWN then
		local localeClass, class = UnitClass(unit)
		local specIcon, iLvl = GetInspectInfo(self, unit, level, isShiftKeyDown)

		-- [[ Player Name Stuff ]]
		local titledName = UnitPVPName(unit)
		if cfg.Tooltip.ShowTitle and titledName then
			name = titledName
		end

		local role = UnitGroupRolesAssigned(unit)
		if (cfg.Tooltip.RoleIcon and role) then
			name = roleicons[role]..' '..name
		end

		local relationship = UnitRealmRelationship(unit)
		if (realm and realm ~= '') then
			if (isShiftKeyDown) then
				name = name..'-'..realm
			elseif( relationship == LE_REALM_RELATION_COALESCED) then
				name = name..'|cffcccccc'..FOREIGN_SERVER_LABEL..'|r'
			elseif( relationship == LE_REALM_RELATION_VIRTUAL) then
				name = name..'|cffcccccc'..INTERACTIVE_SERVER_LABEL..'|r'
			end
		end

		local status
		if UnitIsAFK(unit) then
			status = CHAT_FLAG_AFK
		elseif UnitIsDND(unit) then
			status = CHAT_FLAG_DND
		elseif not UnitIsConnected(unit) then
			status = '[DC]'
		end
		if (status) then name = name..' |cff00cc00'..status..'|r' end
		GameTooltipTextLeft1:SetFormattedText("|c%s%s|r", color.colorStr, name)

		-- [[ Guild ]] --
		local guildName, guildRankName, _, guildRealm = GetGuildInfo(unit)
		if (guildName) then
			if (guildRealm and isShiftKeyDown) then
				guildName = guildName.."-"..guildRealm
			end

			if (cfg.Tooltip.ShowGuildRanks) then
				GameTooltipTextLeft2:SetText(("<|cffff20cc%s|r> |cff00E6A8%s|r"):format(guildName, guildRankName))
			else
				GameTooltipTextLeft2:SetText(("<|cffff20cc%s|r>"):format(guildName))
			end
		end

		-- [[ Level ]] --
		local offset = guildName and 3 or 2
		local LevelLine = FindLine(self, LEVEL, offset)
		if (LevelLine) then
			local diffColor = GetQuestDifficultyColor(level)
			local race, englishRace = UnitRace(unit)
			local _, factionGroup = UnitFactionGroup(unit)
			if(factionGroup and englishRace == "Pandaren") then
				race = factionGroup..(race and " "..race or "")
			end
			if specIcon then
				localeClass = ' |T'..specIcon..':0|t '..localeClass
			end
			LevelLine:SetFormattedText("|cff%02x%02x%02x%s|r %s |c%s%s|r", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "??", race or '', color.colorStr, localeClass)
		end

		if (iLvl) and (isShiftKeyDown) then
			self:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL .. ':', '|cffFFFFFF'..iLvl..'|r')
		end
	else
		local LevelLine = FindLine(self, LEVEL, 2)
		if(LevelLine) then
			local creatureClassification = UnitClassification(unit)
			local creatureType = UnitCreatureType(unit)
			local pvpFlag = ""
			local diffColor
			if(UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then
				level = UnitBattlePetLevel(unit)
				
				local teamLevel = C_PetJournal.GetPetTeamAverageLevel();
				if(teamLevel) then
					diffColor = GetRelativeDifficultyColor(teamLevel, level); 
				else
					diffColor = GetQuestDifficultyColor(level)
				end
			else
				diffColor = GetQuestDifficultyColor(level)
			end
	
			if(UnitIsPVP(unit)) then
				pvpFlag = format(" (%s)", PVP)
			end

			LevelLine:SetFormattedText("|cff%02x%02x%02x%s|r%s %s%s", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "|cffAF5050??|r", Classification[creatureClassification] or "", creatureType or "", pvpFlag)
		end
	end

	-- [[ Target Of Target ]] --
	local unittarget = unit.."target"
	if (UnitExists(unittarget)) then		
		local target
		if(UnitIsUnit(unittarget, "player")) then
			target = format("|cffff0000%s|r", '<You>')
		else
			local _, r, g, b = GetUnitColor(unittarget)
			target = format("|cff%02x%02x%02x%s|r", r*255, g*255, b*255, UnitName(unittarget))
			local Icon = GetRaidTargetIndex(unittarget)
			if Icon then
				target = format("%s%s", ICON_LIST[Icon].."10|t", target)
			end
		end
		GameTooltip:AddDoubleLine(TARGET..":", target)
	end

	-- [[ Fix statusbar pos ]] --
	self:AddLine(' ')
	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:SetPoint('LEFT', self:GetName()..'TextLeft'..self:NumLines(), 1, -3)
	GameTooltipStatusBar:SetPoint('RIGHT', self, -10, 0)

	if(color) then
		GameTooltipStatusBar:SetStatusBarColor(r, g, b)
	else
		GameTooltipStatusBar:SetStatusBarColor(0.6, 0.6, 0.6)
	end
end

local function GameTooltip_OnTooltipCleared(self)
	if not self.borderTextures then return; end
	self:SetBorderTextureFile('default')
	self:SetBorderColor(unpack(cfg.Colors.Border))
end

local function GameTooltip_OnTooltipSetItem(self)
	local item, iLink = self:GetItem()
	if item and self.borderTextures then
		local _, _, quality = GetItemInfo(item)
		if quality then
			self:SetBorderTextureFile('white')
			self:SetBorderColor(GetItemQualityColor(quality))
		end
	end
end

local function GameTooltip_ShowCompareItem(self, shift)
    if ( not self ) then
        self = GameTooltip;
    end
    local item, link = self:GetItem();
    if ( not link ) then
        return;
    end
     
    for _, tip in pairs({unpack(self.shoppingTooltips)}) do
    	if tip and tip:IsShown() then
    		GameTooltip_OnTooltipSetItem(tip)
    	end
    end
end

local function GameTooltipStatusBar_OnValueChanged(self, value)
	if not value and not self.Text then return; end
	local unit = GetGameTooltipUnit(self:GetParent())
	
	local min, max = self:GetMinMaxValues()

	if (value > 0) and (max == 1) then
		self.Text:SetFormattedText('%d%%', floor(value * 100))
	elseif (value == 0 or (unit and UnitIsDeadOrGhost(unit))) then
		self.Text:SetText(DEAD)
	else
		self.Text:SetText(GetFormattedValue(value).." / "..GetFormattedValue(max))
	end
end
-- Showing ID's
local function SetUnitAura(self, unit, index, filter)
	local _, _, _, _, _, _, _, caster, _, _, id = UnitAura(unit, index, filter)
	if(ShowIDs and spellID) then
		if caster then
			local name = UnitName(caster)
			local _, class = UnitClass(caster)
			local color = RAID_CLASS_COLORS[class]
			self:AddDoubleLine(("|cFFCA3C3C%s|r %d"):format(ID, id), format("|c%s%s|r", color.colorStr, name))
		else
			self:AddLine(("|cFFCA3C3C%s|r %d"):format(ID, id))
		end
		GameTooltip:Show()
	end
end

local function SetUnitConsolidatedBuff(self, unit, index)
	local name = GetRaidBuffTrayAuraInfo(index)
	SetUnitAura(self, unit, name)
end

local function GameTooltip_OnTooltipSetSpell(self)
	local _, _, id = self:GetSpell()
	if not id or not ShowIDs then return end

	local displayString = ("|cFFCA3C3C%s|r %d"):format(ID, id)
	local lines = self:NumLines()
	local isFound
	for i= 1, lines do
		local line = _G[("GameTooltipTextLeft%d"):format(i)]
		if line and line:GetText() and line:GetText():find(displayString) then
			isFound = true;
			break
		end
	end
	
	if not isFound then
		self:AddLine(displayString)
		self:Show()
	end
end

local function SetItemRef(link, text, button, chatFrame)
	if find(link,"^spell:") and ShowIDs then
		local id = string.sub(link,7)
		ItemRefTooltip:AddLine(("|cFFCA3C3C%s|r %d"):format(ID, id))
		ItemRefTooltip:Show()
	end
end
-- Make the spacing between comparing tooltips bigger
local function FixShoppingPosition(self, p, par, rp, x, y)
	if x ~= 0 then return; end
	x = (p == "TOPRIGHT") and -3 or 3
	self:SetPoint(p, par, rp, x, y)
end

local function LoadTooltips(event, name)
	-- Setup variables
	playerGUID = UnitGUID("player")
	GameTooltip.inspectCache = {}

	-- Basic Styling
	GameTooltipHeaderText:SetFont(cfg.Fonts.Normal, cfg.Tooltip.FontSize + 2)
	GameTooltipText:SetFont(cfg.Fonts.Normal, cfg.Tooltip.FontSize)
	GameTooltipTextSmall:SetFont(cfg.Fonts.Normal, cfg.Tooltip.FontSize)

	for _, tip in pairs(Tooltips) do
		SetTooltipStyle(tip)
	end

	-- Skin Statusbar
	GameTooltipStatusBar.Text = GameTooltipStatusBar:CreateFontString(nil, "OVERLAY")
	GameTooltipStatusBar.Text:SetPoint("CENTER", GameTooltipStatusBar, 0, 1)
	GameTooltipStatusBar.Text:SetFont(cfg.Fonts.Normal, cfg.Tooltip.FontSize, "THINOUTLINE")

	GameTooltipStatusBar:SetHeight(7)
	GameTooltipStatusBar:SetBackdrop({bgFile = 'Interface\\Buttons\\WHITE8x8'})
	GameTooltipStatusBar:SetBackdropColor(0, 0, 0, 0.3)
	GameTooltipStatusBar:SetScript('OnValueChanged', GameTooltipStatusBar_OnValueChanged)
	GameTooltipStatusBar:SetStatusBarTexture(cfg.Statusbar.Normal)

	-- Modify Unit Tooltip
	GameTooltip:HookScript('OnTooltipSetUnit', GameTooltip_OnTooltipSetUnit)

	-- Color Item Border
	GameTooltip:HookScript('OnTooltipCleared', GameTooltip_OnTooltipCleared)
	GameTooltip:HookScript('OnTooltipSetItem', GameTooltip_OnTooltipSetItem)

	hooksecurefunc("GameTooltip_ShowCompareItem", GameTooltip_ShowCompareItem)

	-- Fix the anchors
	hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
		self:SetOwner(parent, "ANCHOR_NONE")
		self:SetPoint(unpack(cfg.Tooltip.Position))
	end)
	hooksecurefunc(ShoppingTooltip1, "SetPoint", FixShoppingPosition)
	hooksecurefunc(ShoppingTooltip2, "SetPoint", FixShoppingPosition)
	hooksecurefunc(ShoppingTooltip3, "SetPoint", FixShoppingPosition)

	-- Spell / ItemID
	SlashCmdList.SPELLID = function(msg)
		ShowIDs = not ShowIDs
		if (ShowIDs) then
			ns.Print("ID's in tooltips: ON")
		else
			ns.Print("ID's in tooltips: OFF")
		end
	end
	_G.SLASH_SPELLID1 = "/spellid"

	hooksecurefunc(GameTooltip, "SetUnitAura", SetUnitAura)
	hooksecurefunc(GameTooltip, "SetUnitBuff", SetUnitAura)
	hooksecurefunc(GameTooltip, "SetUnitDebuff", SetUnitAura)
	hooksecurefunc(GameTooltip, "SetUnitConsolidatedBuff", SetUnitConsolidatedBuff)
	GameTooltip:HookScript("OnTooltipSetSpell", GameTooltip_OnTooltipSetSpell)
	hooksecurefunc("SetItemRef", SetItemRef)

	-- Setup events
	GameTooltip:RegisterEvent("MODIFIER_STATE_CHANGED")
	GameTooltip:HookScript("OnEvent", GameTooltip_OnEvent)
end

ns.RegisterEvent("PLAYER_LOGIN", LoadTooltips)